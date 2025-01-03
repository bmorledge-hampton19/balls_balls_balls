class_name PlayerSelector
extends Node

@export var prompts: Prompts
@export var playerDisplay: PlayerDisplay

var player: Player = null

func transitionToPlayerDisplay(inputSet: InputSets.InputSet, activePlayer: Player = null):
	prompts.hide()
	if activePlayer == null: player = PlayerManager.getPlayerForInputSet(inputSet)
	else: player = activePlayer
	playerDisplay.initPlayerDisplay(player)
	playerDisplay.show()
	playerDisplay.set_process(true)
	playerDisplay.bumper.activate()

func transitionToPrompts():
	playerDisplay.hide()
	playerDisplay.set_process(false)
	playerDisplay.bumper.deactivate()
	PlayerManager.deactivatePlayer(player)
	player = null
	prompts.hide()

# Called when the node enters the scene tree for the first time.
func _ready():
	prompts.show()
	playerDisplay.hide()
	playerDisplay.set_process(false)
	playerDisplay.bumper.deactivate()
