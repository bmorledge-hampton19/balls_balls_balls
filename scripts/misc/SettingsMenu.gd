class_name SettingsMenu
extends Control
@export var camera: Camera2D
@export var background: Background

@export var masterInputSelector: MasterInputSelector
var firstFrame := true

@export var settingSelectorsControl: Control
@export var settingSelectorPrefab: PackedScene
@export var settingSelectorLeftColumn: VBoxContainer
@export var settingSelectorRightColumn: VBoxContainer
var settingSelectors: Array[SettingSelector]

@export var settingBallsControl: Control
@export var settingBallPrefab: PackedScene
@export var trailPrefab: PackedScene
@export var trailsCanvasGroup: CanvasGroup
var settingBalls: Array[SettingBall]

var highlightedSettingSelectorIndex: int
var settingsFormat: int
var ballSpeed: float

# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceLoader.load_threaded_request("res://scenes/MainMenu.tscn")

	for setting: Settings.Setting in Settings.Setting.values():
		if setting in [Settings.Setting.BEHAVIOR_INTENSITY, Settings.Setting.SPIN_TYPE]: continue
		var settingSelectorColumn: VBoxContainer
		if setting in [
			Settings.Setting.SETTINGS_FORMAT,
			Settings.Setting.BALL_SIZE, Settings.Setting.BALL_SPEED, Settings.Setting.SPAWN_RATE,
			Settings.Setting.PADDLE_SPEED, Settings.Setting.PADDLE_SIZE,
			Settings.Setting.STARTING_LIVES, Settings.Setting.LIVES_ON_ELIM,
			Settings.Setting.FULLSCREEN,
		]:
			settingSelectorColumn = settingSelectorLeftColumn
		else:
			settingSelectorColumn = settingSelectorRightColumn
		
		var newSettingSelector: SettingSelector = settingSelectorPrefab.instantiate()
		newSettingSelector.init(setting)
		if setting in [
			Settings.Setting.ANGLER_SPAWN_RATE, Settings.Setting.SPIRALING_SPAWN_RATE,
			Settings.Setting.STOP_AND_START_SPAWN_RATE, Settings.Setting.DRIFTER_SPAWN_RATE,
			Settings.Setting.PLAYER_CONTROLLED_BALLS,
		]:
			newSettingSelector.indent()
		settingSelectorColumn.add_child(newSettingSelector)
		settingSelectors.append(newSettingSelector)
		if setting == Settings.Setting.FULLSCREEN: Settings.onToggleFullscreen.connect(newSettingSelector.update)
		if setting == Settings.Setting.PRESET: Settings.onCheckPresets.connect(newSettingSelector.update)
		
		var newSettingBall: SettingBall = settingBallPrefab.instantiate()
		var newTrail: Trail = trailPrefab.instantiate()
		newSettingBall.trail = newTrail
		settingBallsControl.add_child(newSettingBall)
		settingBalls.append(newSettingBall)
		trailsCanvasGroup.add_child(newTrail)
		newSettingBall.onBallHitWall.connect(background.spawnBallArc)
		newSettingBall.init(setting)
		if setting == Settings.Setting.FULLSCREEN: Settings.onToggleFullscreen.connect(newSettingBall.update)
		if setting == Settings.Setting.PRESET: Settings.onCheckPresets.connect(newSettingBall.update)
	Settings.onSetPreset.connect(updateSettingSelectors)

	for settingSelector in settingSelectors:
		settingSelector.lowlight()
	for settingBall in settingBalls:
		settingBall.lowlight()

	if PauseManager.transferableController == null:
		masterInputSelector.onMasterInputSelected.connect(initSettingSelectors)
		masterInputSelector.onMasterInputSelected.connect(initSettingBalls)
	else:
		masterInputSelector.masterInputSet = PauseManager.transferableController
		initSettingSelectors()
		initSettingBalls()
		masterInputSelector.hide()

	updateSettingsFormat()
	updateBallSpeed()


func _process(_delta):
	if Input.is_action_just_pressed("SECONDARY_MENU_BUTTON"):
		returnToMainMenu()
	
	if settingsFormat != Settings.getSettingValue(Settings.Setting.SETTINGS_FORMAT):
		updateSettingsFormat()

	if settingsFormat != Settings.BALLS:
		if ballSpeed != 0: pauseBalls()
	elif ballSpeed != Settings.getSettingValue(Settings.Setting.BALL_SPEED):
		updateBallSpeed()

	var masterInputSet := masterInputSelector.masterInputSet
	if masterInputSet == null:
		return
	elif firstFrame:
		firstFrame = false
		return

	if masterInputSet.inputJustPressed[masterInputSet.rightInput]:
		if settingsFormat == Settings.BORING:
			settingSelectors[highlightedSettingSelectorIndex].increment()
		elif settingsFormat == Settings.BALLS:
			settingBalls[highlightedSettingSelectorIndex].increment()
		Settings.checkPresets()
	
	if masterInputSet.inputJustPressed[masterInputSet.leftInput]:
		if settingsFormat == Settings.BORING:
			settingSelectors[highlightedSettingSelectorIndex].decrement()
		elif settingsFormat == Settings.BALLS:
			settingBalls[highlightedSettingSelectorIndex].decrement()
		Settings.checkPresets()

	if masterInputSet.inputJustPressed[masterInputSet.downInput]:
		settingSelectors[highlightedSettingSelectorIndex].lowlight()
		settingBalls[highlightedSettingSelectorIndex].lowlight()
		highlightedSettingSelectorIndex = wrapi(highlightedSettingSelectorIndex + 1, 0, len(settingSelectors))
		settingSelectors[highlightedSettingSelectorIndex].highlight()
		settingBalls[highlightedSettingSelectorIndex].highlight()
	
	if masterInputSet.inputJustPressed[masterInputSet.upInput]:
		settingSelectors[highlightedSettingSelectorIndex].lowlight()
		settingBalls[highlightedSettingSelectorIndex].lowlight()
		highlightedSettingSelectorIndex = wrapi(highlightedSettingSelectorIndex - 1, 0, len(settingSelectors))
		settingSelectors[highlightedSettingSelectorIndex].highlight()
		settingBalls[highlightedSettingSelectorIndex].highlight()


func initSettingSelectors():
	settingSelectors[highlightedSettingSelectorIndex].highlight()

func initSettingBalls():
	settingBalls[highlightedSettingSelectorIndex].highlight()

func updateSettingsFormat():
	settingsFormat = Settings.getSettingValue(Settings.Setting.SETTINGS_FORMAT)
	if settingsFormat == Settings.BORING:
		settingSelectorsControl.show()
		settingBallsControl.hide()
		for ball in settingBalls:
			ball.baseSpeed = 0
		for settingSelector in settingSelectors:
			settingSelector.update()
	elif settingsFormat == Settings.BALLS:
		settingSelectorsControl.hide()
		settingBallsControl.show()
		for ball in settingBalls:
			ball.baseSpeed = ballSpeed
			ball.update()

func updateSettingSelectors():
	for settingSelector in settingSelectors:
		settingSelector.update()
	if settingsFormat == Settings.BALLS: updateBallSpeed()
	for ball in settingBalls:
		ball.update()

func updateBallSpeed():
	ballSpeed = Settings.getSettingValue(Settings.Setting.BALL_SPEED)
	for ball in settingBalls:
		ball.baseSpeed = ballSpeed

func pauseBalls():
	ballSpeed = 0
	for ball in settingBalls:
		ball.baseSpeed = ballSpeed


func returnToMainMenu():
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/MainMenu.tscn"))
