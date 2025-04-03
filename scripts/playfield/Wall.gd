@tool
class_name Wall
extends Control

@export var staticWall: bool = false
@export var visual: ColorRect
@export var area: Area2D
@export var collider: CollisionShape2D

# @export var particleEmittersControl: Control
# @export var particleEmitterPrefab: PackedScene

var _leftVertexTracker: VertexTracker
var _rightVertexTracker: VertexTracker

var leftVertex: Vertex:
	get:
		if staticWall: return null
		else: return _leftVertexTracker.vertex
var rightVertex: Vertex:
	get:
		if staticWall: return null
		else: return _rightVertexTracker.vertex

var leftInnerAngle: float
var rightInnerAngle: float
@export var sideLength: float:
	get: return size.x
	set(value):
		size.x = value
		if not visual or not collider: return
		visual.size.x = sideLength
		visual.material.set_shader_parameter("width", sideLength)
		collider.position.x = sideLength/2
		collider.position.y = 5
		collider.shape.size.x = sideLength
@export var flipped: bool:
	set(value):
		flipped = value
		if not visual: return
		if flipped: visual.material.set_shader_parameter("flipped", 1.0)
		else: visual.material.set_shader_parameter("flipped", 0.0)

var height: float

var reducing: bool


func initWall(p_leftVertex: Vertex, p_rightVertex: Vertex):

	_leftVertexTracker = VertexTracker.new(p_leftVertex)
	_rightVertexTracker = VertexTracker.new(p_rightVertex)


# Called when the node enters the scene tree for the first time.
func _ready():
	sideLength = sideLength
	flipped = flipped
	visual.material.set_shader_parameter("noiseOffset", Vector2(randf(),randf()))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if staticWall or Engine.is_editor_hint(): return
	updateWallControl()
	

func updateWallControl():

	global_position = leftVertex.global_position

	var verticesAngle: float = abs(angle_difference(leftVertex.rotation, rightVertex.rotation))

	if verticesAngle == 0:
		sideLength = 0
		rotation = 0
		height = leftVertex.macroRadius

	else:
		sideLength = sqrt(
			leftVertex.macroRadius**2 + rightVertex.macroRadius**2 -
			2*leftVertex.macroRadius*rightVertex.macroRadius *
			cos(verticesAngle)
		)

		leftInnerAngle = acos(
			(rightVertex.macroRadius**2 - size.x**2 - leftVertex.macroRadius**2) /
			(-2 * size.x * leftVertex.macroRadius)
		)
		rightInnerAngle = PI-leftInnerAngle-verticesAngle
		rotation = leftVertex.rotation + leftInnerAngle - PI/2

		if leftInnerAngle < 90: height = sin(leftInnerAngle)*leftVertex.macroRadius
		else: height = sin(rightInnerAngle)*rightVertex.macroRadius

# func spawnParticlesFromCollision(ball: Ball, collisionPoint: Vector2):
# 	var particleEmitter: CPUParticles2D = particleEmitterPrefab.instantiate()
# 	particleEmittersControl.add_child(particleEmitter)
# 	particleEmitter.global_position = collisionPoint
# 	var emissionAngle := ball.fullVelocity.normalized().angle() - rotation
# 	emissionAngle = clampf(angle_difference(0, emissionAngle),-11.0/12.0*PI,-1.0/12.0*PI)
# 	particleEmitter.direction = Vector2.from_angle(emissionAngle)
	
