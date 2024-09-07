class_name Player
extends Object

var teamColor: Color
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

func _init(p_teamColor: Color, p_inputSet, p_sdInput = 0):
	teamColor = p_teamColor
	inputSet = p_inputSet
	sdInput = p_sdInput

func isInputPressed(input: String) -> bool:
	if input: return inputSet.inputPressed[input]
	else: return false
