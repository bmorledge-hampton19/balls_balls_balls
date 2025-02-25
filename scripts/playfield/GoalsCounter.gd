class_name GoalsCounter
extends Control

@export var colorRect: ColorRect
@export var textureRect: TextureRect
@export var label: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setTexture(texture: Texture):
	textureRect.texture = texture

func setTeamColor(color: Color):
	colorRect.color = color
	label.add_theme_color_override("font_color", color)

func updateText(newText):
	label.text = str(newText)
