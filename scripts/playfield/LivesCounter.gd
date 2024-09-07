class_name LivesCounter
extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func setColor(p_color: Color):
	add_theme_color_override("font_color", p_color)

func updateText(newText):
	text = str(newText)
