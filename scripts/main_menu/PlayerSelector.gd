class_name PlayerSelector
extends Node

@export var prompts: Prompts
@export var playerDisplay: PlayerDisplay

var player: Player = null

func transitionToPlayerDisplay(inputSet: InputSets.InputSet):
	prompts.hide()
	player = PlayerManager.getPlayerForInputSet(inputSet)
	playerDisplay.initPlayerDisplay(player)
	playerDisplay.show()
	playerDisplay.set_process(true)

func transitionToPrompts():
	playerDisplay.hide()
	playerDisplay.set_process(false)
	PlayerManager.deactivatePlayer(player)
	player = null
	prompts.hide()

# Called when the node enters the scene tree for the first time.
func _ready():
	prompts.show()
	playerDisplay.hide()
	playerDisplay.set_process(false)
