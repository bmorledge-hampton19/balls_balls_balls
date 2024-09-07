extends Node

@export var ballPrefab: PackedScene
var balls: Dictionary

@export var averageSpawnTime: float = 5.0
@export var spawnTimeDeviation: float = 2.5
var timeUntilNextSpawn: float = 0

@export var averageSpawnSpeed: float = 100
@export var spawnSpeedDeviation: float = 25


func _ready():
	pass


func _process(delta):
	
	timeUntilNextSpawn -= delta

	if timeUntilNextSpawn <= 0:

		var newBall: Ball = ballPrefab.instantiate()
		balls[newBall] = null
		add_child(newBall)

		newBall.onBallInGoal.connect(deleteBall)
		newBall.baseSpeed = averageSpawnSpeed + randf_range(-spawnSpeedDeviation, spawnSpeedDeviation)

		if randi_range(0,1): newBall.direction = Vector2.from_angle(randf_range(0.1,PI))
		else: newBall.direction = Vector2.from_angle(randf_range(0.1,PI)*-1)

		timeUntilNextSpawn = averageSpawnTime + randf_range(-spawnTimeDeviation, spawnTimeDeviation)


func deleteBall(ball: Ball):
	balls.erase(ball)
	ball.queue_free()
