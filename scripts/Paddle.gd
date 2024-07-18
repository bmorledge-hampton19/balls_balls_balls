class_name Paddle
extends Area2D


var polygon: PolygonGuide.Polygon

var baseWidth := 100.0

var polygonWidthMultiplier
var oldPolygonWidthMultiplier
var polygonWidthMultiplierDelta

var teamSizeWidthMultiplier: float
const TEAM_SIZE_WIDTH_MULTIPLIERS := {
	1 : 1.0,
	2 : 0.9,
	3 : 0.85,
	4 : 0.8,
	5 : 0.775,
	6 : 0.75,
	7 : 0.725,
	8 : 0.7
}

var _width: float
var width: float:
	get: return _width
func updateWidthAndRightBoundary():
	_width = baseWidth * teamSizeWidthMultiplier * polygonWidthMultiplier
	if transitioning:
		rightBoundary = oldSideLength + sideLengthDelta*transitionFraction - _width - leftBoundary
	else:
		rightBoundary = polygon.sideLength - _width - leftBoundary

var baseHeight := 10
var height: float:
	get: return baseHeight

var oldYPos: float
var yPosDelta: float

var speed := 150.0
var movable := true

var leftOfPaddle: Paddle = null
var rightOfPaddle: Paddle = null
var remainingDistance: float
var connectedPaddles: Array[Paddle]

var transitioning := false
var transitionDuration: float
var transitionTimeElapsed: float = 10
var transitionFraction: float

enum {BOTTOM, MIDDLE, TOP}
var verticalPosition: int
const VERTICAL_FRACTIONS := {BOTTOM: 1, MIDDLE: 0.9, TOP: 0.8}
var oldPosition: Vector2
var positionDelta: Vector2

const HORIZONTAL_MARGIN := 5
var leftBoundary: float
var oldLeftBoundary: float
var leftBoundaryDelta: float
var rightBoundary: float
var oldSideLength: float
var sideLengthDelta: float

var team: Team


func _ready():
	pass


func initPaddle(p_verticalPosition: int, p_polygon: PolygonGuide.Polygon, p_team: Team, xPosFraction: float):

	verticalPosition = p_verticalPosition
	polygon = p_polygon
	team = p_team

	polygonWidthMultiplier = polygon.paddleWidthMultiplier
	teamSizeWidthMultiplier = TEAM_SIZE_WIDTH_MULTIPLIERS[len(team.players)]
	leftBoundary = HORIZONTAL_MARGIN + polygon.microRadius*VERTICAL_FRACTIONS[verticalPosition]
	updateWidthAndRightBoundary()

	position.x = leftBoundary + (rightBoundary-leftBoundary)*xPosFraction
	position.y = polygon.microRadius*VERTICAL_FRACTIONS[verticalPosition]-height


func changePolygon(newPolygon: PolygonGuide.Polygon, p_transitionDuration: float):

	transitioning = true
	transitionDuration = p_transitionDuration
	transitionTimeElapsed = 0

	oldPolygonWidthMultiplier = polygonWidthMultiplier
	var targetPolygonWidthMultiplier := newPolygon.paddleWidthMultiplier
	polygonWidthMultiplierDelta = targetPolygonWidthMultiplier - oldPolygonWidthMultiplier

	oldYPos = position.y
	var targetYPos: float = newPolygon.microRadius*VERTICAL_FRACTIONS[verticalPosition]-height
	yPosDelta = targetYPos - oldYPos

	oldLeftBoundary = leftBoundary
	var targetLeftBoundary: float = HORIZONTAL_MARGIN + newPolygon.microRadius*VERTICAL_FRACTIONS[verticalPosition]
	leftBoundaryDelta = targetLeftBoundary - oldLeftBoundary

	oldSideLength = polygon.sideLength
	var targetSideLength := newPolygon.sideLength
	sideLengthDelta = targetSideLength - oldSideLength

	polygon = newPolygon


func processTransitions(delta):

	if transitioning:

		transitionTimeElapsed += delta
		if transitionTimeElapsed >= transitionDuration:
			transitionTimeElapsed = transitionDuration
			transitioning = false
		transitionFraction = transitionTimeElapsed/transitionDuration

		polygonWidthMultiplier = oldPolygonWidthMultiplier + polygonWidthMultiplierDelta*transitionFraction
		position.y = oldYPos + yPosDelta*transitionFraction
		leftBoundary = oldLeftBoundary + leftBoundaryDelta*transitionFraction
		updateWidthAndRightBoundary()


func processInput(delta):

	remainingDistance = 0
	connectedPaddles = [self]

	if movable:
		if Input.is_key_pressed(KEY_RIGHT):
			remainingDistance += speed*delta
		if Input.is_key_pressed(KEY_LEFT):
			remainingDistance -= speed*delta


func moveUntilCollision():

	if remainingDistance > 0:

		if rightOfPaddle in connectedPaddles: return

		elif rightOfPaddle != null:

			if rightOfPaddle.position.x - (position.x + width) < remainingDistance:

				moveConnectedPaddles(rightOfPaddle.position.x - (position.x + width))

				if rightOfPaddle.remainingDistance <= 0:

					var leftPaddles: Array[Paddle] = connectedPaddles
					var rightPaddles: Array[Paddle] = rightOfPaddle.connectedPaddles

					connectPaddles(leftPaddles, rightPaddles)
		
		elif rightBoundary - (position.x + width) < remainingDistance:
				
			moveConnectedPaddles(rightBoundary - (position.x + width), true)

		else:

			moveConnectedPaddles(remainingDistance)

	elif remainingDistance < 0:

		if leftOfPaddle in connectedPaddles: return

		elif leftOfPaddle != null:

			if (leftOfPaddle.position.x + width) - position.x > remainingDistance:

				moveConnectedPaddles((leftOfPaddle.position.x + width) - position.x)

				if leftOfPaddle.remainingDistance >= 0:

					var leftPaddles: Array[Paddle] = leftOfPaddle.connectedPaddles
					var rightPaddles: Array[Paddle] = connectedPaddles

					connectPaddles(leftPaddles, rightPaddles)
		
		elif leftBoundary - position.x > remainingDistance:
				
			moveConnectedPaddles(leftBoundary - position.x, true)

		else:

			moveConnectedPaddles(remainingDistance)


func moveConnectedPaddles(distanceToMove: float, movingToBoundary := false):
	position.x += distanceToMove
	if movingToBoundary: remainingDistance = 0
	else: remainingDistance -= distanceToMove
	for connectedPaddle in connectedPaddles:
		connectedPaddle.position.x += distanceToMove
		if movingToBoundary: connectedPaddle.remainingDistance = 0
		else: connectedPaddle.remainingDistance -= distanceToMove


func connectPaddles(leftPaddles: Array[Paddle], rightPaddles: Array[Paddle]):
	var newRemainingDistance = (
		(leftPaddles[0].remainingDistance*len(leftPaddles) + rightPaddles[0].remainingDistance*len(rightPaddles)) /
		(len(leftPaddles) + len(rightPaddles))
	)

	for leftPaddle in leftPaddles:
		leftPaddle.remainingDistance = newRemainingDistance
		leftPaddle.connectedPaddles += rightPaddles
	for rightPaddle in rightPaddles:
		rightPaddle.remainingDistance = newRemainingDistance
		rightPaddle.connectedPaddles += leftPaddles
