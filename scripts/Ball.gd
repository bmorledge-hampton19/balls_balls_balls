class_name Ball
extends Area2D

@export var shapeCaster: ShapeCast2D
@export var baseSpeed: float
@export var additiveAcceleration: float = 0
@export var multiplicativeAcceleration: float = 1 # Note: Alongisde additive acceleration, framerate affects acceleration.
@export var direction: Vector2
var fullVelocity: Vector2:
	get: return direction * (baseSpeed + decayingSpeed)
var radius: float = 4.9
var decayingSpeedBase: float = 0
var decayingSpeed: float:
	get: 
		if decayingSpeedTimeRemaining <= 0: return 0
		else: return decayingSpeedBase*(decayingSpeedTimeRemaining/decayingSpeedDuration)
var decayingSpeedDuration: float
var decayingSpeedTimeRemaining: float

var newDirection: Vector2


func resetDecayingSpeed(newSpeed: float, duration: float = 2):
	decayingSpeedBase = newSpeed
	decayingSpeedDuration = duration
	decayingSpeedTimeRemaining = duration

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):

	var collisionsThisFrame = 0

	decayingSpeedTimeRemaining -= delta
	baseSpeed += additiveAcceleration*delta
	if multiplicativeAcceleration != 1: baseSpeed *= multiplicativeAcceleration**delta
	var remainingDistance := fullVelocity.length()*delta

	while remainingDistance > 0:

		var priorityCollisionIndex := -1
		var priorityCollisionDistance := remainingDistance + radius
		var collisionIsBumper := false
		var collisionIsPaddle := false

		shapeCaster.target_position = shapeCaster.position + remainingDistance*direction
		shapeCaster.force_shapecast_update()

		if shapeCaster.is_colliding():

			for i in len(shapeCaster.collision_result):

				var collider := shapeCaster.get_collider(i) as Area2D
				var competingDistance = (shapeCaster.get_collision_point(i) - global_position).length()

				if collider.get_collision_layer_value(4):
					if not collisionIsBumper or competingDistance <= priorityCollisionDistance:
						collisionIsBumper = true
						priorityCollisionDistance = competingDistance
						priorityCollisionIndex = i

				elif collider.get_collision_layer_value(2) and not collisionIsBumper:
					if not collisionIsPaddle or competingDistance <= priorityCollisionDistance:
						collisionIsPaddle = true
						priorityCollisionDistance = competingDistance
						priorityCollisionIndex = i
				
				elif collider.get_collision_layer_value(5) and not collisionIsBumper and not collisionIsPaddle:
					if competingDistance <= priorityCollisionDistance:
						priorityCollisionDistance = competingDistance
						priorityCollisionIndex = i

		if priorityCollisionIndex != -1:

			if collisionIsBumper:
				handleBumperCollision(priorityCollisionIndex)
			elif collisionIsPaddle:
				handlePaddleCollision(priorityCollisionIndex)
			else:
				handleWallCollision(priorityCollisionIndex)
			
			
			if priorityCollisionDistance > radius:
				var collisionPoint := shapeCaster.get_collision_point(priorityCollisionIndex)
				var destination := collisionPoint - (collisionPoint-global_position).normalized()*(radius+0.1)
				remainingDistance -= (global_position-destination).length()
				global_position = destination
			else:
				var collisionPoint := shapeCaster.get_collision_point(priorityCollisionIndex)
				global_position = collisionPoint - (collisionPoint-global_position).normalized()*(radius+0.1)

			direction = newDirection

			collisionsThisFrame += 1
			if collisionsThisFrame/delta > 1000:
				print("EXPLODE!")
				queue_free()
				return

		else:
			global_position += remainingDistance*direction
			remainingDistance = 0


func handleBumperCollision(i: int):
	print("Collided with bumper!")
	var bumper := shapeCaster.get_collider(i) as Bumper
	newDirection = shapeCaster.get_collision_normal(i)
	resetDecayingSpeed(baseSpeed)


func handlePaddleCollision(i: int):
	var paddle := shapeCaster.get_collider(i) as Paddle

	var normalAngle := shapeCaster.get_collision_normal(i).angle()
	var paddleAngle := paddle.global_rotation
	var topLeftCorner := paddle.global_position
	var distanceFromTopLeftCorner := (shapeCaster.get_collision_point(i) - topLeftCorner).length()
	var topRightCorner :=  paddle.global_position + paddle.width * Vector2.from_angle(paddleAngle)
	var distanceFromTopRightCorner := (shapeCaster.get_collision_point(i) - topRightCorner).length()
	var bottomLeftCorner := paddle.global_position + paddle.height * Vector2.from_angle(paddleAngle + PI/2)
	var distanceFromBottomLeftCorner := (shapeCaster.get_collision_point(i) - bottomLeftCorner).length()
	var bottomRightCorner := bottomLeftCorner + paddle.width * Vector2.from_angle(paddleAngle)
	var distanceFromBottomRightCorner := (shapeCaster.get_collision_point(i) - bottomRightCorner).length()
	var minDistance = min(
		distanceFromTopLeftCorner, distanceFromTopRightCorner,
		distanceFromBottomLeftCorner, distanceFromBottomRightCorner
	)

	if abs(angle_difference(normalAngle,paddleAngle-PI/2)) < 0.1:
		print("Hit top of paddle!")
		var centerRatio := (distanceFromTopLeftCorner - paddle.width/2)/(paddle.width/2)
		newDirection = Vector2.from_angle(normalAngle + PI * 3/8 * centerRatio)
	elif abs(angle_difference(normalAngle,paddleAngle+PI/2)) < 0.1:
		print("Hit bottom of paddle!")
		var centerRatio := (distanceFromBottomLeftCorner - paddle.width/2)/(paddle.width/2)
		newDirection = Vector2.from_angle(normalAngle - PI * 3/8 * centerRatio)
	elif minDistance == distanceFromTopLeftCorner:
		print("Hit left-top side of paddle")
		newDirection = Vector2.from_angle(paddleAngle - PI * 7/8)
		if paddle.direction == paddle.LEFT and paddle.speed > fullVelocity.length() * 1.1:
			resetDecayingSpeed(paddle.speed*1.25-baseSpeed)
	elif minDistance == distanceFromBottomLeftCorner:
		print("Hit left-bottom side of paddle")
		newDirection = Vector2.from_angle(paddleAngle + PI * 7/8)
		if paddle.direction == paddle.LEFT and paddle.speed > fullVelocity.length() * 1.1:
			resetDecayingSpeed(paddle.speed*1.25-baseSpeed)
	elif minDistance == distanceFromTopRightCorner:
		print("Hit right-top side of paddle")
		newDirection = Vector2.from_angle(paddleAngle - PI * 1/8)
		if paddle.direction == paddle.RIGHT and paddle.speed > fullVelocity.length() * 1.1:
			resetDecayingSpeed(paddle.speed*1.25-baseSpeed)
	elif minDistance == distanceFromBottomRightCorner:
		print("Hit right-bottom side of paddle")
		newDirection = Vector2.from_angle(paddleAngle + PI * 1/8)
		if paddle.direction == paddle.RIGHT and paddle.speed > fullVelocity.length() * 1.1:
			resetDecayingSpeed(paddle.speed*1.25-baseSpeed)
	else:
		print("Wat")


func handleWallCollision(i):
	print("Collided with wall")
	var wall := shapeCaster.get_collider(i) as Wall
	var normalVector := shapeCaster.get_collision_normal(i)
	newDirection = (-direction).rotated((-direction).angle_to(normalVector)*2)

	
