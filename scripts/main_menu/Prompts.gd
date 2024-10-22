class_name Prompts
extends Node

@export var controlStickControl: Control
const controllerPromptsDir = "res://images/controller_prompts/"
const leftStick = controllerPromptsDir + "Switch_Left_Stick.png"
const rightStick = controllerPromptsDir + "Switch_Right_Stick.png"
@export var controlStickTextureRect: TextureRect
@export var rotatingArrow: TextureRect
var switchControlStickTimer := Timer.new()
var maxControlStickSwitches = 2
var currentControlStickSwitch = 0

@export var faceButtonsControl: Control
const upFaceButton = controllerPromptsDir + "Positional_Prompts_Up.png"
const rightFaceButton = controllerPromptsDir + "Positional_Prompts_Right.png"
const downFaceButton = controllerPromptsDir + "Positional_Prompts_Down.png"
const leftFaceButton = controllerPromptsDir + "Positional_Prompts_Left.png"
@export var faceButtonTextureRect: TextureRect
var switchFaceButtonTimer := Timer.new()
var maxFaceButtonSwitches = 8
var currentFaceButtonSwitch = 0

@export var dpadControl: Control
const upDpadButton = controllerPromptsDir + "XboxOne_Dpad_Up.png"
const rightDpadButton = controllerPromptsDir + "XboxOne_Dpad_Right.png"
const downDpadButton = controllerPromptsDir + "XboxOne_Dpad_Down.png"
const leftDpadButton = controllerPromptsDir + "XboxOne_Dpad_Left.png"
@export var dpadButtonTextureRect: TextureRect
var switchDpadButtonTimer := Timer.new()
var maxDpadButtonSwitches = 8
var currentDpadButtonSwitch = 0

@export var keysControl: Control
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
@export var upKeyTextureRect: TextureRect
@export var rightKeyTextureRect: TextureRect
@export var downKeyTextureRect: TextureRect
@export var leftKeyTextureRect: TextureRect
@export var upKeyHighlight: ColorRect
@export var rightKeyHighlight: ColorRect
@export var downKeyHighlight: ColorRect
@export var leftKeyHighlight: ColorRect
var switchKeysTimer := Timer.new()
var maxKeySwitches = 8
var currentKeySwitch = 0
var clockwise := true

enum {CONTROL_STICK, FACE_BUTTONS, DPAD, KEYS}
var currentPrompt: int

# Called when the node enters the scene tree for the first time.
func _ready():
	switchControlStickTimer.timeout.connect(switchControlStick)
	switchControlStickTimer.wait_time = 2
	switchControlStickTimer.one_shot = true
	add_child(switchControlStickTimer)
	switchControlStickTimer.start()

	switchFaceButtonTimer.timeout.connect(switchFaceButton)
	switchFaceButtonTimer.wait_time = 0.5
	switchFaceButtonTimer.one_shot = true
	add_child(switchFaceButtonTimer)

	switchDpadButtonTimer.timeout.connect(switchDpadButton)
	switchDpadButtonTimer.wait_time = 0.5
	switchDpadButtonTimer.one_shot = true
	add_child(switchDpadButtonTimer)

	switchKeysTimer.timeout.connect(switchKeys)
	switchKeysTimer.wait_time = 0.5
	switchKeysTimer.one_shot = true
	add_child(switchKeysTimer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if currentPrompt == CONTROL_STICK:
		if clockwise: rotatingArrow.rotation = PI*-switchControlStickTimer.time_left
		else: rotatingArrow.rotation = PI*switchControlStickTimer.time_left


func switchControlStick():
	if currentControlStickSwitch % 2 == 0:
		controlStickTextureRect.texture = preload(rightStick)
	else:
		controlStickTextureRect.texture = preload(leftStick)

	currentControlStickSwitch += 1
	if currentControlStickSwitch == maxControlStickSwitches: switchPrompt()
	else: switchControlStickTimer.start()


func switchFaceButton():
	match currentFaceButtonSwitch % 4:
		0:
			if clockwise: faceButtonTextureRect.texture = preload(rightFaceButton)
			else: faceButtonTextureRect.texture = preload(leftFaceButton)
		1:
			faceButtonTextureRect.texture = preload(downFaceButton)
		2:
			if clockwise: faceButtonTextureRect.texture = preload(leftFaceButton)
			else: faceButtonTextureRect.texture = preload(rightFaceButton)
		3:
			faceButtonTextureRect.texture = preload(upFaceButton)

	currentFaceButtonSwitch += 1
	if currentFaceButtonSwitch == maxFaceButtonSwitches: switchPrompt()
	else: switchFaceButtonTimer.start()


func switchDpadButton():
	match currentDpadButtonSwitch % 4:
		0:
			if clockwise: dpadButtonTextureRect.texture = preload(rightDpadButton)
			else: dpadButtonTextureRect.texture = preload(leftDpadButton)
		1:
			dpadButtonTextureRect.texture = preload(downDpadButton)
		2:
			if clockwise: dpadButtonTextureRect.texture = preload(leftDpadButton)
			else: dpadButtonTextureRect.texture = preload(rightDpadButton)
		3:
			dpadButtonTextureRect.texture = preload(upDpadButton)

	currentDpadButtonSwitch += 1
	if currentDpadButtonSwitch == maxDpadButtonSwitches: switchPrompt()
	else: switchDpadButtonTimer.start()


func switchKeys():
	match currentKeySwitch % 4:
		0:
			upKeyTextureRect.texture = preload(iKey)
			rightKeyTextureRect.texture = preload(lKey)
			downKeyTextureRect.texture = preload(kKey)
			leftKeyTextureRect.texture = preload(jKey)

			upKeyHighlight.hide()
			if clockwise: rightKeyHighlight.show()
			else: leftKeyHighlight.show()

		1:
			upKeyTextureRect.texture = preload(upArrowKey)
			rightKeyTextureRect.texture = preload(rightArrowKey)
			downKeyTextureRect.texture = preload(downArrowKey)
			leftKeyTextureRect.texture = preload(leftArrowKey)

			if clockwise: rightKeyHighlight.hide()
			else: leftKeyHighlight.hide()
			downKeyHighlight.show()

		2:
			upKeyTextureRect.texture = preload(eightKey)
			rightKeyTextureRect.texture = preload(sixKey)
			downKeyTextureRect.texture = preload(fiveKey)
			leftKeyTextureRect.texture = preload(fourKey)

			downKeyHighlight.hide()
			if clockwise: leftKeyHighlight.show()
			else: rightKeyHighlight.show()

		3:
			upKeyTextureRect.texture = preload(wKey)
			rightKeyTextureRect.texture = preload(dKey)
			downKeyTextureRect.texture = preload(sKey)
			leftKeyTextureRect.texture = preload(aKey)

			if clockwise: leftKeyHighlight.hide()
			else: rightKeyHighlight.hide()
			upKeyHighlight.show()


	currentKeySwitch += 1
	if currentKeySwitch == maxKeySwitches: switchPrompt()
	else: switchKeysTimer.start()


func switchPrompt():
	match currentPrompt:

		CONTROL_STICK:
			controlStickControl.hide()
			currentControlStickSwitch = 0
			faceButtonsControl.show()
			switchFaceButtonTimer.start()
			currentPrompt = FACE_BUTTONS

		FACE_BUTTONS:
			faceButtonsControl.hide()
			currentFaceButtonSwitch = 0
			dpadControl.show()
			switchDpadButtonTimer.start()
			currentPrompt = DPAD

		DPAD:
			dpadControl.hide()
			currentDpadButtonSwitch = 0
			keysControl.show()
			switchKeysTimer.start()
			currentPrompt = KEYS

		KEYS:
			clockwise = not clockwise
			keysControl.hide()
			currentKeySwitch = 0
			rotatingArrow.flip_h = not clockwise
			controlStickControl.show()
			switchControlStickTimer.start()
			currentPrompt = CONTROL_STICK

