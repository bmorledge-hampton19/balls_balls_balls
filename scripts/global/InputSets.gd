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
	var totalTimePressed: Dictionary
	var nextJustPressedTime: Dictionary
	var inputJustPressed: Dictionary

	var timeSinceLastClockwiseInput: float
	var nextClockwiseInput: String
	var consecutiveClockwiseInputs: int = 0
	var timeSinceLastCounterclockwiseInput: float
	var nextCounterclockwiseInput: String
	var consecutiveCounterclockwiseInputs: int = 0
	var inputsRequiredForCircle: int = 4
	signal onCompletedCircle(inputSet: InputSet, clockwise: bool)

	var device: int

	var assignedPlayer: Player

	func _init(p_name, p_device):

		name = p_name
		if "JOYSTICK" in name: inputsRequiredForCircle = 5

		upInput = name + "_UP"
		rightInput = name + "_RIGHT"
		downInput = name + "_DOWN"
		leftInput = name + "_LEFT"

		inputArray = [upInput, rightInput, downInput, leftInput]

		for input in inputArray:
			inputPressed[input] = false
			inputJustPressed[input] = false



		device = p_device

	func processInput(delta: float):

		for input in inputArray:
			inputPressed[input] = MultiplayerInput.is_action_pressed(device, input)

			if inputPressed[input]:
				if totalTimePressed[input] == 0:
					inputJustPressed[input] = true
					nextJustPressedTime[input] = 0.5
				elif totalTimePressed[input] >= nextJustPressedTime[input]:
					inputJustPressed[input] = true
					nextJustPressedTime[input] = nextJustPressedTime[input] + 0.2
				else:
					inputJustPressed[input] = false
				totalTimePressed[input] += delta
			else:
				totalTimePressed[input] = 0
				inputJustPressed[input] = false

		timeSinceLastClockwiseInput += delta
		timeSinceLastCounterclockwiseInput += delta
		if timeSinceLastClockwiseInput > 0.75: consecutiveClockwiseInputs = 0
		if timeSinceLastCounterclockwiseInput > 0.75: consecutiveCounterclockwiseInputs = 0

		var justPressedInputs: Array[String] = []
		for input in inputArray:
			if MultiplayerInput.is_action_just_pressed(device, input): justPressedInputs.append(input)

		while consecutiveClockwiseInputs > 0 and justPressedInputs.size() > 0:

			if nextClockwiseInput in justPressedInputs:

				timeSinceLastClockwiseInput = 0
				justPressedInputs.erase(nextClockwiseInput)
				consecutiveClockwiseInputs += 1

				if consecutiveClockwiseInputs == inputsRequiredForCircle:
					onCompletedCircle.emit(self, true)
					consecutiveClockwiseInputs = 0
				else:
					match nextClockwiseInput:
						upInput: nextClockwiseInput = rightInput
						rightInput: nextClockwiseInput = downInput
						downInput: nextClockwiseInput = leftInput
						leftInput: nextClockwiseInput = upInput

			else:
				consecutiveClockwiseInputs = 0
		
		while consecutiveCounterclockwiseInputs > 0 and justPressedInputs.size() > 0:

			if nextCounterclockwiseInput in justPressedInputs:

				timeSinceLastCounterclockwiseInput = 0
				justPressedInputs.erase(nextCounterclockwiseInput)
				consecutiveCounterclockwiseInputs += 1

				if consecutiveCounterclockwiseInputs == inputsRequiredForCircle:
					onCompletedCircle.emit(self, false)
					consecutiveCounterclockwiseInputs = 0
				else:
					match nextCounterclockwiseInput:
						upInput: nextCounterclockwiseInput = leftInput
						rightInput: nextCounterclockwiseInput = upInput
						downInput: nextCounterclockwiseInput = rightInput
						leftInput: nextCounterclockwiseInput = downInput

			else:
				consecutiveCounterclockwiseInputs = 0

		if consecutiveClockwiseInputs == 0 and justPressedInputs.size() > 0:
			timeSinceLastClockwiseInput = 0
			for inputIndex in range(3,-1,-1):
				if inputArray[inputIndex] in justPressedInputs:
					if consecutiveClockwiseInputs == 0: nextClockwiseInput = inputArray[inputIndex - 3]
					consecutiveClockwiseInputs += 1
				elif consecutiveClockwiseInputs > 0: break
		
		if consecutiveCounterclockwiseInputs == 0 and justPressedInputs.size() > 0:
			timeSinceLastCounterclockwiseInput = 0
			for inputIndex in range(4):
				if inputArray[inputIndex] in justPressedInputs:
					if consecutiveCounterclockwiseInputs == 0: nextCounterclockwiseInput = inputArray[inputIndex - 1]
					consecutiveCounterclockwiseInputs += 1
				elif consecutiveCounterclockwiseInputs > 0: break


	func assignPlayer(player: Player):
		assignedPlayer = player

	func unassignPlayer():
		assignedPlayer = null

var inputSets: Array[InputSet]
signal onAnyCircle(inputSet: InputSet, clockwise: bool)

func _ready():

	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

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
			func(iS: InputSet, clockwise: bool): onAnyCircle.emit(iS, clockwise)
		)

	onAnyCircle.connect(
		func(iS: InputSet, clockwise):
			if clockwise: print(iS.name + " on input device " + str(iS.device) + " completed a clockwise circle!")
			else: print(iS.name + " on input device " + str(iS.device) + " completed a counterclockwise circle!")

	)

func _process(delta):
	var connectedJoypads = Input.get_connected_joypads()

	for inputSet in inputSets:
		if inputSet.device in connectedJoypads or inputSet.device == -1: inputSet.processInput(delta)
