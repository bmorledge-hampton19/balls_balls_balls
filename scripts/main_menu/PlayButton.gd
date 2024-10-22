class_name PlayButton
extends Node

@export var coolRainbowProgressCircle: TextureProgressBar

signal onFullProgressCircle()
var fillRate := 25.0
var emptyRate := 10.0
var active: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if len(PlayerManager.getActiveTeamColors()) < 2:
		coolRainbowProgressCircle.value -= emptyRate*delta
		if active:
			pass

	else:
		if not active:
			pass

		if coolRainbowProgressCircle.value >= coolRainbowProgressCircle.max_value: onFullProgressCircle.emit()

		if Input.is_action_pressed("PRIMARY_MENU_BUTTON"):
			coolRainbowProgressCircle.value += (fillRate*delta)
		else:
			coolRainbowProgressCircle.value -= emptyRate*delta
