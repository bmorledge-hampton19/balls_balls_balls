class_name Ball
extends Area2D

enum {TOP, BOTTOM}

var currentTime: float = 0.0

@export var collisionShape2D: CollisionShape2D
@export var shapeCaster: ShapeCast2D
@export var teamColor: ColorRect
@export var ballSprite: TextureRect
@export var baseSpeed: float = 100
@export var additiveAcceleration: float = 0
@export var multiplicativeAcceleration: float = 1 # Note: Alongisde additive acceleration, framerate affects acceleration.
@export var baseSpeedDirection := Vector2(0,1)
# POTENTIAL OPTIMIZATION: Remove fullVelocity and direction get statements and add dedicated
# updateFullVelocity function, which is called more conservatively.
var fullVelocity: Vector2:
	get: return (
		baseSpeedDirection * (baseSpeed + decayingSpeed) +
		behaviorSpeed*(baseSpeedDirection.rotated(behaviorRotationalDeviation))
	)
var direction: Vector2:
	get:
		if fullVelocity.length() > 0.1: return fullVelocity.normalized()
		else: return baseSpeedDirection

@export var radius: float = 5.0:
	get: return radius
	set(value):
		radius = value
		(collisionShape2D.shape as CircleShape2D).radius = radius
		(shapeCaster.shape as CircleShape2D).radius = radius
		teamColor.position = Vector2(-radius*1.4, -radius*1.4)
		teamColor.size = Vector2(radius*2.8, radius*2.8)
		ballSprite.position = Vector2(-radius, -radius)
		ballSprite.size = Vector2(radius*2, radius*2)
		trail.width = radius*1.8

enum {SMOOTH, ERRATIC}
enum Behavior {
	IDLE,
	CONSTANT_LINEAR, ACCEL_LINEAR,
	CONSTANT_SPIRAL, ACCEL_SPIRAL,
	START_AND_STOP, START_AND_STOP_AND_CHANGE_DIRECTION,
	DRIFT,
	PLAYER_CONTROLLED
}
var behavior: Behavior = Behavior.CONSTANT_LINEAR
var behaviorIntensity: int

var behaviorState: int
var behaviorStateDuration: float
var behaviorStateTimeRemaining: float

var behaviorSpeed: float
var behaviorAcceleration: float
var behaviorRotationalDeviation: float
var behaviorRotationalVelocity: float
var behaviorRotationalAcceleration: float

var ballController: BallController:
	set(value):
		ballController = value
		add_child(ballController)
		move_child(ballController, 0)
		ballController.global_position = global_position
		updateColor(ballController.player.teamColor)
		ballSprite.texture = ballController.player.texture

func changeBehaviorState(newState: int, duration: float):
	behaviorState = newState
	behaviorStateTimeRemaining = duration
	behaviorStateDuration = duration

func resetBehavior():
	behaviorState = 0
	behaviorStateTimeRemaining = 0
	behaviorSpeed = 0
	behaviorAcceleration = 0
	behaviorRotationalDeviation = 0
	behaviorRotationalVelocity = 0
	behaviorRotationalAcceleration = 0

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

var lastPlayer: Player

func resetDecayingSpeed(newSpeed: float, duration: float = 2):
	decayingSpeedBase = newSpeed
	decayingSpeedDuration = duration
	decayingSpeedTimeRemaining = duration
	resetBehavior()

var totalFadeInTime: float
var fadeInTimeRemaining: float

@warning_ignore("unused_signal")
signal onBallInGoal(ball: Ball, team: Team)
signal onBallHitWall(ball: Ball, collisionPoint: Vector2)
signal onBallExplosion(ball: Ball)

var trail: Trail
var trailDragTime: float = 0

class PriorPoint:
	var position: Vector2
	var creationTime: float
	var isActive: bool
	var isCollision: bool
	var heading: Vector2
	func _init(p_position: Vector2, p_creationTime: float, p_isActive: bool, p_isCollision: bool, p_heading: Vector2):
		position = p_position
		creationTime = p_creationTime
		isActive = p_isActive
		isCollision = p_isCollision
		heading = p_heading

var priorPoints: Array[PriorPoint]

func updateColor(newColor: Color):
	teamColor.color = newColor
	if trail != null: trail.updateColor(newColor)
	if ballController != null: ballController.thrustParticleEmitter.color = newColor
	if powerupParticleEmitter != null: powerupParticleEmitter.color = newColor

var powerupType: PowerupManager.Type
var powerupParticleEmitter: CPUParticles2D:
	set(value):
		powerupParticleEmitter = value
		while powerupType == PowerupManager.Type.NONE: powerupType = PowerupManager.Type.values().pick_random()
		add_child(powerupParticleEmitter)
		move_child(powerupParticleEmitter,0)
		updateColor(teamColor.color)

var stuckToWhichPaddle: Paddle:
	set(value):
		stuckToWhichPaddle = value
		if stuckToWhichPaddle != null:
			stuckToWhichPaddle.stuckBalls.append(self)
var stuckCenterRatio: float
var stuckToTopOrBottom: int

var isClone: bool
var timeUntilClone: float


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _notification(what):
	if (what == NOTIFICATION_PREDELETE):
		if is_instance_valid(trail): trail.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):

	currentTime += delta
	timeUntilClone -= delta

	processBaseAcceleration(delta)

	processBehavior(delta)

	processMovement(delta)

	checkForGoals()

	if trail != null: processTrails(delta)


func processBaseAcceleration(delta):
	decayingSpeedTimeRemaining -= delta
	baseSpeed += additiveAcceleration*delta
	if multiplicativeAcceleration != 1: baseSpeed *= multiplicativeAcceleration**delta


func processBehavior(delta):

	behaviorStateTimeRemaining -= delta

	match behavior:

		Behavior.IDLE:
			if baseSpeed+behaviorSpeed > 0:
				behaviorSpeed -= baseSpeed/2*delta
			if baseSpeed+behaviorSpeed < 0:
				behaviorSpeed = -baseSpeed

		Behavior.CONSTANT_LINEAR:
			pass

		Behavior.ACCEL_LINEAR:
			# 0: stable
			# 1: accelerating
			# 2: constant speed
			if behaviorStateTimeRemaining <= 0:
				var duration: float
				var targetSpeed: float
				var newState: int

				if behaviorState == 0:
					newState = 1
					if behaviorIntensity == SMOOTH:
						duration = randf_range(3,5)
						if randi_range(0,1): targetSpeed = randf_range(baseSpeed*1.4, baseSpeed*1.6)
						else: targetSpeed = randf_range(baseSpeed*0.7, baseSpeed*0.85)
					elif behaviorIntensity == ERRATIC:
						duration = randf_range(1,3)
						if randi_range(0,1): targetSpeed = randf_range(baseSpeed*1.2, baseSpeed*2)
						else: targetSpeed = randf_range(baseSpeed*0.5, baseSpeed*0.9)

				if behaviorState == 1:
					newState = 2
					if behaviorIntensity == SMOOTH: duration = randf_range(5,7)
					elif behaviorIntensity == ERRATIC: duration = randf_range(3,7)

				elif behaviorState == 2:
					newState = 1
					if behaviorIntensity == SMOOTH:
						duration = randf_range(3,5)
						if behaviorSpeed < 0: targetSpeed = randf_range(baseSpeed*1.4, baseSpeed*1.6)
						else: targetSpeed = randf_range(baseSpeed*0.7, baseSpeed*0.85)
					elif behaviorIntensity == ERRATIC:
						duration = randf_range(1,3)
						if behaviorSpeed < 0: targetSpeed = randf_range(baseSpeed*1.2, baseSpeed*2)
						else: targetSpeed = randf_range(baseSpeed*0.5, baseSpeed*0.9)
				
				if newState == 2: behaviorAcceleration = 0
				else: behaviorAcceleration = (targetSpeed - (baseSpeed + behaviorSpeed)) / duration

				changeBehaviorState(newState, duration)


		Behavior.CONSTANT_SPIRAL:
			# 0: stable
			# 1: increasing spiral
			# 2: constant spiral
			if behaviorStateTimeRemaining <= 0:
				var duration: float
				var targetRotationalVelocity: float
				var targetBehaviorSpeed: float
				var newState: int

				if behaviorState == 0:
					newState = 1
					if behaviorIntensity == SMOOTH:
						duration = randf_range(3,5)
						targetBehaviorSpeed = randf_range(baseSpeed, baseSpeed*2)
						targetRotationalVelocity = randf_range(PI, 2*PI)
					elif behaviorIntensity == ERRATIC:
						duration = randf_range(1,3)
						targetBehaviorSpeed = randf_range(baseSpeed*2, baseSpeed*3)
						targetRotationalVelocity = randf_range(PI, 4*PI)
					if randi_range(0,1): targetRotationalVelocity *= -1
				
				elif behaviorState == 1 or behaviorState == 2:
					newState = 2
					duration = 69

				if newState == 2:
					behaviorAcceleration = 0
					behaviorRotationalAcceleration = 0
				else:
					behaviorAcceleration = (targetBehaviorSpeed - behaviorSpeed) / duration
					behaviorRotationalAcceleration = (targetRotationalVelocity - behaviorRotationalVelocity) / duration

				changeBehaviorState(newState, duration)


		Behavior.ACCEL_SPIRAL:
			# 0: stable
			# 1: increasing spiral
			# 2: constant spiral
			# 3: stabilizing
			if behaviorStateTimeRemaining <= 0:
				var duration: float
				var targetRotationalVelocity: float
				var targetBehaviorSpeed: float
				var newState: int

				if behaviorState == 0:
					newState = 1
					if behaviorIntensity == SMOOTH:
						duration = randf_range(3,5)
						targetBehaviorSpeed = randf_range(baseSpeed, baseSpeed*2)
						targetRotationalVelocity = randf_range(PI, PI*2)
					elif behaviorIntensity == ERRATIC:
						duration = randf_range(1,3)
						targetBehaviorSpeed = randf_range(baseSpeed*2, baseSpeed*3)
						targetRotationalVelocity = randf_range(PI, PI*4)
					if randi_range(0,1): targetRotationalVelocity *= -1
				
				elif behaviorState == 1:
					newState = 2
					if behaviorIntensity == SMOOTH: duration = randf_range(5,10)
					elif behaviorIntensity == ERRATIC: duration = randf_range(4,8)
				
				elif behaviorState == 2:
					newState = 3
					targetBehaviorSpeed = 0
					targetRotationalVelocity = 0
					if behaviorIntensity == SMOOTH: duration = randf_range(3,5)
					elif behaviorIntensity == ERRATIC: duration = randf_range(1,3)
				
				elif behaviorState == 3:
					newState = 0
					behaviorSpeed = 0
					behaviorRotationalVelocity = 0
					if behaviorIntensity == SMOOTH: duration = randf_range(2,4)
					elif behaviorIntensity == ERRATIC: duration = randf_range(1,3)

				if newState == 2 or newState == 0:
					behaviorAcceleration = 0
					behaviorRotationalAcceleration = 0
				else:
					behaviorAcceleration = (targetBehaviorSpeed - behaviorSpeed) / duration
					behaviorRotationalAcceleration = (targetRotationalVelocity - behaviorRotationalVelocity) / duration

				changeBehaviorState(newState, duration)


		Behavior.START_AND_STOP, Behavior.START_AND_STOP_AND_CHANGE_DIRECTION:
			# 0: stable
			# 1: braking
			# 2: full brakes
			# 3: releasing brakes
			if behaviorStateTimeRemaining <= 0:
				var duration: float
				var targetBehaviorSpeed: float
				var newState: int

				if behaviorState == 0:
					newState = 1
					targetBehaviorSpeed = -baseSpeed
					if behaviorIntensity == SMOOTH: duration = randf_range(3,5)
					elif behaviorIntensity == ERRATIC: duration = randf_range(1,3)

				elif behaviorState == 1:
					if baseSpeed + behaviorSpeed <= 0:
						newState = 2
						if behaviorIntensity == SMOOTH: duration = randf_range(5,7)
						elif behaviorIntensity == ERRATIC: duration = randf_range(3,7)
					else:
						newState = -1
						# Decrease behaviorAcceleration to help overtake baseSpeed?

				elif behaviorState == 2:
					newState = 3
					targetBehaviorSpeed = 0
					if behaviorIntensity == SMOOTH: duration = randf_range(3,5)
					elif behaviorIntensity == ERRATIC: duration = randf_range(1,3)
					if behavior == Behavior.START_AND_STOP_AND_CHANGE_DIRECTION:
						baseSpeedDirection = baseSpeedDirection.rotated(randf_range(0,2*PI))
				
				elif behaviorState == 3:
					newState = 0
					behaviorSpeed = 0
					if behaviorIntensity == SMOOTH: duration = randf_range(5,7)
					elif behaviorIntensity == ERRATIC: duration = randf_range(3,7)

				if newState != -1:
					if newState == 2: behaviorAcceleration = 0
					else: behaviorAcceleration = (targetBehaviorSpeed - behaviorSpeed) / duration

					changeBehaviorState(newState, duration)

			if behaviorState == 2: behaviorSpeed = -baseSpeed


		Behavior.DRIFT:
			# 0: stable
			# 1: increasing drift
			# 2: drifting
			# 3: stabilizing
			if behaviorStateTimeRemaining <= 0:
				var duration: float
				var targetBehaviorSpeed: float
				var newState: int

				if behaviorState == 0:

					newState = 1

					behaviorRotationalDeviation = randf_range(5*PI/8,7*PI/8)
					if randi_range(0,1): behaviorRotationalDeviation *= -1

					if behaviorIntensity == SMOOTH:
						duration = randf_range(2,3)
						targetBehaviorSpeed = randf_range(baseSpeed*1, baseSpeed*1.4)
					elif behaviorIntensity == ERRATIC:
						duration = randf_range(1,2)
						targetBehaviorSpeed = randf_range(baseSpeed*1.4, baseSpeed*2)

				if behaviorState == 1:

					newState = 2
					if behaviorIntensity == SMOOTH: duration = randf_range(2,3)
					elif behaviorIntensity == ERRATIC: duration = randf_range(1,2)
				
				if behaviorState == 2:
					
					newState = 3
					targetBehaviorSpeed = 0
					if behaviorIntensity == SMOOTH: duration = randf_range(2,3)
					elif behaviorIntensity == ERRATIC: duration = randf_range(1,2)

				if behaviorState == 3:

					behaviorSpeed = 0
					newState = 0
					if behaviorIntensity == SMOOTH: duration = randf_range(2,3)
					elif behaviorIntensity == ERRATIC: duration = randf_range(1,2)

				if newState == 1 or newState == 3:
					behaviorAcceleration = (targetBehaviorSpeed - behaviorSpeed) / duration
				else:
					behaviorAcceleration = 0

				changeBehaviorState(newState, duration)


		Behavior.PLAYER_CONTROLLED:
			var behaviorVelocity := behaviorSpeed*(baseSpeedDirection.rotated(behaviorRotationalDeviation))
			behaviorVelocity += ballController.thrustDirection*ballController.thurstAcceleration*delta
			behaviorSpeed = behaviorVelocity.length()
			behaviorRotationalDeviation = baseSpeedDirection.angle_to(behaviorVelocity)


	behaviorSpeed += behaviorAcceleration*delta
	behaviorRotationalVelocity += behaviorRotationalAcceleration*delta
	behaviorRotationalDeviation += behaviorRotationalVelocity*delta
	if behaviorRotationalDeviation > 2*PI: behaviorRotationalDeviation -= 2*PI
	elif behaviorRotationalDeviation < 2*PI: behaviorRotationalDeviation += 2*PI


func processMovement(delta: float):

	if stuckToWhichPaddle != null: return

	var collisionsThisFrame = 0

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
						collisionIsPaddle = false
						priorityCollisionDistance = competingDistance
						priorityCollisionIndex = i

				elif collider.get_collision_layer_value(2) and not collisionIsBumper:
					if not collisionIsPaddle or competingDistance <= priorityCollisionDistance:
						collisionIsPaddle = true
						priorityCollisionDistance = competingDistance
						priorityCollisionIndex = i
				
				elif collider.get_collision_layer_value(5) and not collisionIsBumper and not collisionIsPaddle:
					if competingDistance <= priorityCollisionDistance and isValidWallCollision(i):
						priorityCollisionDistance = competingDistance
						priorityCollisionIndex = i

		if priorityCollisionIndex != -1:

			if collisionIsBumper:
				handleBumperCollision(priorityCollisionIndex)
			elif collisionIsPaddle:
				handlePaddleCollision(priorityCollisionIndex)
				if stuckToWhichPaddle != null:
					return
			else:
				handleWallCollision(priorityCollisionIndex)

			# NOTE: This is helpful if an object has clipped inside a ball but is not guaranteed to avoid future collisions.
			# 		For most use-cases, it's fine, but the innaccuracy is worth noting. (Really, my collision system
			#		just isn't quite sophisticated enough to handle collisions between two moving objects... How is
			#		this achieved normally? It sounds HARD...)
			var collisionPoint := shapeCaster.get_collision_point(priorityCollisionIndex)
			var destination := collisionPoint + collisionNormal*(radius+0.49)
			if priorityCollisionDistance >= radius:
				remainingDistance -= (global_position-destination).length()
			global_position = destination

			# Compensates for behaviorRotationalDeviation
			baseSpeedDirection = baseSpeedDirection.rotated(direction.angle_to(newDirection))
			assert(
				abs((newDirection-direction).length()) < 0.01,
				"New Direction incorrect. Expected: " + str(newDirection) + " Got: " + str(direction)
			)

			if trail != null:
				if len(priorPoints) > 1 and not priorPoints[-1].isCollision:
					trail.set_point_position(len(trail.points)-1, position)
					priorPoints[-1].isActive = false
				else: trail.add_point(position)
				priorPoints.append(PriorPoint.new(position, currentTime, true, true, direction))

			collisionsThisFrame += 1
			if collisionsThisFrame >= 2: print(str(collisionsThisFrame) + " collisions!")
			if collisionsThisFrame > 10 and collisionsThisFrame/delta > 100:
				for goal in goalsEncompassing: goal.area_exited.emit(self)
				onBallExplosion.emit(self)
				return
			
			if collisionIsPaddle: 
				var paddle: Paddle = shapeCaster.get_collider(priorityCollisionIndex).get_parent()
				if (paddle.powerupDurations[PowerupManager.Type.DUPLICATOR]
					and not paddle.powerupDurations[PowerupManager.Type.STICKY]):
					PowerupManager.cloneBall(self)
					paddle.powerupDurations[PowerupManager.Type.DUPLICATOR] = (
						maxf(paddle.powerupDurations[PowerupManager.Type.DUPLICATOR]-0.2,0)
					)

		else:
			global_position += remainingDistance*direction
			remainingDistance = 0


func handleBumperCollision(i: int):
	# print("Collided with bumper!")
	var bumper := shapeCaster.get_collider(i).get_parent() as Bumper
	bumper.pulse()
	collisionNormal = shapeCaster.get_collision_normal(i)
	newDirection = collisionNormal
	if ballController == null: resetDecayingSpeed(baseSpeed)
	else:
		var lingeringBehaviorSpeed = behaviorSpeed * 0.5
		resetDecayingSpeed(fullVelocity.length())
		behaviorSpeed = lingeringBehaviorSpeed


func handlePaddleCollision(i: int):
	var paddleArea = shapeCaster.get_collider(i) as Area2D
	var paddle := paddleArea.get_parent() as Paddle
	collisionNormal = shapeCaster.get_collision_normal(i)
	var collisionPoint := shapeCaster.get_collision_point(i)

	if ballController == null: 
		updateColor(paddle.team.color)
		ballSprite.texture = paddle.player.texture
	lastPlayer = paddle.player

	if not paddle.spinning: handleStaticPaddleCollision(collisionPoint, paddle)
	else: handleSpinningPaddleCollision(collisionPoint, paddle, paddleArea)

func handleStaticPaddleCollision(collisionPoint: Vector2, paddle: Paddle):

	var normalAngle := collisionNormal.angle()
	var paddleAngle := paddle.global_rotation
	var topLeftCorner := paddle.global_position
	var distanceFromTopLeftCorner := (collisionPoint - topLeftCorner).length()
	var topRightCorner :=  paddle.global_position + paddle.width * Vector2.from_angle(paddleAngle)
	var distanceFromTopRightCorner := (collisionPoint - topRightCorner).length()
	var bottomLeftCorner := paddle.global_position + paddle.height * Vector2.from_angle(paddleAngle + PI/2)
	var distanceFromBottomLeftCorner := (collisionPoint - bottomLeftCorner).length()
	var bottomRightCorner := bottomLeftCorner + paddle.width * Vector2.from_angle(paddleAngle)
	var distanceFromBottomRightCorner := (collisionPoint - bottomRightCorner).length()
	var paddleWidth := (topRightCorner-topLeftCorner).length()
	var minDistance = min(
		distanceFromTopLeftCorner, distanceFromTopRightCorner,
		distanceFromBottomLeftCorner, distanceFromBottomRightCorner
	)

	if abs(angle_difference(normalAngle,paddleAngle-PI/2)) < 0.1:
		print("Hit top of paddle!")
		var centerRatio := (distanceFromTopLeftCorner - paddleWidth/2)/(paddleWidth/2)
		if paddle.powerupDurations[PowerupManager.Type.STICKY]:
			stuckToWhichPaddle = paddle
			stuckCenterRatio = centerRatio
			stuckToTopOrBottom = TOP
			resetDecayingSpeed(0)
		else:
			if paddle.powerupDurations[PowerupManager.Type.BALL_BOOSTER] and decayingSpeed < baseSpeed:
				resetDecayingSpeed(baseSpeed*2, 5.0)
			newDirection = Vector2.from_angle(normalAngle + PI * 3/8 * centerRatio)
	elif abs(angle_difference(normalAngle,paddleAngle+PI/2)) < 0.1:
		print("Hit bottom of paddle!")
		var centerRatio := (distanceFromBottomLeftCorner - paddleWidth/2)/(paddleWidth/2)
		if paddle.powerupDurations[PowerupManager.Type.STICKY]:
			stuckToWhichPaddle = paddle
			stuckCenterRatio = centerRatio
			stuckToTopOrBottom = BOTTOM
			resetDecayingSpeed(0)
		else:
			if paddle.powerupDurations[PowerupManager.Type.BALL_BOOSTER] and decayingSpeed < baseSpeed:
				resetDecayingSpeed(baseSpeed*2, 5.0)
			newDirection = Vector2.from_angle(normalAngle - PI * 3/8 * centerRatio)
	elif minDistance == distanceFromTopLeftCorner:
		print("Hit left-top side of paddle")
		newDirection = Vector2.from_angle(paddleAngle - PI * 7/8)
		if paddle.direction == paddle.LEFT:
			if baseSpeed < paddle.speed: resetDecayingSpeed((paddle.speed*1.1-baseSpeed)*paddle.ballBoost)
			else: resetDecayingSpeed(paddle.speed*.1*paddle.ballBoost)
		elif paddle.powerupDurations[PowerupManager.Type.BALL_BOOSTER] and decayingSpeed < baseSpeed:
			resetDecayingSpeed(baseSpeed, 5.0)
	elif minDistance == distanceFromBottomLeftCorner:
		print("Hit left-bottom side of paddle")
		newDirection = Vector2.from_angle(paddleAngle + PI * 7/8)
		if paddle.direction == paddle.LEFT:
			if baseSpeed < paddle.speed: resetDecayingSpeed((paddle.speed*1.1-baseSpeed)*paddle.ballBoost)
			else: resetDecayingSpeed(paddle.speed*.1*paddle.ballBoost)
		elif paddle.powerupDurations[PowerupManager.Type.BALL_BOOSTER] and decayingSpeed < baseSpeed:
			resetDecayingSpeed(baseSpeed, 5.0)
	elif minDistance == distanceFromTopRightCorner:
		print("Hit right-top side of paddle")
		newDirection = Vector2.from_angle(paddleAngle - PI * 1/8)
		if paddle.direction == paddle.RIGHT:
			if baseSpeed < paddle.speed: resetDecayingSpeed((paddle.speed*1.1-baseSpeed)*paddle.ballBoost)
			else: resetDecayingSpeed(paddle.speed*.1*paddle.ballBoost)
		elif paddle.powerupDurations[PowerupManager.Type.BALL_BOOSTER] and decayingSpeed < baseSpeed:
			resetDecayingSpeed(baseSpeed, 5.0)
	elif minDistance == distanceFromBottomRightCorner:
		print("Hit right-bottom side of paddle")
		newDirection = Vector2.from_angle(paddleAngle + PI * 1/8)
		if paddle.direction == paddle.RIGHT:
			if baseSpeed < paddle.speed: resetDecayingSpeed((paddle.speed*1.1-baseSpeed)*paddle.ballBoost)
			else: resetDecayingSpeed(paddle.speed*.1*paddle.ballBoost)
		elif paddle.powerupDurations[PowerupManager.Type.BALL_BOOSTER] and decayingSpeed < baseSpeed:
			resetDecayingSpeed(baseSpeed, 5.0)
	else:
		print("Wat")


func handleSpinningPaddleCollision(collisionPoint: Vector2, paddle: Paddle, paddleArea: Area2D):

	var localCollisionPoint = paddleArea.to_local(collisionPoint)
	var paddlePointVelocity := Vector2.ZERO
	if (
		(paddle.clockwiseSpin and (localCollisionPoint.x > 0) == (localCollisionPoint.y > 0))
		or
		(not paddle.clockwiseSpin and (localCollisionPoint.x < 0) == (localCollisionPoint.y > 0))
		and
		abs(paddleArea.to_local(global_position).x) < paddle.width/2
	):

		paddlePointVelocity = abs(localCollisionPoint.x)*PI/paddle.spinDuration*collisionNormal
		if paddle.direction == paddle.RIGHT:
			paddlePointVelocity += paddle.speed*Vector2.from_angle(paddle.global_rotation)
		elif paddle.direction == paddle.LEFT:
			paddlePointVelocity += paddle.speed*Vector2.from_angle(paddle.global_rotation)*-1
	
	else:
		
		if paddle.direction == paddle.RIGHT:
			paddlePointVelocity += paddle.speed*Vector2.from_angle(paddle.global_rotation)
		elif paddle.direction == paddle.LEFT:
			paddlePointVelocity += paddle.speed*Vector2.from_angle(paddle.global_rotation)*-1
		newDirection = (-direction).rotated((-direction).angle_to(collisionNormal)*2)

	if (
		paddlePointVelocity != Vector2.ZERO and
		abs(angle_difference(paddlePointVelocity.angle(), collisionNormal.angle())) <= PI/2
	):
		newDirection = ((paddlePointVelocity + fullVelocity.length()*collisionNormal)/2).normalized()
		if baseSpeed < paddlePointVelocity.length():
			resetDecayingSpeed((paddlePointVelocity.length()*1.1-baseSpeed)*paddle.ballBoost, 8)
		else:
			resetDecayingSpeed(paddlePointVelocity.length()*.1*paddle.ballBoost, 8)
	else:
		newDirection = (-direction).rotated((-direction).angle_to(collisionNormal)*2)


func unstick():
	
	reorientBallToStuckPaddle(false)
	var paddleAngle = stuckToWhichPaddle.global_rotation

	if stuckToTopOrBottom == TOP:
		newDirection = Vector2.from_angle(paddleAngle-PI/2 + PI * 3/8 * stuckCenterRatio)
	elif stuckToTopOrBottom == BOTTOM:
		newDirection = Vector2.from_angle(paddleAngle+PI/2 - PI * 3/8 * stuckCenterRatio)
	baseSpeedDirection = baseSpeedDirection.rotated(direction.angle_to(newDirection))

	if stuckToWhichPaddle.powerupDurations[PowerupManager.Type.BALL_BOOSTER]:
		resetDecayingSpeed(baseSpeed*2, 5.0)
	else:
		resetDecayingSpeed(baseSpeed*0.5, 3.0)

	if stuckToWhichPaddle.powerupDurations[PowerupManager.Type.DUPLICATOR]:
		PowerupManager.cloneBall(self)

	stuckToWhichPaddle = null


func reorientBallToStuckPaddle(withJitter := true):

	var paddleLocalPosition := Vector2(stuckToWhichPaddle.width/2+stuckToWhichPaddle.width/2*(stuckCenterRatio), -radius-0.49)
	if stuckToTopOrBottom == BOTTOM:
		paddleLocalPosition.y += stuckToWhichPaddle.height + radius*2 + 0.98
	if withJitter: paddleLocalPosition += stuckToWhichPaddle.colorPosOffset
	global_position = stuckToWhichPaddle.to_global(paddleLocalPosition)


func isValidWallCollision(i):
	var wall := shapeCaster.get_collider(i).get_parent() as Wall
	var normalAngle := wall.rotation
	var collidingWithMainFace: bool = (
		abs(abs(angle_difference(shapeCaster.get_collision_normal(i).angle(),normalAngle))-PI/2) < PI/4
	)
	return collidingWithMainFace


func handleWallCollision(i):
	# print("Collided with wall")
	var wall := shapeCaster.get_collider(i).get_parent() as Wall
	var normalAngle := wall.rotation
	if wall.flipped: normalAngle += PI
	normalAngle -= PI/2
	onBallHitWall.emit(self, shapeCaster.get_collision_point(i))
	# Not sure why this was here in the first place? I think it's unnecessary and also kinda wrong.
	# if abs(angle_difference(direction.angle_to(Vector2(0,1)), normalAngle)) < PI/2:
	# 	normalAngle += PI
	if abs(angle_difference(shapeCaster.get_collision_normal(i).angle(), normalAngle)) < PI/16:
		collisionNormal = Vector2.from_angle(normalAngle)
		# print("Normal wall collision")
	else:
		collisionNormal = shapeCaster.get_collision_normal(i)
		# print("FUNKY wall collision! (Probably a corner)")
	newDirection = (-direction).rotated((-direction).angle_to(collisionNormal)*2)

	
func checkForGoals():

	shapeCaster.target_position = shapeCaster.position
	shapeCaster.force_shapecast_update()
	var currentGoals: Array[Area2D] = []

	for i in len(shapeCaster.collision_result):
		var collider := shapeCaster.get_collider(i) as Area2D
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


func processTrails(delta: float):
	
	if decayingSpeedBase == 0: trailDragTime = 0
	else: trailDragTime = sqrt(decayingSpeed / decayingSpeedBase / 4)

	if trailDragTime <= delta:
		priorPoints.clear()
		trail.clear_points()
	else:
		var firstValidPointPos := 0
		for point in priorPoints:
			if currentTime - point.creationTime > trailDragTime:
				if point.isActive and firstValidPointPos != 0: trail.remove_point(0)
				firstValidPointPos += 1
			else:
				if firstValidPointPos == 0: break
				if point.isActive: trail.remove_point(0)
				else: trail.set_point_position(0, point.position) 
				break

		if priorPoints: priorPoints = priorPoints.slice(firstValidPointPos)

		priorPoints.append(PriorPoint.new(position, currentTime, true, false, direction))
		if (
			len(priorPoints) > 2 and
			not priorPoints[-2].isCollision and
			abs((priorPoints[-2].heading - priorPoints[-1].heading).length()) < 0.0001
		):
			trail.set_point_position(len(trail.points)-1, position)
			priorPoints[-2].isActive = false
		else: trail.add_point(position)
