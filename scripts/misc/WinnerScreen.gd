extends Node
@export var camera: Camera2D

@export var background: Background

@export var theBall: TheBall

@export var ballPrefab: PackedScene
@export var ballsControl: Control
@export var trailPrefab: PackedScene
@export var trailsCG: CanvasGroup
@export var ballGoalsTextPrefab: PackedScene

@export var winningTeamText: Label
@export var restartPromptText: Label
@export var restartPrormptSlash: Label

func createBall(position := Vector2(480,270), direction := Vector2(0,1),
				speed: float = 100, additiveAcceleration: float = 0,
				behavior := Ball.Behavior.CONSTANT_LINEAR, behaviorIntensity = Ball.SMOOTH,
				color := Color.WHITE):

	var newBall: Ball = ballPrefab.instantiate()
	var newTrail: Trail = trailPrefab.instantiate()
	newBall.trail = newTrail
	ballsControl.add_child(newBall)
	trailsCG.add_child(newTrail)

	newBall.position = position
	newBall.baseSpeedDirection = direction
	newBall.baseSpeed = speed
	newBall.additiveAcceleration = additiveAcceleration
	newBall.behavior = behavior
	newBall.behaviorIntensity = behaviorIntensity
	newBall.updateColor(color)
	newBall.onBallHitWall.connect(background.spawnBallArc)

# Called when the node enters the scene tree for the first time.
func _ready():

	print(Time.get_ticks_msec())

	ResourceLoader.load_threaded_request("res://scenes/MainMenu.tscn")
	ScreenShaker.setCamera(camera)

	for teamColor in PlayerManager.activePlayersByTeamColor:
		for player in PlayerManager.activePlayersByTeamColor[teamColor]:
			player = player as Player
			var newBall: Ball = ballPrefab.instantiate()
			var newTrail: Trail = trailPrefab.instantiate()
			newBall.trail = newTrail
			ballsControl.add_child(newBall)
			trailsCG.add_child(newTrail)

			newBall.position = Vector2(480,270)
			if teamColor == PlayerManager.winningTeamColor: newBall.radius = 10
			else: newBall.radius = 5
			if randi_range(0,1): newBall.baseSpeedDirection = Vector2.from_angle(randf_range(0.1,PI-0.1))
			else: newBall.baseSpeedDirection = Vector2.from_angle(randf_range(0.1,PI-0.1)*-1)
			newBall.baseSpeed = 100
			newBall.additiveAcceleration = 5
			newBall.updateColor(player.teamColor)
			newBall.ballSprite.texture = player.texture
			newBall.onBallHitWall.connect(background.spawnBallArc)

			var ballGoalsText: Label = ballGoalsTextPrefab.instantiate()
			newBall.add_child(ballGoalsText)
			ballGoalsText.text = "Goals: " + str(player.goals)
			ballGoalsText.add_theme_color_override("font_color", player.teamColor)

	theBall.color = PlayerManager.winningTeamColor
	winningTeamText.text = PlayerManager.teamColorNames[PlayerManager.winningTeamColor] + " TEAM WINS!"
	winningTeamText.add_theme_color_override("font_color", PlayerManager.winningTeamColor)
	restartPromptText.add_theme_color_override("font_color", PlayerManager.winningTeamColor)
	restartPrormptSlash.add_theme_color_override("font_color", PlayerManager.winningTeamColor)


func _process(_delta):
	if Input.is_action_just_pressed("PRIMARY_MENU_BUTTON"):
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/MainMenu.tscn"))
