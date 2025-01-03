class_name FinalTwoLives
extends Control

@export var livesLabel: Label
@export var noise: FastNoiseLite

var basePosition: Vector2

class Shake:
	var initialStrength: float
	var duration: float
	var timeRemaining: float
	func _init(p_initialStrength, p_duration):
		if p_initialStrength < 0: p_initialStrength = 0
		initialStrength = p_initialStrength
		duration = p_duration
		timeRemaining = duration
var shakes: Array[Shake]

var noisePos: float = 0
var shakeSpeed: float = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	basePosition = livesLabel.position
	noise.seed = randi()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var shakeStrength: float = 0
	for shake in shakes:
		var shakeFraction: float = 1
		if shake.duration != -1:
			shake.timeRemaining -= delta
			if shake.timeRemaining <= 0:
				shake.timeRemaining = 0
			shakeFraction = shake.timeRemaining/shake.duration
		shakeStrength += (shake.initialStrength * shakeFraction)**2
	shakeStrength = sqrt(shakeStrength)
	if shakeStrength > 0:
		noisePos += delta*shakeSpeed
		livesLabel.position = basePosition + Vector2(
			noise.get_noise_2d(0, noisePos)*shakeStrength,
			noise.get_noise_2d(100, noisePos)*shakeStrength
		)

	for i in range(len(shakes)-1,-1,-1):
		if shakes[i].timeRemaining == 0:
			shakes.remove_at(i)


func addShake(initialShakeStrength: float = 10, shakeDuration: float = 2) -> Shake:
	var newShake: Shake = Shake.new(initialShakeStrength, shakeDuration)
	shakes.append(newShake)
	return newShake

func removeShake(shake: Shake):
	shakes.erase(shake)

func clearShakes():
	shakes.clear()


func updateText(newText):
	livesLabel.text = str(newText)