class_name Foreground
extends Polygon2D

@export var grid: ColorRect
@export var inwardPulsesControl: Control
@export var theBall: TheBall

@export var finalTwoControl: Control
@export var leftDivider: ColorRect
@export var rightDivider: ColorRect
@export var leftLives: FinalTwoLives
@export var rightLives: FinalTwoLives

var gridSucking: bool
var gridSuckingDuration: float
var gridSuckingTimeElapsed: float
var oldGridDistortion: float
var gridDistortionDelta: float
var oldGridVisibility: float
var gridVisibilityDelta: float

var finalTwoFadingIn: bool
var finalTwoFadeDuration: float
var finalTwoFadeTimeElapsed: float
signal afterfinalTwoFadeIn()

var leftDividerOffset: float = 0
var rightDividerOffset: float = 0
var leftDividerSpeed: float
var rightDividerSpeed: float
var dividerBaseSpeed: float = 10
var dividerAcceleratedSpeed: float = 32

var leftDividerDecelerating: bool
var leftDividerDecelerationDuration: float
var leftDividerDeclerationTimeRemaining: float

var rightDividerDecelerating: bool
var rightDividerDecelerationDuration: float
var rightDividerDeclerationTimeRemaining: float


func _ready():

	leftDividerSpeed = dividerBaseSpeed
	rightDividerSpeed = dividerBaseSpeed
	grid.material.set_shader_parameter("visibilityCutoff", 1)

func _process(delta):
	var theBallFactor = theBall.radius/54
	grid.material.set_shader_parameter("distortionIntensity", 0.15*theBallFactor)
    
	if not finalTwoControl: return

	if gridSucking:
		gridSuckingTimeElapsed += delta
		if gridSuckingTimeElapsed >= gridSuckingDuration:
			gridSuckingTimeElapsed = gridSuckingDuration
			gridSucking = false
		var durationRatio = gridSuckingTimeElapsed/gridSuckingDuration
		grid.material.set_shader_parameter(
			"distortionIntensity", oldGridDistortion+gridDistortionDelta*durationRatio
		)
		grid.material.set_shader_parameter(
			"visibilityCutoff", oldGridVisibility+gridVisibilityDelta*durationRatio
		)

	if finalTwoFadingIn:
		finalTwoFadeTimeElapsed += delta
		if finalTwoFadeTimeElapsed >= finalTwoFadeDuration:
			finalTwoFadeTimeElapsed = finalTwoFadeDuration
			finalTwoFadingIn = false
			afterfinalTwoFadeIn.emit()
		var fadeRatio: float
		if finalTwoFadeDuration == 0: fadeRatio = 1
		else: fadeRatio = finalTwoFadeTimeElapsed/finalTwoFadeDuration
		finalTwoControl.modulate.a = fadeRatio

	if leftDividerDecelerating:
		leftDividerDeclerationTimeRemaining -= delta
		if leftDividerDeclerationTimeRemaining <= 0:
			leftDividerDeclerationTimeRemaining = 0
			leftDividerDecelerating = false
		var decelerationRatio = leftDividerDeclerationTimeRemaining/leftDividerDecelerationDuration
		leftDividerSpeed = dividerBaseSpeed + (dividerAcceleratedSpeed-dividerBaseSpeed)*decelerationRatio
	leftDividerOffset += leftDividerSpeed*delta
	leftDivider.material.set_shader_parameter("offset", leftDividerOffset)

	if rightDividerDecelerating:
		rightDividerDeclerationTimeRemaining -= delta
		if rightDividerDeclerationTimeRemaining <= 0:
			rightDividerDeclerationTimeRemaining = 0
			rightDividerDecelerating = false
		var decelerationRatio = rightDividerDeclerationTimeRemaining/rightDividerDecelerationDuration
		rightDividerSpeed = dividerBaseSpeed + (dividerAcceleratedSpeed-dividerBaseSpeed)*decelerationRatio
	rightDividerOffset += rightDividerSpeed*delta
	rightDivider.material.set_shader_parameter("offset", rightDividerOffset)


func updateCenter(new_center: float):
	theBall.center = new_center
	inwardPulsesControl.position.y = new_center - 270
	grid.material.set_shader_parameter("centerOffset", Vector2(0, (270-new_center)/540))


func suckGrid(duration: float):
	
	gridSucking = true
	gridSuckingDuration = duration
	gridSuckingTimeElapsed = 0

	oldGridDistortion = grid.material.get_shader_parameter("distortionIntensity")
	gridDistortionDelta = 30.0 - oldGridDistortion
	grid.material.set_shader_parameter("distortionVariation", 0)

	oldGridVisibility = 0.75
	grid.material.set_shader_parameter("visibilityCutoff", oldGridVisibility)
	gridVisibilityDelta = 0 - oldGridVisibility

	AudioManager.playTheBallSucking()

func bringTheBallToFront():
	move_child(theBall, -1)

func fadeInFinalTwoGraphics(leftTeam: Team, rightTeam: Team, fadeDuration: float, initialDelay: float = 0):

	await get_tree().create_timer(initialDelay).timeout

	finalTwoFadingIn = true
	finalTwoFadeDuration = fadeDuration
	finalTwoFadeTimeElapsed = 0

	leftDivider.color = leftTeam.color
	rightDivider.color = rightTeam.color
	leftLives.modulate = leftTeam.color
	rightLives.modulate = rightTeam.color

func modulateDividerSpeed(left: bool, duration: float):
	if left:
		leftDividerDecelerating = true
		leftDividerDecelerationDuration = duration
		leftDividerDeclerationTimeRemaining = duration
	else:
		rightDividerDecelerating = true
		rightDividerDecelerationDuration = duration
		rightDividerDeclerationTimeRemaining = duration
