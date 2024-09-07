class_name Bumper
extends Control

var _vertexTracker: VertexTracker
var vertex: Vertex:
	get: return _vertexTracker.vertex

# var transitioning := false
# var transitionDuration: float
# var transitionTimeElapsed: float = 10
# var transitionFraction: float

# var oldAngle: float
# var angleDelta: float

# var oldPosY: float
# var posYDelta: float
# var oldPivotOffsetY: float
# var pivotOffsetYDelta: float


# func initBumper(angle: float, macroRadius: float):
# 	rotation = angle
# 	position.y = macroRadius+270
# 	pivot_offset.y = -macroRadius


func initBumper(p_vertex: Vertex):
	_vertexTracker = VertexTracker.new(p_vertex)
	updatePosition()


# func changePolygon(newPolygon: PolygonGuide.Polygon, newAngle: float, newTransitionDuration: float):

# 	transitioning = true
# 	transitionDuration = newTransitionDuration
# 	transitionTimeElapsed = 0

# 	oldAngle = rotation
# 	angleDelta = angle_difference(oldAngle,newAngle)

# 	oldPosY = position.y
# 	posYDelta = newPolygon.macroRadius+270 - oldPosY

# 	oldPivotOffsetY = pivot_offset.y
# 	pivotOffsetYDelta = -newPolygon.macroRadius - oldPivotOffsetY


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

	updatePosition()


func updatePosition():
	global_position = vertex.global_position
