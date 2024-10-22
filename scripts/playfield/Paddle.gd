class_name Paddle
extends Area2D

@export var collider: CollisionShape2D
@export var color: ColorRect

var team: Team
var player: Player

const baseWidth := 100.0

var polygonWidthMultiplier
var oldPolygonWidthMultiplier
var polygonWidthMultiplierDelta

var teamSizeWidthMultiplier: float
const TEAM_SIZE_WIDTH_MULTIPLIERS := {
	1 : 1.0,
	2 : 0.8,
	3 : 0.7,
	4 : 0.625,
	5 : 0.55,
	6 : 0.5,
	7 : 0.45,
	8 : 0.4
}

var _width: float
var width: float:
	get: return _width

var baseHeight := 10
var height: float:
	get: return baseHeight

var baseSpeed := 150.0
var polygonSpeedMultiplier: float
var oldPolygonSpeedMultiplier: float
var polygonSpeedMultiplierDelta: float
var _speed: float
var speed: float:
	get: return _speed

var movable := true
var moving := false
enum {NONE, LEFT, RIGHT}
var direction: int
var leftKey: String
var leftKeyAlt: String
var rightKey: String
var rightKeyAlt: String

var leftOfPaddle: Paddle = null
var rightOfPaddle: Paddle = null
var atBoundary: bool
var remainingDistance: float
var connectedPaddles: Array[Paddle]

var transitioning := false
var transitionDuration: float
var transitionTimeElapsed: float = 10
var transitionFraction: float

var verticalFraction: float

var leftBoundary: float
var rightBoundary: float


func _ready():
	pass


func initPaddle(
	p_verticalFraction: float, polygon: PolygonGuide.Polygon, p_team: Team, p_player: Player,
	xPosFraction: float, p_leftBoundary: float, p_rightBoundary: float
):

	verticalFraction = p_verticalFraction
	team = p_team
	player = p_player
	leftBoundary = p_leftBoundary
	rightBoundary = p_rightBoundary

	polygonWidthMultiplier = polygon.paddleWidthMultiplier
	polygonSpeedMultiplier = polygon.paddleSpeedMultiplier
	teamSizeWidthMultiplier = TEAM_SIZE_WIDTH_MULTIPLIERS[len(team.players)]
	updateWidthAndHeight()
	_speed = baseSpeed * polygonSpeedMultiplier
	print("Init paddle at " + str(position))
	position.x = leftBoundary + ((rightBoundary-width)-leftBoundary)*xPosFraction

	updateDirectionKeys()


func updateDirectionKeys():
	
	var teamAngle := team.angle

	if teamAngle > -PI/2 + 0.1 and teamAngle < PI/2 - 0.1:
		rightKey = player.rightInput
		leftKey = player.leftInput
	elif teamAngle < -PI/2 - 0.1 or teamAngle > PI/2 + 0.1:
		rightKey = player.leftInput
		leftKey = player.rightInput
	else:
		rightKey = ''
		leftKey = ''

	if teamAngle > 0.1 and teamAngle < PI - 0.1:
		rightKeyAlt = player.downInput
		leftKeyAlt = player.upInput
	elif teamAngle < -0.1 and teamAngle > -PI + 0.1:
		rightKeyAlt = player.upInput
		leftKeyAlt = player.downInput
	else:
		rightKeyAlt = ''
		leftKeyAlt = ''


func changePolygon(newPolygon: PolygonGuide.Polygon, p_transitionDuration: float):

	transitioning = true
	transitionDuration = p_transitionDuration
	transitionTimeElapsed = 0

	oldPolygonWidthMultiplier = polygonWidthMultiplier
	var targetPolygonWidthMultiplier := newPolygon.paddleWidthMultiplier
	polygonWidthMultiplierDelta = targetPolygonWidthMultiplier - oldPolygonWidthMultiplier

	oldPolygonSpeedMultiplier = polygonSpeedMultiplier
	var targetPolygonSpeedMultiplier := newPolygon.paddleSpeedMultiplier
	polygonSpeedMultiplierDelta = targetPolygonSpeedMultiplier - oldPolygonSpeedMultiplier

func processTransitions(delta):

	if transitioning:

		transitionTimeElapsed += delta
		if transitionTimeElapsed >= transitionDuration:
			transitionTimeElapsed = transitionDuration
			transitioning = false
		transitionFraction = transitionTimeElapsed/transitionDuration

		polygonWidthMultiplier = oldPolygonWidthMultiplier + polygonWidthMultiplierDelta*transitionFraction
		polygonSpeedMultiplier = oldPolygonSpeedMultiplier + polygonSpeedMultiplierDelta*transitionFraction

	updateWidthAndHeight()
	

func updateWidthAndHeight():
	_width = baseWidth * teamSizeWidthMultiplier * polygonWidthMultiplier * verticalFraction**2
	collider.shape.size.x = width
	collider.position.x = width/2
	color.size.x = width

	position.y = -team.height*(1-verticalFraction)-height
	
	atBoundary = false


func forceUpdateWidth(newWidth: float):
	_width = newWidth
	collider.shape.size.x = width
	collider.position.x = width/2
	color.size.x = width


func checkForValidPos() -> bool:
	var validPos := true

	if leftOfPaddle == null:
		if position.x < leftBoundary:
			validPos = false
			atBoundary = true
			position.x = leftBoundary + 0.1
	else:
		var overlap := leftOfPaddle.position.x + leftOfPaddle.width - position.x
		if overlap > 0.01:
			validPos = false
			if atBoundary:
				leftOfPaddle.position.x -= overlap + 0.01
				leftOfPaddle.atBoundary = true
			elif leftOfPaddle.atBoundary:
				position.x += overlap + 0.01
				atBoundary = false
			else:
				leftOfPaddle.position.x -= overlap/2 + 0.01
				position.x += overlap/2 + 0.01

	if rightOfPaddle == null:
		if position.x + width > rightBoundary:
			validPos = false
			atBoundary = true
			position.x = rightBoundary - width - 0.01
	else:
		var overlap := position.x + width - rightOfPaddle.position.x
		if overlap > 0.01:
			validPos = false
			if atBoundary:
				rightOfPaddle.position.x += overlap + 0.01
				rightOfPaddle.atBoundary = true
			elif rightOfPaddle.atBoundary:
				position.x -= overlap + 0.01
				atBoundary = false
			else:
				rightOfPaddle.position.x += overlap/2 + 0.01
				position.x -= overlap/2 + 0.01

	return validPos


func processInput(delta: float):

	remainingDistance = 0
	connectedPaddles = [self]
	direction = NONE

	if not moving: updateDirectionKeys()

	moving = false
	if movable:
		_speed = baseSpeed*polygonSpeedMultiplier
		if player.isInputPressed(leftKey) or player.isInputPressed(leftKeyAlt):
			remainingDistance -= speed*delta
			direction = LEFT
			moving = true
		if player.isInputPressed(rightKey) or player.isInputPressed(rightKeyAlt):
			remainingDistance += speed*delta
			direction = RIGHT
			moving = true
		if Input.is_key_pressed(player.sdInput): team.eliminateTeam.emit(team)


func moveUntilCollision():

	if remainingDistance > 0:

		if rightOfPaddle in connectedPaddles: return

		elif rightOfPaddle != null and rightOfPaddle.position.x - (position.x + width) < remainingDistance:

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

		elif leftOfPaddle != null and (leftOfPaddle.position.x + width) - position.x > remainingDistance:

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
	for connectedPaddle in connectedPaddles:
		connectedPaddle.position.x += distanceToMove
		if movingToBoundary:
			connectedPaddle.remainingDistance = 0
			direction = NONE
		else:
			connectedPaddle.remainingDistance -= distanceToMove


func connectPaddles(leftPaddles: Array[Paddle], rightPaddles: Array[Paddle]):
	var newRemainingDistance = (
		(leftPaddles[0].remainingDistance*len(leftPaddles) + rightPaddles[0].remainingDistance*len(rightPaddles)) /
		float(len(leftPaddles) + len(rightPaddles))
	)

	for leftPaddle in leftPaddles:
		leftPaddle.remainingDistance = newRemainingDistance
		leftPaddle.connectedPaddles += rightPaddles
	for rightPaddle in rightPaddles:
		rightPaddle.remainingDistance = newRemainingDistance
		rightPaddle.connectedPaddles += leftPaddles

