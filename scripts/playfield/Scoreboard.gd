class_name Scoreboard
extends Control

@export var textControl: Control
@export var livesCounterPrefab: PackedScene
@export var goalsCounterPrefab: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func addLivesCounter(color: Color, team: Team):
	var newCounter: LivesCounter = livesCounterPrefab.instantiate()
	textControl.add_child(newCounter)
	newCounter.updateText(team.livesRemaining)
	newCounter.setColor(color)
	team.onLivesChanged.connect(newCounter.updateText)
