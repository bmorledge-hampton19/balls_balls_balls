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

@export var anglerParticleEmitterPrefab: PackedScene
@export var spinnerParticleEmitterPrefab: PackedScene
@export var sleeperParticleEmitterPrefab: PackedScene
@export var drifterParticleEmitterPrefab: PackedScene

var averageSpawnTime: float
var spawnTimeDeviation: float:
	get: return averageSpawnTime / 2
var extraSpawnTimePerBall: float:
	get: return averageSpawnTime / 5

var random = RandomNumberGenerator.new()
var timeUntilNextSpawn: float = 0
var ballBehaviorWeightDict := {
	Ball.Behavior.IDLE : 0,
	Ball.Behavior.CONSTANT_LINEAR : 100,
	Ball.Behavior.ANGLER : 10,
	Ball.Behavior.CONSTANT_SPIRAL : 5,
	Ball.Behavior.ACCEL_SPIRAL : 5,
	Ball.Behavior.START_AND_STOP : 5,
	Ball.Behavior.START_AND_STOP_AND_CHANGE_DIRECTION : 5,
	Ball.Behavior.DRIFT : 10,
}
var ballBehaviorWeights: Array[float]
var erraticBehaviorProbability := 0.3

var averageSpawnSpeed: float
var spawnSpeedDeviation: float:
	get: return averageSpawnSpeed / 5
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

	PowerupManager.ballManager = self
	PowerupManager.particleControl = particleEmittersControl

	averageSpawnSpeed = Settings.getSettingValue(Settings.Setting.BALL_SPEED)

	averageSpawnTime = 1.0/Settings.getSettingValue(Settings.Setting.SPAWN_RATE)

	ballBehaviorWeightDict[Ball.Behavior.ANGLER] = \
		Settings.getSettingValue(Settings.Setting.ANGLER_SPAWN_RATE)
	ballBehaviorWeightDict[Ball.Behavior.CONSTANT_SPIRAL] = \
		Settings.getSettingValue(Settings.Setting.SPIRALING_SPAWN_RATE)/2.0
	ballBehaviorWeightDict[Ball.Behavior.ACCEL_SPIRAL] = \
		Settings.getSettingValue(Settings.Setting.SPIRALING_SPAWN_RATE)/2.0
	ballBehaviorWeightDict[Ball.Behavior.START_AND_STOP] = \
		Settings.getSettingValue(Settings.Setting.STOP_AND_START_SPAWN_RATE)/2.0
	ballBehaviorWeightDict[Ball.Behavior.START_AND_STOP_AND_CHANGE_DIRECTION] = \
		Settings.getSettingValue(Settings.Setting.STOP_AND_START_SPAWN_RATE)/2.0
	ballBehaviorWeightDict[Ball.Behavior.DRIFT] = \
		Settings.getSettingValue(Settings.Setting.DRIFTER_SPAWN_RATE)

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
		for ball in balls:
			if ball.ballController == null: timeUntilNextSpawn += extraSpawnTimePerBall
		if burstSpawns: timeUntilNextSpawn += burstActivationTimer.wait_time

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

	newBall.radius = Settings.getSettingValue(Settings.Setting.BALL_SIZE)
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
		newBall.radius += 5
	
	elif burstSpawns:
		individualBurstSpawnCount += 1
		if individualBurstSpawnCount >= 8:
			individualBurstSpawnTimer.stop()

	AudioManager.playSpawnBall()


func activateBall(ball: Ball, volumeMod := 1.0):
	ball.modulate.a = 1
	ball.trail.show()
	ball.resetDecayingSpeed(ball.baseSpeed*0.4, 1)

	if ball.ballController != null:
		ball.behavior = Ball.Behavior.PLAYER_CONTROLLED
		ball.baseSpeed = 0
		ball.additiveAcceleration = 0
		ball.multiplicativeAcceleration = 0
	else:
		ball.behavior = random.rand_weighted(ballBehaviorWeights) as Ball.Behavior
		match ball.behavior:
			Ball.Behavior.ANGLER:
				ball.behaviorParticleEmitter = anglerParticleEmitterPrefab.instantiate()
			Ball.Behavior.ACCEL_SPIRAL, Ball.Behavior.CONSTANT_SPIRAL:
				ball.behaviorParticleEmitter = spinnerParticleEmitterPrefab.instantiate()
			Ball.Behavior.START_AND_STOP, Ball.Behavior.START_AND_STOP_AND_CHANGE_DIRECTION:
				ball.behaviorParticleEmitter = sleeperParticleEmitterPrefab.instantiate()
			Ball.Behavior.DRIFT:
				ball.behaviorParticleEmitter = drifterParticleEmitterPrefab.instantiate()

		var behaviorIntensity = Settings.getSettingValue(Settings.Setting.BEHAVIOR_INTENSITY)
		if behaviorIntensity == Settings.ERRATIC: ball.behaviorIntensity = Ball.ERRATIC
		elif behaviorIntensity == Settings.MIXED:
			if randf() < erraticBehaviorProbability: ball.behaviorIntensity = Ball.ERRATIC

	spawningBalls.erase(ball)

	AudioManager.playActivateBall(ball.behavior, volumeMod)

func activateAllBalls():
	for ball in spawningBalls.keys():
		activateBall(ball, 0.25)


func cloneBall(parent: Ball):
	if len(balls) > 200 or parent.isClone or parent.timeUntilClone > 0: return # Exponential growth can be crazy!!

	var newBall: Ball = ballPrefab.instantiate()
	var newTrail: Trail = trailPrefab.instantiate()
	newBall.trail = newTrail
	balls[newBall] = null
	ballsControl.add_child(newBall)
	trailsCanvasGroup.add_child(newTrail)
	newBall.onBallInGoal.connect(onBallInGoal)
	newBall.onBallHitWall.connect(background.spawnBallArc)
	newBall.onBallExplosion.connect(explodeBall)

	newBall.global_position = parent.global_position
	newBall.radius = parent.radius
	newBall.baseSpeed = parent.baseSpeed
	if randi_range(0,1): newBall.baseSpeedDirection = parent.baseSpeedDirection.rotated(randf_range(PI/16,PI/8))
	else: newBall.baseSpeedDirection = parent.baseSpeedDirection.rotated(-randf_range(PI/16,PI/8))
	newBall.additiveAcceleration = parent.additiveAcceleration

	newBall.behavior = parent.behavior
	newBall.behaviorIntensity = parent.behaviorIntensity
	match newBall.behavior:
		Ball.Behavior.ANGLER:
			newBall.behaviorParticleEmitter = anglerParticleEmitterPrefab.instantiate()
		Ball.Behavior.ACCEL_SPIRAL, Ball.Behavior.CONSTANT_SPIRAL:
			newBall.behaviorParticleEmitter = spinnerParticleEmitterPrefab.instantiate()
		Ball.Behavior.START_AND_STOP, Ball.Behavior.START_AND_STOP_AND_CHANGE_DIRECTION:
			newBall.behaviorParticleEmitter = sleeperParticleEmitterPrefab.instantiate()
		Ball.Behavior.DRIFT:
			newBall.behaviorParticleEmitter = drifterParticleEmitterPrefab.instantiate()

	newBall.updateColor(parent.teamColor.color)
	newBall.ballSprite.texture = parent.ballSprite.texture
	newBall.lastPlayer = parent.lastPlayer

	if parent.ballController != null:
		var ballController: BallController = ballControllerPrefab.instantiate()
		ballController.player = parent.ballController.player
		newBall.ballController = ballController

	newBall.isClone = true
	parent.timeUntilClone = 0.5


func deleteBall(ball: Ball):
	balls.erase(ball)
	spawningBalls.erase(ball)
	if ball.ballController != null:
		queuePlayerControlledBall(ball.ballController.player)
	if ball.stuckToWhichPaddle != null: ball.stuckToWhichPaddle.stuckBalls.erase(ball)
	if ball.ballController == null: timeUntilNextSpawn -= extraSpawnTimePerBall

	ball.queue_free()
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


func explodeBall(ball: Ball, playAudio: bool = true):
	var particleEmitter: OneShotParticleEmitter = explosionParticleEmitter.instantiate()
	particleEmittersControl.add_child(particleEmitter)
	particleEmitter.color = ball.teamColor.color
	particleEmitter.global_position = ball.global_position
	ScreenShaker.addShake(20)
	deleteBall(ball)
	if playAudio: AudioManager.playBallExplosion()

func explodeAllBalls():
	for ball in balls.keys():
		explodeBall(ball, false)
	AudioManager.playBallExplosion()


func prepForFinale(spawnDelay: float):
	explodeAllBalls()
	burstSpawns = true
	off = true
	averageSpawnTime *= 4
	timeUntilNextSpawn = spawnDelay
	theBallScaleFactor /= 4


func queuePlayerControlledBall(player: Player):
	playerBallRespawnTimers[player] = randf_range(5,10)
