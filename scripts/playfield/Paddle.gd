class_name Paddle
extends Node2D

@export var pivot: Area2D
@export var collider: CollisionShape2D
@export var color: ColorRect
@export var ballDuplicatorSprite: Sprite2D
@export var topStickyShader: ColorRect
@export var bottomStickyShader: ColorRect
@export var ballBoosterShader: ColorRect
@export var texture: TextureRect
@export var chargingNode: ColorRect
@export var chargedParticleEmitter: CPUParticles2D
@export var failedChargeParticleEmitter: CPUParticles2D
@export var textControl: Control

@export var noise: FastNoiseLite
var noisePos: float

var team: Team
var player: Player

const baseWidth := 110.0

var polygonWidthMultiplier
var oldPolygonWidthMultiplier
var polygonWidthMultiplierDelta

var teamSizeWidthMultiplier: float
const TEAM_SIZE_WIDTH_MULTIPLIERS := {
	1 : 1.0,
	2 : 0.8,
	3 : 0.7,
	4 : 0.625,
	5 : 0.55,
	6 : 0.5,
	7 : 0.45,
	8 : 0.4
}

var powerupWidthMultiplier: float = 1.0

var _width: float
var width: float:
	get: return _width

var baseHeight := 10
var height: float:
	get: return baseHeight

var baseSpeed := 200.0
var polygonSpeedMultiplier: float
var oldPolygonSpeedMultiplier: float
var polygonSpeedMultiplierDelta: float
var powerupSpeedMultiplier: float = 1.0
var _speed: float
var speed: float:
	get: return _speed

var movable := true
var moving := false
enum {NONE, LEFT, RIGHT}
var direction: int
var leftKey: String
var leftKeyAlt: String
var rightKey: String
var rightKeyAlt: String

var leftOfPaddle: Paddle = null
var rightOfPaddle: Paddle = null
var atBoundary: bool
var remainingDistance: float
var connectedPaddles: Array[Paddle]

var transitioning := false
var transitionDuration: float
var transitionTimeElapsed: float = 10
var transitionFraction: float

var verticalFraction: float

var leftBoundary: float
var rightBoundary: float

var chargingSpin: bool
var chargingDuration: float
var chargingTimeElasped: float
var chargingClockwise: bool
var chargedSpin: bool
var queuedSpin: bool
var chargedTimeElapsed: float
var chargedDuration: float
var losingCharge: bool

var spinning: bool
var spinDuration: float
var spinTimeRemaining: float
var clockwiseSpin: bool
var initialRotation: float
var rotationDelta: float

var failedSpinJitterStrength: float

var alphaChanging: bool
var alphaChangeDuration: float
var alphaChangeTimeElapsed: float
var originalAlpha: float
var alphaDelta: float
var onFinishChangingAlpha: Callable

var powerupDurations: Dictionary = {
	PowerupManager.Type.SPIN_CYCLE : 0, PowerupManager.Type.DUPLICATOR : 0, PowerupManager.Type.STICKY : 0,
	PowerupManager.Type.BALL_BOOSTER : 0, PowerupManager.Type.WIDE_PADDLE : 0, PowerupManager.Type.FAST_PADDLE : 0,
}
var absorbedPowerupParticles: int

var frameBeginPos: Vector2
var stuckBalls: Array[Ball]
var ballBoost: float:
	get:
		if powerupDurations[PowerupManager.Type.BALL_BOOSTER]: return 1.5
		else: return 1.0
var colorPosOffset := Vector2.ZERO

func _ready():
	topStickyShader.material.set_shader_parameter("noiseOffset", Vector2(randf(),randf()))
	bottomStickyShader.material.set_shader_parameter("noiseOffset", Vector2(randf(),randf()))

func initPaddle(
	p_verticalFraction: float, polygon: PolygonGuide.Polygon, p_team: Team, p_player: Player,
	xPosFraction: float, p_leftBoundary: float, p_rightBoundary: float
):

	verticalFraction = p_verticalFraction
	team = p_team
	player = p_player
	leftBoundary = p_leftBoundary
	rightBoundary = p_rightBoundary

	polygonWidthMultiplier = polygon.paddleWidthMultiplier
	polygonSpeedMultiplier = polygon.paddleSpeedMultiplier
	teamSizeWidthMultiplier = TEAM_SIZE_WIDTH_MULTIPLIERS[len(team.players)]
	updateWidthAndHeight()
	_speed = baseSpeed * polygonSpeedMultiplier * Settings.getSettingValue(Settings.Setting.PADDLE_SPEED)
	print("Init paddle at " + str(position))
	position.x = leftBoundary + ((rightBoundary-width)-leftBoundary)*xPosFraction

	player.inputSet.onCompletedCircle.connect(initiateCharge)
	updateDirectionKeys()

	player.paddle = self
	color.color = team.color
	chargingNode.color = team.color
	ballDuplicatorSprite.modulate = team.color
	topStickyShader.color = team.color
	bottomStickyShader.color = team.color
	ballBoosterShader.color = team.color
	noisePos += randf_range(0,10)

	if player.icon == PlayerManager.PlayerIcon.CIRCLE:
		texture.hide()
	else:
		texture.texture = player.texture


func updateDirectionKeys():
	
	var teamAngle := team.angle

	if teamAngle > -PI/2 + 0.1 and teamAngle < PI/2 - 0.1:
		rightKey = player.rightInput
		leftKey = player.leftInput
	elif teamAngle < -PI/2 - 0.1 or teamAngle > PI/2 + 0.1:
		rightKey = player.leftInput
		leftKey = player.rightInput
	else:
		rightKey = ''
		leftKey = ''

	if teamAngle > 0.1 and teamAngle < PI - 0.1:
		rightKeyAlt = player.downInput
		leftKeyAlt = player.upInput
	elif teamAngle < -0.1 and teamAngle > -PI + 0.1:
		rightKeyAlt = player.upInput
		leftKeyAlt = player.downInput
	else:
		rightKeyAlt = ''
		leftKeyAlt = ''


func changePolygon(newPolygon: PolygonGuide.Polygon, p_transitionDuration: float):

	transitioning = true
	transitionDuration = p_transitionDuration
	transitionTimeElapsed = 0

	oldPolygonWidthMultiplier = polygonWidthMultiplier
	var targetPolygonWidthMultiplier := newPolygon.paddleWidthMultiplier
	polygonWidthMultiplierDelta = targetPolygonWidthMultiplier - oldPolygonWidthMultiplier

	oldPolygonSpeedMultiplier = polygonSpeedMultiplier
	var targetPolygonSpeedMultiplier := newPolygon.paddleSpeedMultiplier
	polygonSpeedMultiplierDelta = targetPolygonSpeedMultiplier - oldPolygonSpeedMultiplier

func processTransitions(delta):

	if transitioning:

		transitionTimeElapsed += delta
		if transitionTimeElapsed >= transitionDuration:
			transitionTimeElapsed = transitionDuration
			transitioning = false
		transitionFraction = transitionTimeElapsed/transitionDuration

		polygonWidthMultiplier = oldPolygonWidthMultiplier + polygonWidthMultiplierDelta*transitionFraction
		polygonSpeedMultiplier = oldPolygonSpeedMultiplier + polygonSpeedMultiplierDelta*transitionFraction
	

func processPowerups(delta):
	for powerup in powerupDurations:
		if powerupDurations[powerup] > 0:
			powerupDurations[powerup] -= delta
			if powerupDurations[powerup] < 0: powerupDurations[powerup] = 0
	
	if powerupDurations[PowerupManager.Type.WIDE_PADDLE]:
		powerupWidthMultiplier = lerp(powerupWidthMultiplier, 2.0, delta)
	else:
		powerupWidthMultiplier = lerp(powerupWidthMultiplier, 1.0, delta/4)
	
	if powerupDurations[PowerupManager.Type.FAST_PADDLE]:
		powerupSpeedMultiplier = lerp(powerupSpeedMultiplier, 3.0, delta)
	else:
		powerupSpeedMultiplier = lerp(powerupSpeedMultiplier, 1.0, delta/4)
	
	if not powerupDurations[PowerupManager.Type.STICKY]:
		unstickBalls()

	colorPosOffset = Vector2.ZERO
	if powerupSpeedMultiplier > 1:
		noisePos += delta*5.0
		colorPosOffset = Vector2(
			noise.get_noise_2d(0, noisePos)*(powerupSpeedMultiplier-1.0)*2,
			noise.get_noise_2d(100, noisePos)*(powerupSpeedMultiplier-1.0)*2
		)
	if failedSpinJitterStrength > 0.01:
		failedSpinJitterStrength = lerp(failedSpinJitterStrength, 0.0, delta*2)
		if not powerupDurations[PowerupManager.Type.FAST_PADDLE]:
			noisePos += delta*10.0
			colorPosOffset = Vector2(
				noise.get_noise_2d(0, noisePos)*failedSpinJitterStrength*3,
				noise.get_noise_2d(100, noisePos)*failedSpinJitterStrength*3
			)
	
	if powerupDurations[PowerupManager.Type.DUPLICATOR] > 2:
		ballDuplicatorSprite.self_modulate.a = lerp(ballDuplicatorSprite.self_modulate.a, 1.0, delta*2)
	else:
		ballDuplicatorSprite.self_modulate.a = lerp(ballDuplicatorSprite.self_modulate.a, 0.0, delta)
	ballDuplicatorSprite.region_rect.position.x += delta*10

	if powerupDurations[PowerupManager.Type.SPIN_CYCLE] > 2 and not chargingSpin and not spinning:
		chargingNode.self_modulate.a = lerp(chargingNode.self_modulate.a, 1.0, delta*2)
	elif not chargingSpin:
		chargingNode.self_modulate.a = lerp(chargingNode.self_modulate.a, 0.0, delta)

	if powerupDurations[PowerupManager.Type.STICKY] > 2:
		topStickyShader.self_modulate.a = lerp(topStickyShader.self_modulate.a, 0.75, delta*2)
		bottomStickyShader.self_modulate.a = lerp(bottomStickyShader.self_modulate.a, 0.75, delta*2)
	else:
		topStickyShader.self_modulate.a = lerp(topStickyShader.self_modulate.a, 0.0, delta)
		bottomStickyShader.self_modulate.a = lerp(bottomStickyShader.self_modulate.a, 0.0, delta)

	if powerupDurations[PowerupManager.Type.BALL_BOOSTER] > 2:
		ballBoosterShader.self_modulate.a = lerp(ballBoosterShader.self_modulate.a, 1.0, delta*2)
	else:
		ballBoosterShader.self_modulate.a = lerp(ballBoosterShader.self_modulate.a, 0.0, delta)


func updateWidthAndHeight():
	_width = (
		(baseWidth-2*Settings.getSettingValue(Settings.Setting.BALL_SIZE)) * teamSizeWidthMultiplier *
		polygonWidthMultiplier * verticalFraction**2 *
		Settings.getSettingValue(Settings.Setting.PADDLE_SIZE) *
		powerupWidthMultiplier
	)
	if _width < 20: _width = 20
	pivot.position.x = width/2
	textControl.position.x = width/2
	collider.shape.size.x = width
	color.size.x = width
	color.position = Vector2(-width/2,-5) + colorPosOffset
	color.material.set_shader_parameter("width", width)

	ballDuplicatorSprite.position.x = width/2
	ballDuplicatorSprite.region_rect.size.x = width

	topStickyShader.material.set_shader_parameter("width", width)
	bottomStickyShader.material.set_shader_parameter("width", width)

	ballBoosterShader.position.x = -width/2 - 20
	ballBoosterShader.size.x = width + 40

	chargedParticleEmitter.position.x = width/2
	failedChargeParticleEmitter.position.x = width/2

	position.y = -team.height*(1-verticalFraction)-height
	
	atBoundary = false


func forceUpdateWidth(newWidth: float):
	_width = newWidth
	pivot.position.x = width/2
	textControl.position.x = width/2
	collider.shape.size.x = width
	color.size.x = width
	color.position = Vector2(-width/2,-5) + colorPosOffset
	color.material.set_shader_parameter("width", width)

	ballDuplicatorSprite.position.x = width/2
	ballDuplicatorSprite.region_rect.size.x = width

	topStickyShader.material.set_shader_parameter("width", width)
	bottomStickyShader.material.set_shader_parameter("width", width)

	ballBoosterShader.position.x = -width/2 - 20
	ballBoosterShader.size.x = width + 40

	chargedParticleEmitter.position.x = width/2
	failedChargeParticleEmitter.position.x = width/2


func checkForValidPos() -> bool:
	var validPos := true

	if leftOfPaddle == null:
		if position.x < leftBoundary:
			validPos = false
			atBoundary = true
			position.x = leftBoundary + 0.1
	else:
		var overlap := leftOfPaddle.position.x + leftOfPaddle.width - position.x
		if overlap > 0.01:
			validPos = false
			if atBoundary:
				leftOfPaddle.position.x -= overlap + 0.01
				leftOfPaddle.atBoundary = true
			elif leftOfPaddle.atBoundary:
				position.x += overlap + 0.01
				atBoundary = false
			else:
				leftOfPaddle.position.x -= overlap/2 + 0.01
				position.x += overlap/2 + 0.01

	if rightOfPaddle == null:
		if position.x + width > rightBoundary:
			validPos = false
			atBoundary = true
			position.x = rightBoundary - width - 0.01
	else:
		var overlap := position.x + width - rightOfPaddle.position.x
		if overlap > 0.01:
			validPos = false
			if atBoundary:
				rightOfPaddle.position.x += overlap + 0.01
				rightOfPaddle.atBoundary = true
			elif rightOfPaddle.atBoundary:
				position.x -= overlap + 0.01
				atBoundary = false
			else:
				rightOfPaddle.position.x += overlap/2 + 0.01
				position.x -= overlap/2 + 0.01

	return validPos


func processInput(delta: float):

	remainingDistance = 0
	connectedPaddles = [self]
	direction = NONE

	if not moving: updateDirectionKeys()

	moving = false
	if movable:
		_speed = (
			baseSpeed * polygonSpeedMultiplier *
			Settings.getSettingValue(Settings.Setting.PADDLE_SPEED) *
			powerupSpeedMultiplier
		)
		if player.isInputPressed(leftKey) or player.isInputPressed(leftKeyAlt):
			remainingDistance -= speed*delta
			direction = LEFT
			moving = true
		if player.isInputPressed(rightKey) or player.isInputPressed(rightKeyAlt):
			remainingDistance += speed*delta
			direction = RIGHT
			moving = true
		if Input.is_key_pressed(player.sdInput): team.eliminateTeam.emit(team)

	if chargingSpin:
		chargingTimeElasped += delta
		if chargingTimeElasped > chargingDuration:
			finishChargingSpin()
		else:
			chargingNode.material.set_shader_parameter("innerSpiralProgress", chargingTimeElasped/chargingDuration)

	if chargedSpin and not losingCharge:
		chargedTimeElapsed += delta
		if chargedTimeElapsed >= chargedDuration:
			chargedParticleEmitter.emitting = false
			losingCharge = true
			changeTextureAlpha(0, 1, removeCharge)

	if player.isInputJustPressed(player.specialInput):
		if chargedSpin:
			AudioManager.playInitiateSpin(team.color)
			initiateSpin(chargingClockwise)
		elif chargingSpin:
			queuedSpin = true
		elif failedSpinJitterStrength < 0.1:
			AudioManager.playFailedCharge(team.color)
			failedChargeParticleEmitter.emitting = true
			failedSpinJitterStrength = 1

	if spinning:
		spinTimeRemaining -= delta
		if spinTimeRemaining <= 0:
			spinTimeRemaining = 0
			spinning = false
			if powerupDurations[PowerupManager.Type.SPIN_CYCLE]:
				pivot.rotation = initialRotation + rotationDelta
				initiateSpin(chargingClockwise)
			else:
				changeTextureAlpha(0, 2)
				# AudioManager.stopSustainedSpin(self)
		var spinFraction: float = (spinDuration-spinTimeRemaining)/spinDuration
		pivot.rotation = initialRotation + rotationDelta*spinFraction
	
	if alphaChanging:
		alphaChangeTimeElapsed += delta
		if alphaChangeTimeElapsed > alphaChangeDuration:
			alphaChangeTimeElapsed = alphaChangeDuration
			alphaChanging = false
			if onFinishChangingAlpha: onFinishChangingAlpha.call()
		var alphaChangeRatio = alphaChangeTimeElapsed/alphaChangeDuration
		texture.self_modulate = Color(texture.self_modulate,originalAlpha + alphaDelta*alphaChangeRatio)


func initiateCharge(_inputSet, clockwise: bool):
	if chargingSpin or spinning or PauseManager.paused: return

	chargingSpin = true
	chargedSpin = false
	chargingDuration = 0.5
	chargingTimeElasped = 0
	chargingClockwise = clockwise

	chargingNode.self_modulate.a = 1
	chargingNode.material.set_shader_parameter("innerSpiralProgress", 0.0)
	chargingNode.material.set_shader_parameter("spiralRotationSpeed", 0.5)
	if chargingClockwise: chargingNode.material.set_shader_parameter("reverse", 1.0)
	else: chargingNode.material.set_shader_parameter("reverse", -1.0)
	chargedParticleEmitter.emitting = false

	changeTextureAlpha(1, chargingDuration)

	AudioManager.playPaddleCharge(team.color)


func removeCharge():
	chargedSpin = false
	chargedParticleEmitter.emitting = false


func finishChargingSpin():
	chargingNode.self_modulate.a = 0
	chargingNode.material.set_shader_parameter("innerSpiralProgress", 0.5)
	# initiateSpin(chargingClockwise)
	# AudioManager.playInitiateSpin(team.color)
	# AudioManager.playSustainedSpin(self)
	chargingSpin = false
	if powerupDurations[PowerupManager.Type.SPIN_CYCLE] or queuedSpin:
		AudioManager.playInitiateSpin(team.color)
		initiateSpin(chargingClockwise)
		queuedSpin = false
	else:
		chargedSpin = true
		losingCharge = false
		chargedDuration = 5
		chargedTimeElapsed = 0
		chargedParticleEmitter.emitting = true


func initiateSpin(clockwise: bool):
	removeCharge()
	spinning = true
	spinDuration = width/150.0
	if powerupDurations[PowerupManager.Type.SPIN_CYCLE]: spinDuration /= 2.0
	spinTimeRemaining = spinDuration
	clockwiseSpin = clockwise
	initialRotation = pivot.rotation
	if clockwise: rotationDelta = PI
	else: rotationDelta = -PI
	unstickBalls()


func changeTextureAlpha(targetAlpha: float, p_alphaChangeDuration: float, onFinish: Callable = Callable()):
	alphaChanging = true
	alphaChangeDuration = p_alphaChangeDuration
	alphaChangeTimeElapsed = 0
	originalAlpha = texture.self_modulate.a
	alphaDelta = targetAlpha-originalAlpha
	onFinishChangingAlpha = onFinish
	

func moveUntilCollision():

	if remainingDistance > 0:

		if rightOfPaddle in connectedPaddles: return

		elif rightOfPaddle != null and rightOfPaddle.position.x - (position.x + width) < remainingDistance:

			moveConnectedPaddles(rightOfPaddle.position.x - (position.x + width))

			if rightOfPaddle.remainingDistance <= 0:

				var leftPaddles: Array[Paddle] = connectedPaddles
				var rightPaddles: Array[Paddle] = rightOfPaddle.connectedPaddles

				connectPaddles(leftPaddles, rightPaddles)
		
		elif rightBoundary - (position.x + width) < remainingDistance:

			moveConnectedPaddles(rightBoundary - (position.x + width), true)

		else:

			moveConnectedPaddles(remainingDistance)

	elif remainingDistance < 0:

		if leftOfPaddle in connectedPaddles: return

		elif leftOfPaddle != null and (leftOfPaddle.position.x + width) - position.x > remainingDistance:

			moveConnectedPaddles((leftOfPaddle.position.x + width) - position.x)

			if leftOfPaddle.remainingDistance >= 0:

				var leftPaddles: Array[Paddle] = leftOfPaddle.connectedPaddles
				var rightPaddles: Array[Paddle] = connectedPaddles

				connectPaddles(leftPaddles, rightPaddles)
		
		elif leftBoundary - position.x > remainingDistance:

			moveConnectedPaddles(leftBoundary - position.x, true)

		else:

			moveConnectedPaddles(remainingDistance)


func moveConnectedPaddles(distanceToMove: float, movingToBoundary := false):
	for connectedPaddle in connectedPaddles:
		connectedPaddle.position.x += distanceToMove
		if movingToBoundary:
			connectedPaddle.remainingDistance = 0
			direction = NONE
		else:
			connectedPaddle.remainingDistance -= distanceToMove


func connectPaddles(leftPaddles: Array[Paddle], rightPaddles: Array[Paddle]):
	var newRemainingDistance = (
		(leftPaddles[0].remainingDistance*len(leftPaddles) + rightPaddles[0].remainingDistance*len(rightPaddles)) /
		float(len(leftPaddles) + len(rightPaddles))
	)

	for leftPaddle in leftPaddles:
		leftPaddle.remainingDistance = newRemainingDistance
		leftPaddle.connectedPaddles += rightPaddles
	for rightPaddle in rightPaddles:
		rightPaddle.remainingDistance = newRemainingDistance
		rightPaddle.connectedPaddles += leftPaddles


func processStuckBalls():
	for ball in stuckBalls:
		ball.reorientBallToStuckPaddle()

func unstickBalls():
	for ball in stuckBalls:
		ball.unstick()
	stuckBalls.clear()
