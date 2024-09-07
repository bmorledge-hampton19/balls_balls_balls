class_name Wall
extends Control

@export var area: Area2D
@export var collider: CollisionShape2D

var _leftVertexTracker: VertexTracker
var _rightVertexTracker: VertexTracker

var leftVertex: Vertex:
	get: return _leftVertexTracker.vertex
var rightVertex: Vertex:
	get: return _rightVertexTracker.vertex

var leftInnerAngle: float
var rightInnerAngle: float
var sideLength: float:
	get: return size.x
	set(value): size.x = value
var height: float

var reducing: bool


func initWall(p_leftVertex: Vertex, p_rightVertex: Vertex):

	_leftVertexTracker = VertexTracker.new(p_leftVertex)
	_rightVertexTracker = VertexTracker.new(p_rightVertex)

	# rightTeam = p_rightTeam
	# leftTeam = p_leftTeam

	# if replacingTeam != null:
	# 	rotation = replacingTeam.rotation
	# elif replacingWall != null:
	# 	rotation = replacingWall.rotation
	# else:
	# 	rotation = rightTeam.rotation + angle_difference(rightTeam.rotation,leftTeam.rotation)

	# var sideLength: float
	# if atVertex: sideLength = 0
	# elif polygon.sides > 2: sideLength = polygon.sideLength
	# else: sideLength = 960

	# var height: float
	# if atVertex: height = polygon.macroRadius
	# if polygon.sides > 2: height = polygon.microRadius
	# else: height = 270

	# position.y = 540-height
	
	# area.position = Vector2(-sideLength/2, height)

	# collider.position = Vector2(sideLength/2, 5)
	# collider.shape.size = Vector2(sideLength, 10)



# func changePolygon(newPolygon: PolygonGuide.Polygon, newTransitionDuration: float, p_reducing := false):

# 	transitioning = true
# 	transitionDuration = newTransitionDuration
# 	transitionTimeElapsed = 0
# 	reducing = p_reducing

# 	var sideLength: float
# 	if reducing: sideLength = 0
# 	elif newPolygon.sides > 2: sideLength = newPolygon.sideLength
# 	else: 
# 	var height := newPolygon.microRadius

# 	oldAngle = rotation
# 	var targetAngle := rightTeam.targetAngle + angle_difference(rightTeam.targetAngle,leftTeam.targetAngle)
# 	angleDelta = angle_difference(oldAngle, targetAngle)

# 	oldPosY = position.y
# 	posYDelta = (540-height) - oldPosY
	
# 	oldAreaPosition = area.position
# 	areaPositionDelta = Vector2(-sideLength/2, height) - oldAreaPosition

# 	oldColliderPosition = collider.position
# 	colliderPositionDelta = Vector2(sideLength/2, 5) - oldColliderPosition
# 	oldColliderWidth = collider.shape.size.x
# 	colliderWidthDelta = sideLength - oldColliderWidth


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

	updateWallControl()
	updateCollider()

func updateWallControl():

	global_position = leftVertex.global_position

	var verticesAngle: float = abs(angle_difference(leftVertex.rotation, rightVertex.rotation))

	if verticesAngle == 0:
		size.x = 0
		rotation = 0
		height = leftVertex.macroRadius

	else:
		size.x = sqrt(
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


func updateCollider():
	collider.position.x = sideLength/2
	collider.position.y = 5
	collider.shape.size.x = sideLength
