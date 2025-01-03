class_name PlayButton
extends Node

@export var coolRainbowProgressCircle: TextureProgressBar
@export var backgroundBall: ColorRect
@export var playText: Label
@export var addTeamsLabel: Control
@export var buttonPrompts: Control

signal onFullProgressCircle()
var fillRate := 25.0
var emptyRate := 10.0
var active: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	if len(PlayerManager.getActiveTeamColors()) < 2: deactivateButton()
	else: activateButton()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if len(PlayerManager.getActiveTeamColors()) < 2:
		coolRainbowProgressCircle.value -= emptyRate*delta
		if active:
			deactivateButton()

	else:
		if not active:
			activateButton()

		if coolRainbowProgressCircle.value >= coolRainbowProgressCircle.max_value:
			print("Go!")
			onFullProgressCircle.emit()

		if Input.is_action_just_pressed("PRIMARY_MENU_BUTTON"):
			coolRainbowProgressCircle.value += 10
		elif Input.is_action_pressed("PRIMARY_MENU_BUTTON"):
			coolRainbowProgressCircle.value += (fillRate*delta)
		else:
			coolRainbowProgressCircle.value -= emptyRate*delta


func deactivateButton():
	addTeamsLabel.show()
	buttonPrompts.hide()

	backgroundBall.color = Color.LIGHT_GRAY
	playText.add_theme_color_override("font_color", Color.DARK_GRAY)

	active = false


func activateButton():
	addTeamsLabel.hide()
	buttonPrompts.show()

	backgroundBall.color = Color.WHITE
	playText.add_theme_color_override("font_color", Color.BLACK)

	active = true