extends Node

const FACE_BUTTONS = "FACE_BUTTONS"
const DPAD = "DPAD"
const LEFT_JOYSTICK = "LEFT_JOYSTICK"
const RIGHT_JOYSTICK = "RIGHT_JOYSTICK"
const WASD = "WASD"
const IJKL = "IJKL"
const ARROW_KEYS = "ARROW_KEYS"
const NUMPAD = "NUMPAD"

const JOYPAD_INPUT_SET_NAMES = [FACE_BUTTONS, DPAD, LEFT_JOYSTICK, RIGHT_JOYSTICK]
const KEYBOARD_INPUT_SET_NAMES = [WASD, IJKL, ARROW_KEYS, NUMPAD]

class InputSet:

	var name: String

	var upInput: String
	var rightInput: String
	var downInput: String
	var leftInput: String
	var inputArray: Array[String]

	var inputPressed: Dictionary

	var timeSinceLastCircleInput: float
	var nextCircleInput: String
	var consecutiveCircleInputs: int = 0
	signal onCompletedCircle(inputSet: InputSet)

	var device: int

	var assignedPlayer: Player

	func _init(p_name, p_device):

		name = p_name

		upInput = name + "_UP"
		rightInput = name + "_RIGHT"
		downInput = name + "_DOWN"
		leftInput = name + "_LEFT"

		inputArray = [upInput, rightInput, downInput, leftInput]

		inputPressed[upInput] = false
		inputPressed[downInput] = false
		inputPressed[rightInput] = false
		inputPressed[leftInput] = false

		device = p_device

	func processInput(delta: float):

		inputPressed[upInput] = MultiplayerInput.is_action_pressed(device, upInput)
		inputPressed[downInput] = MultiplayerInput.is_action_pressed(device, downInput)
		inputPressed[rightInput] = MultiplayerInput.is_action_pressed(device, rightInput)
		inputPressed[leftInput] = MultiplayerInput.is_action_pressed(device, leftInput)

		timeSinceLastCircleInput += delta

		var justPressedInputs: Array[String] = []
		for input in inputArray:
			if MultiplayerInput.is_action_just_pressed(device, input): justPressedInputs.append(input)

		if timeSinceLastCircleInput > 0.75: consecutiveCircleInputs = 0

		while consecutiveCircleInputs > 0 and justPressedInputs.size() > 0:

			if nextCircleInput in justPressedInputs:

				timeSinceLastCircleInput = 0
				justPressedInputs.erase(nextCircleInput)
				consecutiveCircleInputs += 1

				if consecutiveCircleInputs == 5:
					onCompletedCircle.emit(self)
					consecutiveCircleInputs = 0
				else:
					match nextCircleInput:
						upInput: nextCircleInput = rightInput
						rightInput: nextCircleInput = downInput
						downInput: nextCircleInput = leftInput
						leftInput: nextCircleInput = upInput

			else:
				consecutiveCircleInputs = 0
		
		if consecutiveCircleInputs == 0 and justPressedInputs.size() > 0:
			timeSinceLastCircleInput = 0
			for inputIndex in range(3,-1,-1):
				if inputArray[inputIndex] in justPressedInputs:
					if consecutiveCircleInputs == 0: nextCircleInput = inputArray[inputIndex - 3]
					consecutiveCircleInputs += 1
				elif consecutiveCircleInputs > 0: break


	func assignPlayer(player: Player):
		assignedPlayer = player

	func unassignPlayer():
		assignedPlayer = null

var inputSets: Array[InputSet]
signal onAnyCircle(inputSet: InputSet)

func _ready():
	inputSets.append(InputSet.new(WASD, -1))
	inputSets.append(InputSet.new(IJKL, -1))
	inputSets.append(InputSet.new(ARROW_KEYS, -1))
	inputSets.append(InputSet.new(NUMPAD, -1))
	for i in range(8):
		inputSets.append(InputSet.new(FACE_BUTTONS, i))
		inputSets.append(InputSet.new(DPAD, i))
		inputSets.append(InputSet.new(LEFT_JOYSTICK, i))
		inputSets.append(InputSet.new(RIGHT_JOYSTICK, i))

	for inputSet in inputSets:
		inputSet.onCompletedCircle.connect(
			func(iS: InputSet): onAnyCircle.emit(iS)
		)

	onAnyCircle.connect(
		func(iS: InputSet): print(iS.name + " on input device " + str(iS.device) + " completed a circle!")
	)

func _process(delta):
	var connectedJoypads = Input.get_connected_joypads()

	for inputSet in inputSets:
		if inputSet.device in connectedJoypads or inputSet.device == -1: inputSet.processInput(delta)
