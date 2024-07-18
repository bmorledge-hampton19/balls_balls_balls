class_name GameManager
extends Control

@export var leftScoreboard: Scoreboard
@export var rightScoreboard: Scoreboard

@export var wallPrefab: PackedScene
var walls: Array[Wall]

@export var teamPrefab: PackedScene
var teams: Array[Team]

@export var bumperPrefab: PackedScene
var bumpers: Array[Bumper]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
