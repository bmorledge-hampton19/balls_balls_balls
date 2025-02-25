class_name Credits
extends Control
@export var camera: Camera2D
@export var background: Background

@export var ballPrefab: PackedScene
@export var ballsControl: Control
@export var trailPrefab: PackedScene
@export var trailsCG: CanvasGroup
@export var ballGoalsTextPrefab: PackedScene

var names: Array[String] = [
	"test",
]
var colors: Array[Color] = [
	Color.BLUE,
]

# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceLoader.load_threaded_request("res://scenes/MainMenu.tscn")
	for i in range(len(names)):
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

		var ballGoalsText: Label = ballGoalsTextPrefab.instantiate()
		newBall.add_child(ballGoalsText)
		ballGoalsText.text = names[i]
		ballGoalsText.add_theme_color_override("font_color", colors[i])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("SECONDARY_MENU_BUTTON"):
		returnToMainMenu()

func returnToMainMenu():
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/MainMenu.tscn"))