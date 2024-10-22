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
var sdInput: int
var icon: PlayerManager.PlayerIcon
var texture: Texture2D:
	get: return PlayerManager.getPlayerIconTexture(icon)

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
