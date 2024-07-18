class_name PaddleManager
extends Node

var paddlePrefab: PackedScene
var paddles: Array[Paddle]
var bottomLayerPaddles: Array[Paddle]
var middleLayerPaddles: Array[Paddle]
var topLayerPaddles: Array[Paddle]


func initPaddles(polygon: PolygonGuide.Polygon, team: Team):
	var teamSize := len(team.players)
	for i in range(teamSize):

		var paddle := paddlePrefab.instantiate() as Paddle
		paddles.append(paddle)

		var verticalPosition: int
		var xPosFraction: float
		var layerArray: Array[Paddle]

		match i:

			0,3,6:
				verticalPosition = Paddle.BOTTOM
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
				verticalPosition = Paddle.MIDDLE
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
				verticalPosition = Paddle.TOP
				layerArray = topLayerPaddles
				if teamSize >= 6:
					if i == 2:
						xPosFraction = 0.25
					else:
						xPosFraction = 0.75
				else:
					xPosFraction = 0.5
		
		paddle.initPaddle(verticalPosition, polygon, team, xPosFraction)
		layerArray.append(paddle)
		if i >= 3:
			paddle.leftOfPaddle = layerArray[i/3-1]
			paddle.leftOfPaddle.rightOfPaddle = paddle


func changePolygon(newPolygon: PolygonGuide.Polygon, newTransitionDuration: float):
	for paddle in paddles:
		paddle.changePolygon(newPolygon, newTransitionDuration)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	for paddle in paddles:
		paddle.processTransitions(delta)
		paddle.processInput(delta)
	
	for paddleGroup in [bottomLayerPaddles, middleLayerPaddles, topLayerPaddles]:
		while not groupHasFinishedMoving(paddleGroup):
			for paddle in paddleGroup:
				if paddle.remainingDistance != 0:
					paddle.moveUntilCollision()


func groupHasFinishedMoving(paddleGroup: Array[Paddle]) -> bool:

	for paddle in paddleGroup:
		if paddle.remainingDistance != 0: return false
	
	return true
