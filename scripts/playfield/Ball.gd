class_name Ball
extends Area2D

var currentTime: float = 0.0

@export var collisionShape2D: CollisionShape2D
@export var shapeCaster: ShapeCast2D
@export var teamColor: ColorRect
@export var ballSprite: TextureRect
@export var baseSpeed: float = 100
@export var additiveAcceleration: float = 0
@export var multiplicativeAcceleration: float = 1 # Note: Alongisde additive acceleration, framerate affects acceleration.
@export var direction := Vector2(0,1)
var fullVelocity: Vector2:
	get: return direction * (baseSpeed + decayingSpeed)
var radius: float = 5.0:
	get: return radius
	set(value):
		radius = value
		(collisionShape2D.shape as CircleShape2D).radius = radius - 0.1
		(shapeCaster.shape as CircleShape2D).radius = radius - 0.1
		teamColor.position = Vector2(-radius*1.4, -radius*1.4)
		teamColor.size = Vector2(radius*2.8, radius*2.8)
		ballSprite.position = Vector2(-radius, -radius)
		ballSprite.size = Vector2(radius*2, radius*2)
		trail.width = radius

var decayingSpeedBase: float = 0
var decayingSpeed: float:
	get: 
		if decayingSpeedTimeRemaining <= 0: return 0
		else: return decayingSpeedBase*(decayingSpeedTimeRemaining/decayingSpeedDuration)
var decayingSpeedDuration: float
var decayingSpeedTimeRemaining: float

var collisionNormal: Vector2
var newDirection: Vector2

var goalsEncompassing: Array[Area2D]
var inGoal: bool:
	get: return len(goalsEncompassing) > 0

func resetDecayingSpeed(newSpeed: float, duration: float = 2):
	decayingSpeedBase = newSpeed
	decayingSpeedDuration = duration
	decayingSpeedTimeRemaining = duration

signal onBallInGoal(ball: Ball)

var trail: Trail
var time

class PriorPoint:
	var position: Vector2
	var creationTime: float
	var isActive: bool
	var isCollision: bool
	func _init(p_position: Vector2, p_creationTime: float, p_isActive: bool, p_isCollision: bool):
		position = p_position
		creationTime = p_creationTime
		isActive = p_isActive
		isCollision = p_isCollision

var priorPoints: Array[PriorPoint]	
var timeSinceLastTrailUpdate: float

func updateColor(newColor: Color):
	teamColor.color = newColor
	if trail != null: trail.updateColor(newColor)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _notification(what):
	if (what == NOTIFICATION_PREDELETE):
		if is_instance_valid(trail): trail.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):

	currentTime += delta

	processMovement(delta)
	
	checkForGoals()

	if trail != null: processTrails()


func processMovement(delta: float):

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
			
			var collisionPoint := shapeCaster.get_collision_point(priorityCollisionIndex)
			var destination := collisionPoint + shapeCaster.get_collision_normal(priorityCollisionIndex)*(radius+0.1)
			if priorityCollisionDistance >= radius:
				remainingDistance -= (global_position-destination).length()
			global_position = destination

			direction = newDirection
			print(newDirection)

			if trail != null:
				if len(priorPoints) > 1 and not priorPoints[-1].isCollision:
					trail.set_point_position(len(trail.points)-1, position)
					priorPoints[-1].isActive = false
				else: trail.add_point(position)
				priorPoints.append(PriorPoint.new(position, currentTime, true, true))

			collisionsThisFrame += 1
			if collisionsThisFrame > 2: print(str(collisionsThisFrame) + " collisions!")
			if collisionsThisFrame/delta > 1000:
				print("EXPLODE!")
				for goal in goalsEncompassing: goal.area_exited.emit(self)
				queue_free()
				return

		else:
			global_position += remainingDistance*direction
			remainingDistance = 0


func handleBumperCollision(i: int):
	print("Collided with bumper!")
	var _bumper := shapeCaster.get_collider(i).get_parent() as Bumper
	collisionNormal = shapeCaster.get_collision_normal(i)
	newDirection = collisionNormal
	resetDecayingSpeed(baseSpeed)


func handlePaddleCollision(i: int):
	var paddle := shapeCaster.get_collider(i) as Paddle

	collisionNormal = shapeCaster.get_collision_normal(i)
	var normalAngle := collisionNormal.angle()
	var paddleAngle := paddle.global_rotation
	var topLeftCorner := paddle.global_position
	var distanceFromTopLeftCorner := (shapeCaster.get_collision_point(i) - topLeftCorner).length()
	var topRightCorner :=  paddle.global_position + paddle.width * Vector2.from_angle(paddleAngle)
	var distanceFromTopRightCorner := (shapeCaster.get_collision_point(i) - topRightCorner).length()
	var bottomLeftCorner := paddle.global_position + paddle.height * Vector2.from_angle(paddleAngle + PI/2)
	var distanceFromBottomLeftCorner := (shapeCaster.get_collision_point(i) - bottomLeftCorner).length()
	var bottomRightCorner := bottomLeftCorner + paddle.width * Vector2.from_angle(paddleAngle)
	var distanceFromBottomRightCorner := (shapeCaster.get_collision_point(i) - bottomRightCorner).length()
	var paddleWidth := (topRightCorner-topLeftCorner).length()
	var minDistance = min(
		distanceFromTopLeftCorner, distanceFromTopRightCorner,
		distanceFromBottomLeftCorner, distanceFromBottomRightCorner
	)

	if abs(angle_difference(normalAngle,paddleAngle-PI/2)) < 0.1:
		print("Hit top of paddle!")
		var centerRatio := (distanceFromTopLeftCorner - paddleWidth/2)/(paddleWidth/2)
		print(centerRatio)
		newDirection = Vector2.from_angle(normalAngle + PI * 3/8 * centerRatio)
	elif abs(angle_difference(normalAngle,paddleAngle+PI/2)) < 0.1:
		print("Hit bottom of paddle!")
		var centerRatio := (distanceFromBottomLeftCorner - paddleWidth/2)/(paddleWidth/2)
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
	var wall := shapeCaster.get_collider(i).get_parent() as Wall
	var normalAngle := wall.rotation
	if abs(angle_difference(direction.angle_to(Vector2(0,1)), normalAngle)) < PI/2:
		normalAngle += PI
	collisionNormal = Vector2.from_angle(normalAngle-PI/2)
	print(collisionNormal)
	newDirection = (-direction).rotated((-direction).angle_to(collisionNormal)*2)

	
func checkForGoals():

	shapeCaster.target_position = shapeCaster.position
	shapeCaster.force_shapecast_update()
	var currentGoals: Array[Area2D] = []

	for i in len(shapeCaster.collision_result):
		var collider := shapeCaster.get_collider(i) as Area2D
		print(collider)
		if collider.get_collision_layer_value(3):
			currentGoals.append(collider)

	for goal in goalsEncompassing:
		if goal not in currentGoals:
			goal.area_exited.emit(self)
			goalsEncompassing.erase(goal)

	for goal in currentGoals:
		if goal not in goalsEncompassing:
			goal.area_entered.emit(self)
			goalsEncompassing.append(goal)


func processTrails():
	
	var firstValidPointPos := 0
	for point in priorPoints:
		if currentTime - point.creationTime > 0.5:
			if point.isActive and firstValidPointPos != 0: trail.remove_point(0)
			firstValidPointPos += 1
		else:
			if firstValidPointPos == 0: break
			if point.isActive: trail.remove_point(0)
			else: trail.set_point_position(0, point.position) 
			break

	if priorPoints: priorPoints = priorPoints.slice(firstValidPointPos)

	priorPoints.append(PriorPoint.new(position, currentTime, true, false))
	if len(priorPoints) > 2 and not priorPoints[-2].isCollision:
		trail.set_point_position(len(trail.points)-1, position)
		priorPoints[-2].isActive = false
	else: trail.add_point(position)
