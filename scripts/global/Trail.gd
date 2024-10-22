class_name Trail
extends Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func updateColor(newColor: Color):
	gradient.set_color(0, Color(newColor, 0.1))
	gradient.set_color(1, Color(newColor, 1))
	gradient.set_color(2, Color(newColor, 1))
