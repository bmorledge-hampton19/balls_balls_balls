class_name SettingSelector
extends MarginContainer

@export var settingNameLabel: Label
@export var valueContainer: HBoxContainer
@export var currentValue: Label
@export var leftBall: ColorRect
@export var rightBall: ColorRect

var setting: Settings.Setting
var possibleValues: Array
var currentValueIndex: int
var highlighted: bool

const lowlightColor: Color = Color.DIM_GRAY

func _ready():
	lowlight()

func init(p_setting: Settings.Setting):
	setting = p_setting
	possibleValues = Settings.SETTING_VALUE_NAMES[setting]

	settingNameLabel.text = Settings.SETTING_TITLES[setting] + ':'
	currentValueIndex = Settings._settingIndices[setting]
	currentValue.text = possibleValues[currentValueIndex]
	Settings.setSetting(setting, currentValueIndex)

func _process(_delta):

	if highlighted and (currentValueIndex > 1 or (currentValueIndex > 0 and setting != Settings.Setting.PRESET)):
		leftBall.color = Color.WHITE
		leftBall.position.x = sin(Time.get_ticks_msec()/500.0)*-5 - 5
	else:
		leftBall.color = lowlightColor
		leftBall.position.x = 0

	if highlighted and currentValueIndex < len(possibleValues)-1:
		rightBall.color = Color.WHITE
		rightBall.position.x = sin(Time.get_ticks_msec()/500.0)*5 + 5
	else:
		rightBall.color = lowlightColor
		rightBall.position.x = 0


func indent():
	add_theme_constant_override("margin_left", 45)
	settingNameLabel.custom_minimum_size.x = 205
	valueContainer.custom_minimum_size.x = 215


func increment():
	if currentValueIndex < len(possibleValues)-1:
		currentValueIndex += 1
		currentValue.text = possibleValues[currentValueIndex]
		Settings.setSetting(setting, currentValueIndex)


func decrement():
	if currentValueIndex > 1 or (currentValueIndex > 0 and setting != Settings.Setting.PRESET):
		currentValueIndex -= 1
		currentValue.text = possibleValues[currentValueIndex]
		Settings.setSetting(setting, currentValueIndex)


func highlight():
	highlighted = true
	currentValue.modulate = Color.WHITE
	settingNameLabel.modulate = Color.WHITE

func lowlight():
	highlighted = false
	currentValue.modulate = lowlightColor
	settingNameLabel.modulate = lowlightColor


func update():
	currentValueIndex = Settings._settingIndices[setting]
	currentValue.text = possibleValues[currentValueIndex]
