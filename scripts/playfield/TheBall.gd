class_name TheBall
extends ColorRect

@export var inwardPulsesControl: Control
@export var inwardPulsePrefab: PackedScene

var center: float = 270:
	set(value):
		center = value
		position.y = center - radius
var radius: float = 54:
	set(value):
		radius = value
		size = Vector2(radius*2, radius*2)
		position = Vector2(480-radius, center-radius)
var radiusScale: float:
	get: return radius/54
var brightness: float = 0.5:
	set(value):
		brightness = value
		material.set_shader_parameter("brightness", brightness)

var radiusIncreasesPerPulse: Array[float]
var brightnessIncreasesPerPulse: Array[float]

var pulsesRemaining: int
var timeUntilNextPulse: float

var transitioning := false
var transitionDuration: float
var transitionTimeElapsed: float
var transitionFraction: float

var oldBrightness: float
var brightnessDelta: float

var oldRadius: float
var radiusDelta: float

var oldColor: Color
var newColor: Color

# Called when the node enters the scene tree for the first time.
func _ready():
	oldBrightness = material.get_shader_parameter("brightness")
	oldColor = color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pulsesRemaining > 0:
		timeUntilNextPulse -= delta
		if timeUntilNextPulse <= 0:
			initiatePulse()
	
	if transitioning:
		transitionTimeElapsed += delta
		if transitionTimeElapsed >= transitionDuration:
			transitionTimeElapsed = transitionDuration
			transitioning = false
		transitionFraction = transitionTimeElapsed/transitionDuration

		radius = oldRadius + radiusDelta*transitionFraction
		brightness = oldBrightness + brightnessDelta*transitionFraction
		color = oldColor.lerp(newColor, transitionFraction)

func initiateGrowth(pulses: int = 3, radiusIncreasePerPulse: float = 6, brightnessIncreasePerPulse: float = 0):
	pulsesRemaining += pulses
	for _i in pulses:
		radiusIncreasesPerPulse.append(radiusIncreasePerPulse)
		brightnessIncreasesPerPulse.append(brightnessIncreasePerPulse)

func initiatePulse():
	pulsesRemaining -= 1
	timeUntilNextPulse = 1
	var newPulse: Pulse = inwardPulsePrefab.instantiate()
	newPulse.material.set_shader_parameter("ballRadius", radius/540/2)
	newPulse.onPulseFinish.connect(assimilatePulse)
	newPulse.lifespan = 3
	inwardPulsesControl.add_child(newPulse)
	AudioManager.playInwardPulse()

func assimilatePulse():
	transitioning = true
	transitionDuration = 0.5
	transitionTimeElapsed = 0

	oldRadius = radius
	radiusDelta = radiusIncreasesPerPulse[0]
	radiusIncreasesPerPulse.remove_at(0)

	oldBrightness = brightness
	brightnessDelta = brightnessIncreasesPerPulse[0]
	brightnessIncreasesPerPulse.remove_at(0)

	oldColor = color
	newColor = color

	ScreenShaker.addShake()

	AudioManager.playTheBallExpansion()

func forceSizeChange(newRadius: float, p_transitionDuration: float, p_newColor: Color = Color.WHITE):
	
	for inwardPulse in inwardPulsesControl.get_children():
		inwardPulse.queue_free()

	if p_transitionDuration == 0:
	
		transitioning = false
		radius = newRadius
		color = p_newColor

	else:

		transitioning = true
		transitionDuration = p_transitionDuration
		transitionTimeElapsed = 0

		oldRadius = radius
		radiusDelta = newRadius-oldRadius
		
		oldColor = color
		newColor = p_newColor
