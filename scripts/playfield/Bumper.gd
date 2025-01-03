@tool
class_name Bumper
extends Control

@export var collisionShape: CollisionShape2D
@export var pulsesControl: Control
@export var pulsePrefab: PackedScene
@export var texture: ColorRect
@export var radius: float = 10:
	set(p_radius):
		radius = p_radius
		if collisionShape != null: updateRadius()
		else: updateRadius.call_deferred()

func updateRadius():
	collisionShape.shape.radius = radius
	pulsesControl.position = Vector2(-radius*5,-radius*5)
	texture.size = Vector2(radius*2, radius*2)
	texture.position = Vector2(-radius, -radius)

var _vertexTracker: VertexTracker
var vertex: Vertex:
	get: return _vertexTracker.vertex

# var baseTexturePulseSpeed: float = 0.25
# var extraTexturePulseSpeed: float = 0
# var extraTexturePulseSpeedDecel: float = 0.25

var extraTextureSaturation: float = 0
var extraTextureSaturationDecay: float = 0.25

func activate():
	collisionShape.disabled = false
func deactivate():
	collisionShape.disabled = true


func initBumper(p_vertex: Vertex):
	_vertexTracker = VertexTracker.new(p_vertex)
	updatePosition()

func pulse():
	var newPulse = pulsePrefab.instantiate()
	pulsesControl.add_child(newPulse)
	newPulse.size = Vector2(radius*10,radius*10)
	# extraTexturePulseSpeed = 0.25
	extraTextureSaturation += 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if _vertexTracker != null: updatePosition()

	updateTexture(delta)


func updatePosition():
	global_position = vertex.global_position


func updateTexture(delta):
	# extraTexturePulseSpeed = clamp(extraTexturePulseSpeed-extraTexturePulseSpeedDecel*delta, 0, 1)
	extraTextureSaturation = clamp(extraTextureSaturation-extraTextureSaturationDecay*delta, 0, 1)

	# texture.material.set_shader_parameter("speed", baseTexturePulseSpeed + extraTexturePulseSpeed)
	texture.material.set_shader_parameter("extraSaturation", extraTextureSaturation)
