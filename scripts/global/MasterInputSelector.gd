class_name MasterInputSelector
extends Control

@export var shadedBackground: ColorRect

@export var cwArrow: TextureRect
@export var ccwArrow: TextureRect

@export var cwNoInputText: Label
@export var ccwNoInputText: Label

@export var cwControllerInputID: Control
@export var cwControllerNum: Label
@export var cwControllerInputs: TextureRect
@export var ccwControllerInputID: Control
@export var ccwControllerNum: Label
@export var ccwControllerInputs: TextureRect

@export var cwKeyboardInputID: Control
@export var cwUpKey: TextureRect
@export var cwRightKey: TextureRect
@export var cwDownKey: TextureRect
@export var cwLeftKey: TextureRect
@export var ccwKeyboardInputID: Control
@export var ccwUpKey: TextureRect
@export var ccwRightKey: TextureRect
@export var ccwDownKey: TextureRect
@export var ccwLeftKey: TextureRect

const controllerPromptsDir = "res://images/controller_prompts/"
const leftStick = controllerPromptsDir + "Switch_Left_Stick.png"
const rightStick = controllerPromptsDir + "Switch_Right_Stick.png"
const dpad = controllerPromptsDir + "XboxOne_Dpad.png"
const faceButtons = controllerPromptsDir + "Positional_Prompts_All_Empty.png"
const wKey = controllerPromptsDir + "W_Key_Dark.png"
const dKey = controllerPromptsDir + "D_Key_Dark.png"
const sKey = controllerPromptsDir + "S_Key_Dark.png"
const aKey = controllerPromptsDir + "A_Key_Dark.png"
const iKey = controllerPromptsDir + "I_Key_Dark.png"
const lKey = controllerPromptsDir + "L_Key_Dark.png"
const kKey = controllerPromptsDir + "K_Key_Dark.png"
const jKey = controllerPromptsDir + "J_Key_Dark.png"
const upArrowKey = controllerPromptsDir + "Arrow_Up_Key_Dark.png"
const rightArrowKey = controllerPromptsDir + "Arrow_Right_Key_Dark.png"
const downArrowKey = controllerPromptsDir + "Arrow_Down_Key_Dark.png"
const leftArrowKey = controllerPromptsDir + "Arrow_Left_Key_Dark.png"
const eightKey = controllerPromptsDir + "8_Key_Dark.png"
const sixKey = controllerPromptsDir + "6_Key_Dark.png"
const fiveKey = controllerPromptsDir + "5_Key_Dark.png"
const fourKey = controllerPromptsDir + "4_Key_Dark.png"

var cwInputSet: InputSets.InputSet
var ccwInputSet: InputSets.InputSet
var masterInputSet: InputSets.InputSet

signal onMasterInputSelected()

# Called when the node enters the scene tree for the first time.
func _ready():
	InputSets.onAnyCircle.connect(registerCircle)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cwArrow.rotation += PI*delta
	ccwArrow.rotation -= PI*delta

func registerCircle(inputSet: InputSets.InputSet, clockwise: bool):
	
	var controllerInputID: Control
	var controllerNum: Label
	var controllerInputs: TextureRect
	var keyboardInputID: Control
	var upKey: TextureRect
	var rightKey: TextureRect
	var downKey: TextureRect
	var leftKey: TextureRect

	if clockwise:
		cwNoInputText.hide()
		cwInputSet = inputSet
		controllerInputID = cwControllerInputID
		controllerNum = cwControllerNum
		controllerInputs = cwControllerInputs
		keyboardInputID = cwKeyboardInputID
		upKey = cwUpKey
		rightKey = cwRightKey
		downKey = cwDownKey
		leftKey = cwLeftKey
	else:
		ccwNoInputText.hide()
		ccwInputSet = inputSet
		controllerInputID = ccwControllerInputID
		controllerNum = ccwControllerNum
		controllerInputs = ccwControllerInputs
		keyboardInputID = ccwKeyboardInputID
		upKey = ccwUpKey
		rightKey = ccwRightKey
		downKey = ccwDownKey
		leftKey = ccwLeftKey

	if inputSet.device == -1:
		keyboardInputID.show()
		controllerInputID.hide()
		match inputSet.name:
			InputSets.WASD:
				upKey.texture = preload(wKey)
				rightKey.texture = preload(dKey)
				downKey.texture = preload(sKey)
				leftKey.texture = preload(aKey)
			InputSets.IJKL:
				upKey.texture = preload(iKey)
				rightKey.texture = preload(lKey)
				downKey.texture = preload(kKey)
				leftKey.texture = preload(jKey)
			InputSets.ARROW_KEYS:
				upKey.texture = preload(upArrowKey)
				rightKey.texture = preload(rightArrowKey)
				downKey.texture = preload(downArrowKey)
				leftKey.texture = preload(leftArrowKey)
			InputSets.NUMPAD:
				upKey.texture = preload(eightKey)
				rightKey.texture = preload(sixKey)
				downKey.texture = preload(fiveKey)
				leftKey.texture = preload(fourKey)
	else:
		controllerInputID.show()
		keyboardInputID.hide()
		controllerNum.text = str(inputSet.device+1)
		match inputSet.name:
			InputSets.FACE_BUTTONS: controllerInputs.texture = preload(faceButtons)
			InputSets.DPAD: controllerInputs.texture = preload(dpad)
			InputSets.LEFT_JOYSTICK: controllerInputs.texture = preload(leftStick)
			InputSets.RIGHT_JOYSTICK: controllerInputs.texture = preload(rightStick)

	if cwInputSet != null and ccwInputSet != null and cwInputSet == ccwInputSet:
		masterInputSet = inputSet
		InputSets.onAnyCircle.disconnect(registerCircle)
		onMasterInputSelected.emit()
		hide()