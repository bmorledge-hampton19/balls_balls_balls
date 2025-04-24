class_name Player
extends Object

var teamColor: Color
var active: bool
var inputSet: InputSets.InputSet
var leftInput: String:
	get: return inputSet.leftInput
var rightInput: String:
	get: return inputSet.rightInput
var upInput: String:
	get: return inputSet.upInput
var downInput: String:
	get: return inputSet.downInput
var specialInput: String:
	get: return inputSet.specialInput
var sdInput: int
var icon: PlayerManager.PlayerIcon
var texture: Texture2D:
	get: return PlayerManager.getPlayerIconTexture(icon)

var paddle: Paddle
var goals: int
var goalsAtLastPowerup: int
var readyForPowerup: bool:
	get:
		if goals >= goalsAtLastPowerup + Settings.getSettingValue(Settings.Setting.POWERUP_FREQUENCY):
			goalsAtLastPowerup += Settings.getSettingValue(Settings.Setting.POWERUP_FREQUENCY)
			return true
		else:
			return false
@warning_ignore("unused_signal")
signal onGoal(goals: int)

func _init(p_teamColor: Color, p_inputSet: InputSets.InputSet, p_icon: PlayerManager.PlayerIcon):
	teamColor = p_teamColor
	inputSet = p_inputSet
	inputSet.assignPlayer(self)
	icon = p_icon

func addSDInput(p_sdInput):
	sdInput = p_sdInput

func isInputPressed(input: String) -> bool:
	if input: return inputSet.inputPressed[input]
	else: return false

func isInputJustPressed(input: String) -> bool:
	if input: return inputSet.inputJustPressed[input]
	else: return false
