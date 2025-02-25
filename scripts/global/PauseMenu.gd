class_name PauseMenu
extends Control

@export var masterInputSelector: MasterInputSelector

@export var optionsContainer: VBoxContainer
@export var optionPrefab: PackedScene

var options: Array[PauseMenuOption]
var highlightedOptionIndex: int
var firstFrame := true

# Called when the node enters the scene tree for the first time.
func _ready():
	masterInputSelector.shadedBackground.hide()


func initOptions(names: Array[String], functions: Array[Callable]):
	
	for i in range(len(names)):
		var option: PauseMenuOption = optionPrefab.instantiate()
		option.label.text = names[i]
		option.onConfirmOption.connect(functions[i])
		optionsContainer.add_child(option)
		options.append(option)
		option.lowlight()
	
	options[0].highlight()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

	if Input.is_action_just_pressed("SECONDARY_MENU_BUTTON"): PauseManager.unpause()

	var masterInputSet := masterInputSelector.masterInputSet
	if masterInputSet == null:
		return
	elif firstFrame:
		firstFrame = false
		return

	if masterInputSet.inputJustPressed[masterInputSet.rightInput]:
		options[highlightedOptionIndex].bumpRight()

	if masterInputSet.inputJustPressed[masterInputSet.leftInput]:
		options[highlightedOptionIndex].bumpLeft()

	if masterInputSet.inputJustPressed[masterInputSet.downInput]:
		options[highlightedOptionIndex].lowlight()
		highlightedOptionIndex = wrapi(highlightedOptionIndex+1, 0, len(options))
		options[highlightedOptionIndex].highlight()

	if masterInputSet.inputJustPressed[masterInputSet.upInput]:
		options[highlightedOptionIndex].lowlight()
		highlightedOptionIndex = wrapi(highlightedOptionIndex-1, 0, len(options))
		options[highlightedOptionIndex].highlight()
