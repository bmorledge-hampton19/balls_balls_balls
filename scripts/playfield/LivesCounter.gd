class_name LivesCounter
extends Control

@export var mainCounter: Label
@export var bonusCounter: Label

var showingBonus: bool
var currentBonus: int
var bonusDuration: float
var bonusTimeRemaining: float

var fading: bool
var fadeDuration: float
var fadeTimeRemaining: float

# Called when the node enters the scene tree for the first time.
func _ready():
	bonusCounter.self_modulate.a = 0

func _process(delta):
	if showingBonus:
		bonusTimeRemaining -= delta
		if bonusTimeRemaining < 0:
			showingBonus = false
			bonusTimeRemaining = 0
			currentBonus = 0
		bonusCounter.self_modulate.a = bonusTimeRemaining/bonusDuration

	if fading:
		fadeTimeRemaining -= delta
		if fadeTimeRemaining < 0:
			fading = false
			fadeTimeRemaining = 0
			queue_free()
		modulate.a = fadeTimeRemaining/fadeDuration
		custom_minimum_size.y = 28.0*fadeTimeRemaining/fadeDuration


func setColor(p_color: Color):
	mainCounter.add_theme_color_override("font_color", p_color)
	bonusCounter.add_theme_color_override("font_color", p_color)

func updateText(newText):
	mainCounter.text = str(newText)

func showBonusCounter(bonusLives: int):
	currentBonus += bonusLives
	bonusCounter.text = "+" + str(currentBonus)
	showingBonus = true
	bonusDuration = 4
	bonusTimeRemaining = bonusDuration

func fadeOut(duration: float = 2.0):
	fading = true
	fadeDuration = duration
	fadeTimeRemaining = duration
