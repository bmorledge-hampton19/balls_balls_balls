class_name Credits
extends Control
@export var camera: Camera2D
@export var background: Background

@export var ballPrefab: PackedScene
@export var ballsControl: Control
@export var trailPrefab: PackedScene
@export var trailsCG: CanvasGroup
@export var ballGoalsTextPrefab: PackedScene

var topTexts: Array[String] = [
	"Sound Effects", "Music", "Controller Icons", "Vaguely Circular Images",
	"Emotional Support Humans", "Emotional Support Humans", "Emotional Support Humans",
	"Multiplayer Input System", "Engine", "Font",
]
var bottomTexts: Array[String] = [
	"jfxr.frozenfractal.com", "beepbox.co", "thoseawesomeguys.com/prompts", "cleanpng.com",
	"The M-H Gang", "The Boys", "The WSU Community",
	"github.com/matjlars", "godotengine.org/license", "Iceland",
]
var colors: Array[Color] = [
	Color.WHITE, Color.PURPLE, Color.ORANGE, Color.LIGHT_GREEN,
	Color.GOLDENROD, Color.CRIMSON, Color.DARK_GRAY,
	Color.SLATE_GRAY, Color8(68, 125, 175), Color.WEB_GREEN,
]
var positions: Array[Vector2] = [
	Vector2(150, 115), Vector2(350, 115), Vector2(550, 115), Vector2(750, 115),
	Vector2(200, 300), Vector2(460, 300), Vector2(700, 300),
	Vector2(200, 460), Vector2(460, 460), Vector2(700, 460)
]

# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceLoader.load_threaded_request("res://scenes/MainMenu.tscn")
	for i in range(len(topTexts)):
		var newBall: Ball = ballPrefab.instantiate()
		var newTrail: Trail = trailPrefab.instantiate()
		newBall.trail = newTrail
		ballsControl.add_child(newBall)
		trailsCG.add_child(newTrail)

		newBall.position = Vector2(480,150)
		newBall.radius = 10
		if randi_range(0,1): newBall.baseSpeedDirection = Vector2.from_angle(randf_range(0.1,PI-0.1))
		else: newBall.baseSpeedDirection = Vector2.from_angle(randf_range(0.1,PI-0.1)*-1)
		newBall.baseSpeed = 100
		newBall.additiveAcceleration = 5
		newBall.updateColor(colors[i])
		newBall.onBallHitWall.connect(background.spawnBallArc)

		if topTexts[i]:
			var topText: Label = ballGoalsTextPrefab.instantiate()
			newBall.add_child(topText)
			topText.position.y -= 44
			topText.text = topTexts[i]
			topText.add_theme_color_override("font_color", colors[i])
		
		if bottomTexts[i]:
			var bottomText: Label = ballGoalsTextPrefab.instantiate()
			newBall.add_child(bottomText)
			bottomText.text = bottomTexts[i]
			bottomText.add_theme_color_override("font_color", colors[i])
		
		newBall.position = positions[i]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("SECONDARY_MENU_BUTTON"):
		returnToMainMenu()

func returnToMainMenu():
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/MainMenu.tscn"))