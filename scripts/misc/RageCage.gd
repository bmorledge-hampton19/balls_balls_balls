extends Node
@export var camera: Camera2D

@export var background: Background

@export var theBall: TheBall

@export var ballPrefab: PackedScene
@export var ballsControl: Control

@export var trailPrefab: PackedScene
@export var trailsCG: CanvasGroup

var timeBetweenTheBallGrowths: float = 10
var timeUntilNextTheBallGrowth: float

func createBall(position := Vector2(480,270), direction := Vector2(0,1),
				speed: float = 100, additiveAcceleration: float = 0,
				behavior := Ball.Behavior.CONSTANT_LINEAR, behaviorIntensity = Ball.SMOOTH,
				color := Color.WHITE):

	var newBall: Ball = ballPrefab.instantiate()
	var newTrail: Trail = trailPrefab.instantiate()
	newBall.trail = newTrail
	ballsControl.add_child(newBall)
	trailsCG.add_child(newTrail)

	newBall.position = position
	newBall.baseSpeedDirection = direction
	newBall.baseSpeed = speed
	newBall.additiveAcceleration = additiveAcceleration
	newBall.behavior = behavior
	newBall.behaviorIntensity = behaviorIntensity
	newBall.updateColor(color)
	newBall.onBallHitWall.connect(background.spawnBallArc)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	ScreenShaker.setCamera(camera)

	var behavior: Ball.Behavior
	var behaviorIntensity: int
	var direction: Vector2

	for i in range(50):
		behavior = randi_range(1,7) as Ball.Behavior
		if randi_range(0,1): behaviorIntensity = Ball.SMOOTH
		else: behaviorIntensity = Ball.ERRATIC
		if randi_range(0,1): direction = Vector2.from_angle(randf_range(0.1,PI-0.1))
		else: direction = Vector2.from_angle(randf_range(0.1,PI-0.1)*-1)
		createBall(Vector2(480,270), direction, 100, 5, behavior, behaviorIntensity)
	createBall(Vector2(480,270))

	timeUntilNextTheBallGrowth = timeBetweenTheBallGrowths


func _process(delta):
	timeUntilNextTheBallGrowth -= delta
	if timeUntilNextTheBallGrowth <= 0:
		timeUntilNextTheBallGrowth = timeBetweenTheBallGrowths
		theBall.initiateGrowth()
		