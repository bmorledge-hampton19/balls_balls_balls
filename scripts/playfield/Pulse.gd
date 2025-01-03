class_name Pulse
extends ColorRect

var lifespan: float = 1.0:
	set(value):
		lifespan = value
		material.set_shader_parameter("speed", 1.0/(lifespan*1.05))

var elapsedTime: float
signal onPulseFinish()

# Called when the node enters the scene tree for the first time.
func _ready():
	lifespan = lifespan


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsedTime += delta
	material.set_shader_parameter("elapsedTime", elapsedTime)
	if elapsedTime >= lifespan:
		onPulseFinish.emit()
		queue_free()
