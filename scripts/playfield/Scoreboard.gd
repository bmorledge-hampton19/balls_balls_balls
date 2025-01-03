class_name Scoreboard
extends Control

@export var textControl: Control
@export var title: Label
@export var livesCounterPrefab: PackedScene
@export var goalsCounterPrefab: PackedScene

var counters: Array[Control]
var labelFading: bool
var labelFadeDuration: float
var labelFadeTimeRemaining: float

var livesCounters: Dictionary
var goalsCounters: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	counters.append(title)

func _process(delta):
	if labelFading:
		labelFadeTimeRemaining -= delta
		if labelFadeTimeRemaining <= 0:
			labelFading = false
			labelFadeTimeRemaining = 0
		var labelAlpha = labelFadeTimeRemaining/labelFadeDuration
		for counter in counters:
			counter.modulate = Color(counter.modulate, labelAlpha)

func beginFade(duration: float = 4.0):
	labelFading = true
	labelFadeDuration = duration
	labelFadeTimeRemaining = duration

func addLivesCounter(color: Color, team: Team):
	var newCounter: LivesCounter = livesCounterPrefab.instantiate()
	textControl.add_child(newCounter)
	newCounter.updateText(team.livesRemaining)
	newCounter.setColor(color)
	team.onLivesChanged.connect(newCounter.updateText)
	counters.append(newCounter)
	livesCounters[team] = newCounter

func addGoalsCounter(player: Player):
	var newCounter: GoalsCounter = goalsCounterPrefab.instantiate()
	textControl.add_child(newCounter)
	newCounter.updateText(player.goals)
	newCounter.setTexture(player.texture)
	newCounter.setTeamColor(player.teamColor)
	player.onGoal.connect(newCounter.updateText)
	counters.append(newCounter)
	goalsCounters[player] = newCounter

func fadeOutLivesCounter(team: Team):
	livesCounters[team].fadeOut()
	counters.erase(livesCounters[team])
	livesCounters.erase(team)