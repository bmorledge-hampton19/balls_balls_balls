class_name  BallManager
extends Node

@export var ballPrefab: PackedScene
@export var ballsControl: Control
var balls: Dictionary
var spawningBalls: Dictionary

@export var ballControllerPrefab: PackedScene
var playerBallRespawnTimers: Dictionary

@export var trailPrefab: PackedScene
@export var trailsCanvasGroup: CanvasGroup

@export var averageSpawnTime: float = 5
@export var spawnTimeDeviation: float = 2.5
@export var extraSpawnTimePerBall: float = 1

var random = RandomNumberGenerator.new()
var timeUntilNextSpawn: float = 0
var ballBehaviorWeightDict := {
	Ball.Behavior.IDLE : 0,
	Ball.Behavior.CONSTANT_LINEAR : 100,
	Ball.Behavior.ACCEL_LINEAR : 10,
	Ball.Behavior.CONSTANT_SPIRAL : 10,
	Ball.Behavior.ACCEL_SPIRAL : 10,
	Ball.Behavior.START_AND_STOP : 10,
	Ball.Behavior.START_AND_STOP_AND_CHANGE_DIRECTION : 10,
	Ball.Behavior.DRIFT : 10,
}
var ballBehaviorWeights: Array[float]
var erraticBehaviorProbability := 0.3

@export var averageSpawnSpeed: float = 50
@export var spawnSpeedDeviation: float = 10
@export var baseFadeInTime: float = 3
@export var additiveAcceleration: float = 1
@export var theBallScaleFactor: float = 0.5

@export var background: Background
@export var goalParticleEmitter: PackedScene
@export var explosionParticleEmitter: PackedScene
@export var particleEmittersControl: Control
@export var theBall: TheBall

@export var off := false

var burstSpawns: bool
@export var individualBurstSpawnTimer: Timer
var individualBurstSpawnCount: int
@export var burstActivationTimer: VariableTimer

func _ready():
	for ballBehavior in Ball.Behavior.values():
		if ballBehavior not in ballBehaviorWeightDict:
			ballBehaviorWeights.append(0)
		else:
			ballBehaviorWeights.append(ballBehaviorWeightDict[ballBehavior])


func _process(delta):
	
	if off: return

	timeUntilNextSpawn -= delta

	if timeUntilNextSpawn <= 0:
		if burstSpawns:
			individualBurstSpawnTimer.start()
			individualBurstSpawnCount = 0
			burstActivationTimer.start()
		else: spawnBall()
		timeUntilNextSpawn = averageSpawnTime
		timeUntilNextSpawn += randf_range(-spawnTimeDeviation, spawnTimeDeviation)
		timeUntilNextSpawn += extraSpawnTimePerBall*len(balls)

	var markedForErasure: Array
	for player in playerBallRespawnTimers:
		playerBallRespawnTimers[player] -= delta
		if playerBallRespawnTimers[player] <= 0:
			spawnBall(player)
			markedForErasure.append(player)
	for player in markedForErasure: playerBallRespawnTimers.erase(player)

	for ball in spawningBalls:
		ball.fadeInTimeRemaining -= delta
		if ball.fadeInTimeRemaining <= 0:
			if burstSpawns and ball.ballController == null: ball.modulate.a = 1
			else: activateBall(ball)
		else:
			ball.modulate.a = (ball.totalFadeInTime-ball.fadeInTimeRemaining)/ball.totalFadeInTime


func spawnBall(playerController: Player = null):
	var newBall: Ball = ballPrefab.instantiate()
	var newTrail: Trail = trailPrefab.instantiate()
	newBall.trail = newTrail
	balls[newBall] = null
	ballsControl.add_child(newBall)
	trailsCanvasGroup.add_child(newTrail)
	newBall.onBallInGoal.connect(onBallInGoal)
	newBall.onBallHitWall.connect(background.spawnBallArc)
	newBall.onBallExplosion.connect(explodeBall)

	newBall.baseSpeed = averageSpawnSpeed + randf_range(-spawnSpeedDeviation, spawnSpeedDeviation)
	newBall.baseSpeed *= 1+(theBall.radiusScale-1)*theBallScaleFactor
	if randi_range(0,1): newBall.baseSpeedDirection = Vector2.from_angle(randf_range(0.1,PI-.1))
	else: newBall.baseSpeedDirection = Vector2.from_angle(randf_range(0.1,PI-.1)*-1)
	newBall.additiveAcceleration = additiveAcceleration*theBall.radiusScale*theBallScaleFactor

	spawningBalls[newBall] = null
	var fadeInTime = baseFadeInTime / (1+(theBall.radiusScale-1)*theBallScaleFactor)
	newBall.totalFadeInTime = fadeInTime
	newBall.fadeInTimeRemaining = fadeInTime
	newBall.trail.hide()
	if burstSpawns: newBall.resetDecayingSpeed(100, 1)
	else: newBall.resetDecayingSpeed(10, 9999)
	newBall.behavior = Ball.Behavior.IDLE
	newBall.behaviorSpeed = -newBall.baseSpeed
	newBall.modulate.a = 0

	if playerController != null:
		var ballController: BallController = ballControllerPrefab.instantiate()
		ballController.player = playerController
		newBall.ballController = ballController
		newBall.radius = 10
	
	elif burstSpawns:
		individualBurstSpawnCount += 1
		if individualBurstSpawnCount >= 8:
			individualBurstSpawnTimer.stop()


func activateBall(ball: Ball):
	ball.modulate.a = 1
	ball.trail.show()
	ball.resetDecayingSpeed(ball.baseSpeed*0.5)

	if ball.ballController != null:
		ball.behavior = Ball.Behavior.PLAYER_CONTROLLED
		ball.baseSpeed = 0
		ball.additiveAcceleration = 0
		ball.multiplicativeAcceleration = 0
	else:
		ball.behavior = random.rand_weighted(ballBehaviorWeights) as Ball.Behavior
		if randf() < erraticBehaviorProbability: ball.behaviorIntensity = Ball.ERRATIC

	spawningBalls.erase(ball)

func activateAllBalls():
	for ball in spawningBalls.keys():
		activateBall(ball)


func deleteBall(ball: Ball):
	balls.erase(ball)
	spawningBalls.erase(ball)
	if ball.ballController != null:
		queuePlayerControlledBall(ball.ballController.player)
	ball.queue_free()

	timeUntilNextSpawn -= extraSpawnTimePerBall
	if len(balls) == 0: timeUntilNextSpawn = 0


func onBallInGoal(ball: Ball, team: Team):

	var particleEmitter: OneShotParticleEmitter = goalParticleEmitter.instantiate()
	particleEmittersControl.add_child(particleEmitter)
	particleEmitter.global_position = ball.global_position - ball.radius*Vector2.from_angle(team.rotation+PI/2)
	var localEmissionAngle := angle_difference(0,ball.fullVelocity.normalized().angle() + PI - team.rotation)
	localEmissionAngle = clampf(localEmissionAngle,-11.0/12.0*PI,-1.0/12.0*PI)
	particleEmitter.direction = Vector2.from_angle(localEmissionAngle+team.rotation)
	particleEmitter.color = team.color

	background.spawnBallExplosion(ball)
	ScreenShaker.addShake(10)
	deleteBall(ball)


func explodeBall(ball: Ball):
	var particleEmitter: OneShotParticleEmitter = explosionParticleEmitter.instantiate()
	particleEmittersControl.add_child(particleEmitter)
	particleEmitter.color = ball.teamColor.color
	particleEmitter.global_position = ball.global_position
	ScreenShaker.addShake(20)
	deleteBall(ball)

func explodeAllBalls():
	for ball in balls.keys():
		explodeBall(ball)


func prepForFinale(spawnDelay: float):
	explodeAllBalls()
	burstSpawns = true
	off = true
	averageSpawnTime *= 4
	timeUntilNextSpawn = spawnDelay
	theBallScaleFactor /= 4


func queuePlayerControlledBall(player: Player):
	playerBallRespawnTimers[player] = randf_range(5,10)