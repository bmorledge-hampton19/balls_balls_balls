class_name Team
extends Control

@export var goal: Area2D
@export var goalShader: ColorRect
@export var goalCollider: CollisionPolygon2D
@export var paddleManager: PaddleManager
@export var particleEmitterControl: Control
@export var particleEmitterPrefab: PackedScene

var _leftVertexTracker: VertexTracker
var _rightVertexTracker: VertexTracker

var leftVertex: Vertex:
	get: return _leftVertexTracker.vertex
var rightVertex: Vertex:
	get: return _rightVertexTracker.vertex

var leftInnerAngle: float
var rightInnerAngle: float
var sideLength: float:
	get: return size.x
	set(value): size.x = value
var height: float
var angle: float:
	get:
		var leftVertexAngle := angle_difference(0,leftVertex.rotation)
		var vertexAngleDifference := angle_difference(leftVertexAngle, rightVertex.rotation)
		return angle_difference(0, leftVertexAngle + vertexAngleDifference/2)


var livesRemaining: int
var ballsInGoal: Dictionary

var color: Color
var players: Array[Player]

signal onLivesChanged(lives: int)
signal eliminateTeam(team: Team)

func initTeam(
	polygon: PolygonGuide.Polygon, p_leftVertex: Vertex, p_rightVertex: Vertex,
	p_players: Array[Player], p_color: Color
):

	_leftVertexTracker = VertexTracker.new(p_leftVertex)
	_rightVertexTracker = VertexTracker.new(p_rightVertex)

	players = p_players.duplicate()
	players.shuffle()

	color = p_color
	goalShader.color = color

	updateTeamControl()
	updateGoalCollider()

	paddleManager.initPaddles(polygon, self)


func changePolygon(polygon: PolygonGuide.Polygon, transitionDuration: float):

	paddleManager.changePolygon(polygon, transitionDuration)	


# Called when the node enters the scene tree for the first time.
func _ready():
	livesRemaining = Settings.getSettingValue(Settings.Setting.STARTING_LIVES)

func _physics_process(_delta):

	updateGoalCollider()

	for ball in ballsInGoal.keys():
		if not is_instance_valid(ball): ballsInGoal.erase(ball)
		else: checkBall(ball)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	# if Input.is_physical_key_pressed(KEY_ENTER) and transitionTimeElapsed > 1:
	# 	changePolygon(polygon-1, targetRotation/180*PI, 5)

	updateTeamControl()
	
	paddleManager.processPaddles(delta)


func updateTeamControl():

	global_position = leftVertex.global_position

	var verticesAngle: float = abs(angle_difference(leftVertex.rotation, rightVertex.rotation))

	if verticesAngle == 0:
		size.x = 0
		leftInnerAngle = 90
		rightInnerAngle = 90
		rotation = 0
		height = leftVertex.macroRadius

	else:
		size.x = sqrt(
			leftVertex.macroRadius**2 + rightVertex.macroRadius**2 -
			2*leftVertex.macroRadius*rightVertex.macroRadius *
			cos(verticesAngle)
		)

		leftInnerAngle = acos(
			(rightVertex.macroRadius**2 - size.x**2 - leftVertex.macroRadius**2) /
			(-2 * size.x * leftVertex.macroRadius)
		)
		rightInnerAngle = PI-leftInnerAngle-verticesAngle
		rotation = leftVertex.rotation + leftInnerAngle - PI/2

		if leftInnerAngle < 90: height = sin(leftInnerAngle)*leftVertex.macroRadius
		else: height = sin(rightInnerAngle)*rightVertex.macroRadius


func updateGoalCollider():
	var newGoalColliderPolygon := PackedVector2Array()

	newGoalColliderPolygon.append(Vector2(0,0))
	newGoalColliderPolygon.append(Vector2(size.x,0))

	if rightInnerAngle < 90:
		newGoalColliderPolygon.append(Vector2(size.x + 200/tan(rightInnerAngle), 200))
	elif rightInnerAngle == 90:
		newGoalColliderPolygon.append(Vector2(size.x, 200))
	else:
		newGoalColliderPolygon.append(Vector2(size.x - 200/tan(PI-rightInnerAngle), 200))
	
	if leftInnerAngle < 90:
		newGoalColliderPolygon.append(Vector2(-200/tan(leftInnerAngle), 200))
	elif leftInnerAngle == 90:
		newGoalColliderPolygon.append(Vector2(0, 200))
	else:
		newGoalColliderPolygon.append(Vector2(200/tan(PI-leftInnerAngle), 200))

	goalCollider.polygon = newGoalColliderPolygon


func onBallEnterGoal(ball: Area2D):
	print("Ball entered")
	if not ball.inGoal:
		ballsInGoal[ball as Ball] = null
		

func onBallExitGoal(ball: Area2D):
	print("Ball exited")
	ballsInGoal.erase(ball)


func checkBall(ball: Ball):
	var localBallPos = goal.to_local(ball.global_position)
	if localBallPos.y > ball.radius:

		if ball.lastPlayer != null:
			if ball.ballController == null:
				if ball.lastPlayer.teamColor == color: ball.lastPlayer.goals -= 1
				else: ball.lastPlayer.goals += 1
				ball.lastPlayer.onGoal.emit(ball.lastPlayer.goals)
			else:
				ball.ballController.player.goals += 1
				ball.ballController.player.onGoal.emit(ball.ballController.player.goals)

			if (
				ball.powerupType != PowerupManager.Type.NONE and
				is_instance_valid(ball.lastPlayer.paddle) and
				ball.lastPlayer.paddle.color.color != self.color
			):
				PowerupManager.initPowerupAnimation(
					ball.powerupType, ball.lastPlayer.paddle,
					ball.global_position - ball.radius*Vector2.from_angle(rotation+PI/2)
				)

		ballsInGoal.erase(ball)
		ball.onBallInGoal.emit(ball, self)
		livesRemaining -= 1
		onLivesChanged.emit(livesRemaining)
		if livesRemaining == 0:
			for otherBall in ballsInGoal:
				(otherBall as Ball).goalsEncompassing.erase(goal)
				# print("Encompassement: " + str(goal.to_local(otherBall.global_position).y))
				if goal.to_local(otherBall.global_position).y >= otherBall.radius/2: otherBall.onBallInGoal.emit(otherBall,self)
			eliminateTeam.emit(self)
		
		AudioManager.playGoal(color)

func addLives(livesToAdd: int):
	livesRemaining += livesToAdd
	onLivesChanged.emit(livesRemaining)