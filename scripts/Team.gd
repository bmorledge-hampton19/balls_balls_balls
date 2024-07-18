class_name Team
extends Control

@export var goal: Area2D
@export var goalCollider: CollisionPolygon2D
@export var paddleManager: PaddleManager

var polygon: PolygonGuide.Polygon

var transitioning := false
var transitionDuration: float
var transitionTimeElapsed: float = 10
var transitionFraction: float

var oldAngle: float
var angleDelta: float

var oldTeamPosition: Vector2
var teamPositionDelta: Vector2
var oldTeamSize: Vector2
var teamSizeDelta: Vector2
var oldTeamPivotOffset: Vector2
var teamPivotOffsetDelta: Vector2

var oldGoalPosition: Vector2
var goalPositionDelta: Vector2

var oldCollisionVertices: PackedVector2Array
var collisionVerticesDeltas: PackedVector2Array

var livesRemaining: int = 5
var ballsInGoal: Dictionary

var players: Array[Player]


func initTeam(p_polygon: PolygonGuide.Polygon, angle: float, p_players: Array[Player]):

	polygon = p_polygon
	rotation = angle
	players = p_players

	var sideLength := polygon.sideLength
	var height := polygon.microRadius

	position = Vector2(480-sideLength/2,540-height)
	size = Vector2(sideLength, height)
	pivot_offset = Vector2(sideLength/2,pivot_offset.y)
	
	paddleManager.initPaddles(polygon, self)

	goal.position = Vector2(sideLength/2, height)

	goalCollider.polygon.clear()
	var frontVerticesX := sideLength/2
	goalCollider.polygon.append(Vector2(-frontVerticesX,0))
	goalCollider.polygon.append(Vector2(frontVerticesX,0))
	var rearVerticesX := sideLength/2 + 100*tan(PI/polygon.sides)
	goalCollider.polygon.append(Vector2(rearVerticesX,0))
	goalCollider.polygon.append(Vector2(-rearVerticesX,0))


func changePolygon(newPolygon: PolygonGuide.Polygon, newAngle: float, newTransitionDuration: float):

	transitioning = true
	transitionDuration = newTransitionDuration
	transitionTimeElapsed = 0


	oldAngle = rotation
	angleDelta = angle_difference(oldAngle,newAngle)


	var targetSideLength := newPolygon.sideLength
	var targetHeight := newPolygon.microRadius


	oldTeamPosition = position
	var targetTeamPosition := Vector2(480-targetSideLength/2,540-targetHeight)
	teamPositionDelta = targetTeamPosition - oldTeamPosition

	oldTeamSize = size
	var targetTeamSize := Vector2(targetSideLength, targetHeight)
	teamSizeDelta = targetTeamSize-oldTeamSize

	oldTeamPivotOffset = pivot_offset
	var targetTeamPivotOffset := Vector2(targetSideLength/2,pivot_offset.y)
	teamPivotOffsetDelta = targetTeamPivotOffset - oldTeamPivotOffset


	paddleManager.changePolygon(newPolygon, transitionDuration)


	oldGoalPosition = goal.position
	var targetGoalPosition := Vector2(targetSideLength/2, targetHeight)
	goalPositionDelta = targetGoalPosition - oldGoalPosition

	oldCollisionVertices = goalCollider.polygon
	collisionVerticesDeltas.clear()
	var frontVerticesTarget := targetSideLength/2
	var frontVerticesDelta := frontVerticesTarget - oldCollisionVertices[1].x
	collisionVerticesDeltas.append(Vector2(-frontVerticesDelta,0))
	collisionVerticesDeltas.append(Vector2(frontVerticesDelta,0))
	var rearVerticesTarget := targetSideLength/2 + 100*tan(PI/newPolygon.sides)
	var rearVerticesDelta := rearVerticesTarget - oldCollisionVertices[2].x
	collisionVerticesDeltas.append(Vector2(rearVerticesDelta,0))
	collisionVerticesDeltas.append(Vector2(-rearVerticesDelta,0))

	polygon = newPolygon


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	# if Input.is_physical_key_pressed(KEY_ENTER) and transitionTimeElapsed > 1:
	# 	changePolygon(polygon-1, targetRotation/180*PI, 5)

	if transitioning:

		transitionTimeElapsed += delta
		if transitionTimeElapsed >= transitionDuration:
			transitionTimeElapsed = transitionDuration
			transitioning = false
		transitionFraction = transitionTimeElapsed/transitionDuration
		
		updateAngle()
		updateTeamControl()
		updateGoalCollider()

	for ball in ballsInGoal:
		checkBall(ball)


func updateAngle():
	rotation = oldAngle + angleDelta*transitionFraction


func updateTeamControl():
	position = oldTeamPosition + teamPositionDelta*transitionFraction
	size = oldTeamSize + teamSizeDelta*transitionFraction
	pivot_offset = oldTeamPivotOffset + teamPivotOffsetDelta*transitionFraction


func updateGoalCollider():
	goal.position = oldGoalPosition + goalPositionDelta*transitionFraction
	for i in range(goalCollider.polygon.size()):
		goalCollider.polygon[i] = oldCollisionVertices[i] + collisionVerticesDeltas[i]*transitionFraction


func onBallEnterGoal(ball: Area2D):
	print("Ball Entered")
	ballsInGoal[ball as Ball] = null
	print(ballsInGoal)

func onBallExitGoal(ball: Area2D):
	print("Ball Exited")
	ballsInGoal.erase(ball)
	

func checkBall(ball: Ball):
	print(goal.to_local(ball.global_position).y)
	if goal.to_local(ball.global_position).y > ball.radius:
		print("GOOOOOOOOOOOOAL!!!")
		ball.queue_free()