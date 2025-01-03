class_name Trail
extends Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func updateColor(newColor: Color):
	material.set_shader_parameter("teamColor", newColor)
