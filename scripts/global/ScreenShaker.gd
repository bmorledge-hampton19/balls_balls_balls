extends Node

@export var noise: FastNoiseLite

var _camera: Camera2D

class Shake:
	var initialStrength: float
	var duration: float
	var timeRemaining: float
	func _init(p_initialStrength, p_duration):
		if p_initialStrength < 0: p_initialStrength = 0
		initialStrength = p_initialStrength
		duration = p_duration
		timeRemaining = duration

var _shakes: Array[Shake]

var noisePos: float = 0
var shakeSpeed: float = 1

func setCamera(newCamera: Camera2D):
	_camera = newCamera

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if _camera == null: return

	var shakeStrength: float = 0
	for shake in _shakes:
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
		_camera.offset = Vector2(
			noise.get_noise_2d(0, noisePos)*shakeStrength,
			noise.get_noise_2d(100, noisePos)*shakeStrength
		)

	for i in range(len(_shakes)-1,-1,-1):
		if _shakes[i].timeRemaining == 0:
			_shakes.remove_at(i)

func addShake(initialShakeStrength: float = 20, shakeDuration: float = 1) -> Shake:
	var newShake: Shake = Shake.new(initialShakeStrength, shakeDuration)
	_shakes.append(newShake)
	return newShake

func removeShake(shake: Shake):
	_shakes.erase(shake)

func clearShakes():
	_shakes.clear()
