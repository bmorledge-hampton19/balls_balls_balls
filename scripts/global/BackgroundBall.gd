class_name BackgroundBall
extends ColorRect

var speed: float
var radius: float:
	set(value):
		radius = value
		size = Vector2(radius*2, radius*2)
		speed = 1000/radius
		material.set_shader_parameter("pulseSpeed", 20/radius)
		material.set_shader_parameter("randomPulseOffset", randf()*PI*2)
var flowDeviation: float
var independentFlow := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	if randi_range(0,49):
		radius = randi_range(5, 15)
	else:
		radius = randi_range(50,70)
	
	flowDeviation = randf_range(-PI/8,PI/8)

	color = Color(randf(), randf(), randf())
	while color.r + color.g + color.b < 0.5:
		color = Color(randf(), randf(), randf())
