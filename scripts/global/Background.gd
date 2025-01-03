class_name Background
extends ColorRect

@export var backgroundBallPrefab: PackedScene
@export var backgroundBallsControl: Control


var center: Vector2:
	get: return Vector2(size.x/2, size.y/2)
var boundsRadius: float:
	get: return sqrt(size.x**2 + size.y**2)/2

var flowDirection := Vector2.RIGHT
var changingFlow: bool
var oldFlowAngle: float
var flowAngleDelta: float
var flowChangeDuration: float
var flowChangeTimeElapsed: float


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if changingFlow:
		flowChangeTimeElapsed += delta
		if flowChangeTimeElapsed >= flowChangeDuration:
			flowChangeTimeElapsed = flowChangeDuration
			changingFlow = false
		flowDirection = Vector2.from_angle(oldFlowAngle + flowAngleDelta*flowChangeTimeElapsed/flowChangeDuration)

	for backgroundBall in backgroundBallsControl.get_children():
		backgroundBall = backgroundBall as BackgroundBall
		if backgroundBall.independentFlow == Vector2.ZERO:
			backgroundBall.position += backgroundBall.speed*delta*flowDirection.rotated(backgroundBall.flowDeviation)
		else:
			backgroundBall.position += backgroundBall.speed*delta*backgroundBall.independentFlow


func addBackgroundBall():
	for backgroundBall in backgroundBallsControl.get_children():
		if isBallOutOfBounds(backgroundBall): backgroundBall.queue_free()
	var newBackgroundBall: BackgroundBall = backgroundBallPrefab.instantiate()
	backgroundBallsControl.add_child(newBackgroundBall)
	var pos1 = (-center).rotated(flowDirection.angle())+center
	var pos2 = pos1 + Vector2(0,size.y).rotated(flowDirection.angle())
	newBackgroundBall.position = pos1.lerp(pos2,randf())
	newBackgroundBall.position -= newBackgroundBall.radius * Vector2.RIGHT.rotated(flowDirection.angle()) * 2

func initiateFlowChange():
	changingFlow = true
	oldFlowAngle = flowDirection.angle()
	var targetFlowAngle := oldFlowAngle + randf_range(-PI/2,PI/2)
	flowAngleDelta = targetFlowAngle - oldFlowAngle
	flowChangeDuration = 5
	flowChangeTimeElapsed = 0

func isBallOutOfBounds(backgroundBall: BackgroundBall):
	var centerDistance = (backgroundBall.position + Vector2(backgroundBall.radius, backgroundBall.radius) - center).length()
	return centerDistance > boundsRadius + backgroundBall.radius

func spawnBallExplosion(ball: Ball):
	for i in range(10):
		var newBackgroundBall: BackgroundBall = backgroundBallPrefab.instantiate()
		backgroundBallsControl.add_child(newBackgroundBall)
		newBackgroundBall.global_position = ball.global_position
		newBackgroundBall.independentFlow = Vector2.from_angle(i*2*PI/10.0)
		newBackgroundBall.radius = randi_range(5, 10)
		newBackgroundBall.color = ball.teamColor.color

func spawnBallArc(ball: Ball, collisionPoint: Vector2):
	for i in range(8):
		var newBackgroundBall: BackgroundBall = backgroundBallPrefab.instantiate()
		backgroundBallsControl.add_child(newBackgroundBall)
		newBackgroundBall.global_position = collisionPoint
		newBackgroundBall.independentFlow = ball.fullVelocity.normalized().rotated(-PI/4 + PI/16*i)
		newBackgroundBall.color = Color.WHITE
		newBackgroundBall.radius = randi_range(5, 10)
