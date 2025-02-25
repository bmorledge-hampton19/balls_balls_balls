class_name SettingBall
extends Ball

@export var settingNameLabel: Label
@export var currentValue: Label

var setting: Settings.Setting
var possibleValues: Array
var currentValueIndex: int
var highlighted: bool

func _ready():
	super._ready()
	lowlight()


func init(p_setting: Settings.Setting):
	setting = p_setting
	possibleValues = Settings.SETTING_VALUE_NAMES[setting]

	settingNameLabel.text = Settings.SETTING_TITLES[setting] + ':'
	currentValueIndex = Settings._settingIndices[setting]
	currentValue.text = possibleValues[currentValueIndex]
	Settings.setSetting(setting, currentValueIndex)

	radius = 40
	global_position = Vector2(randi_range(50,910), randi_range(50,300))
	baseSpeed = Settings.getSettingValue(Settings.Setting.BALL_SPEED)
	if randi_range(0,1): baseSpeedDirection = Vector2.from_angle(randf_range(0.1,PI-.1))
	else: baseSpeedDirection = Vector2.from_angle(randf_range(0.1,PI-.1)*-1)


func _process(delta):
	return super._process(delta)

func increment():
	currentValueIndex = wrapi(currentValueIndex+1, 0, len(possibleValues))
	currentValue.text = possibleValues[currentValueIndex]
	Settings.setSetting(setting, currentValueIndex)


func decrement():
	currentValueIndex = wrapi(currentValueIndex-1, 0, len(possibleValues))
	currentValue.text = possibleValues[currentValueIndex]
	Settings.setSetting(setting, currentValueIndex)


func highlight():
	highlighted = true
	updateColor(Color.WHITE)
	settingNameLabel.modulate = Color.WHITE
	get_parent().move_child(self, -1)

func lowlight():
	highlighted = false
	updateColor(Color.DIM_GRAY)
	settingNameLabel.modulate = Color.DIM_GRAY


func update():
	currentValueIndex = Settings._settingIndices[setting]
	currentValue.text = possibleValues[currentValueIndex]
