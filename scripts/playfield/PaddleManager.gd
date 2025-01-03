class_name PaddleManager
extends Node

var team: Team

@export var paddlePrefab: PackedScene
var paddles: Array[Paddle]
var bottomLayerPaddles: Array[Paddle]
var middleLayerPaddles: Array[Paddle]
var topLayerPaddles: Array[Paddle]
var paddleGroupsByLayer := {
	BOTTOM: bottomLayerPaddles,
	MIDDLE: middleLayerPaddles,
	TOP: topLayerPaddles 
}

enum {BOTTOM, MIDDLE, TOP}
const VERTICAL_FRACTIONS := {BOTTOM: 1, MIDDLE: 0.9, TOP: 0.8}
const HORIZONTAL_MARGIN := 10
var leftBoundaries: Dictionary
var rightBoundaries: Dictionary
var polygon: PolygonGuide.Polygon


func initPaddles(p_polygon: PolygonGuide.Polygon, p_team: Team):
	polygon = p_polygon
	team = p_team
	updateBoundaries()
	var teamSize := len(team.players)
	for i in range(teamSize):

		var paddle := paddlePrefab.instantiate() as Paddle
		add_child(paddle)
		paddles.append(paddle)

		var verticalPosition: int
		var xPosFraction: float
		var layerArray: Array[Paddle]

		match i:

			0,3,6:
				verticalPosition = BOTTOM
				layerArray = bottomLayerPaddles
				if teamSize >= 7:
					if i == 0:
						xPosFraction = 0.15
					elif i == 3:
						xPosFraction = 0.5
					else:
						xPosFraction = 0.85
				elif teamSize >=4:
					if i == 0:
						xPosFraction = 0.25
					else:
						xPosFraction = 0.75
				else:
					xPosFraction = 0.5

			1,4,7:
				verticalPosition = MIDDLE
				layerArray = middleLayerPaddles
				if teamSize >= 8:
					if i == 1:
						xPosFraction = 0.15
					elif i == 4:
						xPosFraction = 0.5
					else:
						xPosFraction = 0.85
				elif teamSize >=5:
					if i == 1:
						xPosFraction = 0.25
					else:
						xPosFraction = 0.75
				else:
					xPosFraction = 0.5

			2,5:
				verticalPosition = TOP
				layerArray = topLayerPaddles
				if teamSize >= 6:
					if i == 2:
						xPosFraction = 0.25
					else:
						xPosFraction = 0.75
				else:
					xPosFraction = 0.5
		
		paddle.initPaddle(
			VERTICAL_FRACTIONS[verticalPosition], polygon, team, team.players[i], xPosFraction,
			leftBoundaries[verticalPosition], rightBoundaries[verticalPosition]
		)
		layerArray.append(paddle)
		if i >= 3:
			paddle.leftOfPaddle = layerArray[i/3-1]
			paddle.leftOfPaddle.rightOfPaddle = paddle


func changePolygon(newPolygon: PolygonGuide.Polygon, transitionDuration: float):
	polygon = newPolygon
	for paddle in paddles:
		paddle.changePolygon(newPolygon, transitionDuration)


func fadePaddleTextures():
	for paddle in paddles:
		paddle.changeTextureAlpha(0, 2)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func processPaddles(delta):

	updateBoundaries()
	for verticalPosition in [BOTTOM, MIDDLE, TOP]:
		var paddleGroup: Array[Paddle] = paddleGroupsByLayer[verticalPosition]
		for paddle in paddleGroup:
			paddle.leftBoundary = leftBoundaries[verticalPosition]
			paddle.rightBoundary = rightBoundaries[verticalPosition]

	for paddle in paddles:
		paddle.processTransitions(delta)

	for verticalPosition in [BOTTOM, MIDDLE, TOP]:
		var paddleGroup: Array[Paddle] = paddleGroupsByLayer[verticalPosition]
		var maxWidth: float = rightBoundaries[verticalPosition] - leftBoundaries[verticalPosition]
		var totalWidth: float = 0
		for paddle in paddleGroup: totalWidth += paddle.width
		if totalWidth > maxWidth:
			var reductionRatio := maxWidth/totalWidth
			print("Paddle group width: ", totalWidth, " exceeds max width: ", maxWidth)
			for paddle in paddleGroup: paddle.forceUpdateWidth(paddle.width*reductionRatio-1)

	for paddleGroup in [bottomLayerPaddles, middleLayerPaddles, topLayerPaddles]:
		var allValidPositions := false
		while not allValidPositions:
			allValidPositions = true
			for paddle in paddleGroup:
				if not paddle.checkForValidPos(): allValidPositions = false

	for paddle in paddles:
		paddle.processInput(delta)
	
	for paddleGroup in [bottomLayerPaddles, middleLayerPaddles, topLayerPaddles]:
		while not groupHasFinishedMoving(paddleGroup):
			for paddle in paddleGroup:
				if paddle.remainingDistance != 0:
					paddle.moveUntilCollision()


func updateBoundaries():

	for verticalPosition in [BOTTOM, MIDDLE, TOP]:

		if polygon.sides == 2 and (not paddles or not paddles[0].transitioning):
			rightBoundaries[verticalPosition] = team.sideLength - HORIZONTAL_MARGIN
			leftBoundaries[verticalPosition] = HORIZONTAL_MARGIN
		
		else:
			if team.rightInnerAngle <= 90:
				rightBoundaries[verticalPosition] = (
					team.sideLength - HORIZONTAL_MARGIN -
					(1-VERTICAL_FRACTIONS[verticalPosition])*cos(team.rightInnerAngle)*team.rightVertex.macroRadius
				)
			else:
				rightBoundaries[verticalPosition] = (
					team.sideLength - HORIZONTAL_MARGIN +
					(1-VERTICAL_FRACTIONS[verticalPosition])*cos(180-team.rightInnerAngle)*team.rightVertex.macroRadius
				)

			if team.leftInnerAngle <= 90:
				leftBoundaries[verticalPosition] = (
					HORIZONTAL_MARGIN +
					(1-VERTICAL_FRACTIONS[verticalPosition])*cos(team.leftInnerAngle)*team.leftVertex.macroRadius
				)
			else:
				leftBoundaries[verticalPosition] = (
					HORIZONTAL_MARGIN -
					(1-VERTICAL_FRACTIONS[verticalPosition])*cos(180-team.leftInnerAngle)*team.leftVertex.macroRadius
				)


func groupHasFinishedMoving(paddleGroup: Array[Paddle]) -> bool:

	for paddle in paddleGroup:
		if paddle.remainingDistance != 0: return false
	
	return true
