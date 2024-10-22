extends Node

@export var ballPrefab: PackedScene
@export var ballsControl: Control

@export var trailPrefab: PackedScene
@export var trailsControl: Control

func createBall(position := Vector2(480,270), direction := Vector2(0,1),
				speed: float = 100, additiveAcceleration: float = 0,
				color = Color.WHITE):

	var newBall: Ball = ballPrefab.instantiate()
	var newTrail: Trail = trailPrefab.instantiate()
	newBall.trail = newTrail
	ballsControl.add_child(newBall)
	trailsControl.add_child(newTrail)

	newBall.position = position
	newBall.direction = direction
	newBall.baseSpeed = speed
	newBall.additiveAcceleration = additiveAcceleration
	newBall.updateColor(color)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	createBall(Vector2(480,270), Vector2(0.1,1).normalized(), 2000, 0)