class_name MainMenu
extends Node

@export var mainViewport: Control

@export var theBallZone: Control
@export var trailsCanvasGroup: CanvasGroup
@export var wallPrefab: PackedScene
@export var ballPrefab: PackedScene
@export var trailPrefab: PackedScene
@export var playerSelectorPrefab: PackedScene
@export var playerSelectorGrid: GridContainer

@export var playButton: PlayButton

var playerSelectors: Array[PlayerSelector]
var ballsByPlayer: Dictionary

func attemptAddPlayer(inputSet: InputSets.InputSet, _direction: bool, activePlayer: Player = null):
	if PauseManager.paused: return
	if activePlayer == null and inputSet.assignedPlayer != null and inputSet.assignedPlayer.active: return
	if playerSelectors[-1].player != null: return
	playerSelectors[-1].transitionToPlayerDisplay(inputSet, activePlayer)

	var newBall: Ball = ballPrefab.instantiate()
	var newTrail: Trail = trailPrefab.instantiate()
	newBall.trail = newTrail
	newBall.ballSprite.texture = playerSelectors[-1].player.texture
	newBall.updateColor(playerSelectors[-1].player.teamColor)
	newBall.radius = 10
	newBall.global_position = Vector2(480,270)
	ballsByPlayer[playerSelectors[-1].player] = newBall

	theBallZone.add_child(newBall)
	trailsCanvasGroup.add_child(newTrail)
	playerSelectors[-1].playerDisplay.ball = newBall

	newBall.baseSpeed = 200

	if randi_range(0,1): newBall.baseSpeedDirection = Vector2.from_angle(randf_range(0.1,PI-0.1))
	else: newBall.baseSpeedDirection = Vector2.from_angle(randf_range(0.1,PI-0.1)*-1)

	if len(playerSelectors) < 16: addPlayerSelector()

func addPlayerSelector():
	var playerSelector := playerSelectorPrefab.instantiate()
	playerSelectorGrid.add_child(playerSelector)
	playerSelectors.append(playerSelector)
	playerSelector.playerDisplay.closeButton.pressed.connect(func(): removePlayerSelector(playerSelector))

func removePlayerSelector(playerSelector: PlayerSelector):
	print("Removing...")
	ballsByPlayer[playerSelector.player].queue_free()
	ballsByPlayer.erase(playerSelector.player)
	playerSelectors.erase(playerSelector)
	PlayerManager.deactivatePlayer(playerSelector.player)
	playerSelector.queue_free()
	if playerSelectors[-1].player != null: addPlayerSelector()

func startGame():
	print(Time.get_ticks_msec())
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/Playfield.tscn"))
	

# Called when the node enters the scene tree for the first time.
func _ready():
	addPlayerSelector()
	InputSets.onAnyCircle.connect(attemptAddPlayer)
	playButton.onFullProgressCircle.connect(startGame)
	ResourceLoader.load_threaded_request("res://scenes/Playfield.tscn")
	ResourceLoader.load_threaded_request("res://scenes/Credits.tscn")
	ResourceLoader.load_threaded_request("res://scenes/Settings.tscn")

	PauseManager.pausable = true

	for teamColor in PlayerManager.activePlayersByTeamColor:
		for player in PlayerManager.activePlayersByTeamColor[teamColor]:
			attemptAddPlayer(player.inputSet, true, player)

func _process(_delta):
	if Input.is_action_just_pressed("SECONDARY_MENU_BUTTON"):
		var pauseMenu := PauseManager.pause()
		pauseMenu.initOptions(["Settings", "Credits", "Resume", "Quit Game"],
							  [transitionToSettings, transitionToCredits, PauseManager.unpause, get_tree().quit])
		mainViewport.add_child(pauseMenu)


func transitionToSettings():
	PauseManager.unpause(true)
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/Settings.tscn"))

func transitionToCredits():
	PauseManager.unpause()
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/Credits.tscn"))
