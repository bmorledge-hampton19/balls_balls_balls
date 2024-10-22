class_name MainMenu
extends Node

@export var theBallZone: Control
@export var trailsControl: Control
@export var wallPrefab: PackedScene
@export var ballPrefab: PackedScene
@export var trailPrefab: PackedScene
@export var playerSelectorPrefab: PackedScene
@export var playerSelectorGrid: GridContainer

@export var playButton: PlayButton
@export var playfieldScene: PackedScene

var playerSelectors: Array[PlayerSelector]
var ballsByPlayer: Dictionary

func attemptAddPlayer(inputSet: InputSets.InputSet, _direction: bool):
	if inputSet.assignedPlayer != null and inputSet.assignedPlayer.active: return
	if playerSelectors[-1].player != null: return
	playerSelectors[-1].transitionToPlayerDisplay(inputSet)

	var newBall: Ball = ballPrefab.instantiate()
	var newTrail: Trail = trailPrefab.instantiate()
	newBall.trail = newTrail
	newBall.ballSprite.texture = playerSelectors[-1].player.texture
	newBall.updateColor(playerSelectors[-1].player.teamColor)
	newBall.radius = 10
	newBall.global_position = Vector2(480,270)
	ballsByPlayer[playerSelectors[-1].player] = newBall

	theBallZone.add_child(newBall)
	trailsControl.add_child(newTrail)
	playerSelectors[-1].playerDisplay.ball = newBall

	newBall.baseSpeed = 200

	if randi_range(0,1): newBall.direction = Vector2.from_angle(randf_range(0.1,PI))
	else: newBall.direction = Vector2.from_angle(randf_range(0.1,PI)*-1)

	if len(playerSelectors) < 16: addPlayerSelector()

func addPlayerSelector():
	var playerSelector := playerSelectorPrefab.instantiate()
	playerSelectorGrid.add_child(playerSelector)
	playerSelectors.append(playerSelector)
	playerSelector.playerDisplay.closeButton.pressed.connect(func(): removePlayerSelector(playerSelector))

func removePlayerSelector(playerSelector: PlayerSelector):
	ballsByPlayer[playerSelector.player].queue_free()
	ballsByPlayer.erase(playerSelector.player)
	playerSelectors.erase(playerSelector)
	PlayerManager.deactivatePlayer(playerSelector.player)
	playerSelector.queue_free()
	if playerSelectors[-1].player != null: addPlayerSelector()

func startGame():
	ResourceLoader.load_threaded_get(playfieldScene.resource_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	addPlayerSelector()
	InputSets.onAnyCircle.connect(attemptAddPlayer)
	playButton.onFullProgressCircle.connect(startGame)
	ResourceLoader.load_threaded_request(playfieldScene.resource_path)
