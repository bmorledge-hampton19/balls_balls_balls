class_name Vertex
extends Control

enum {AUTO, LEFT, RIGHT, NONE}

var trackers: Array[VertexTracker]

var macroRadius: float:
	set(p_macroRadius):
		macroRadius = p_macroRadius
		position.y = macroRadius
		pivot_offset.y = -macroRadius
var unadjustedMacroRadius: float

var boundaries: GameManager.PlayfieldBoundaries

var transitioning := false
var transitioningAndReducing := false
var transitionDuration: float
var transitionTimeElapsed: float
var transitionFraction: float
signal onTransitionEnd(vertex: Vertex)

var oldAngle: float
var angleDelta: float
var targetAngle: float:
	get: return oldAngle + angleDelta

var oldMacroRadius: float
var macroRadiusDelta: float
var targetMacroRadius: float:
	get: return oldMacroRadius + macroRadiusDelta

var transitionDirection: int:
	get: 
		if not transitioning: return NONE
		elif angleDelta < 0: return RIGHT
		elif angleDelta > 0: return LEFT
		else: return AUTO

var _reducingParentTracker: VertexTracker
var reducingParent: Vertex:
	get:
		if _reducingParentTracker == null: return null
		else: return _reducingParentTracker.vertex
var reducingChild: Vertex
var reducingTimeRemaining: float


func initVertex(angle: float, p_macroRadius: float, p_boundaries):
	macroRadius = p_macroRadius
	unadjustedMacroRadius = macroRadius
	rotation = angle
	boundaries = p_boundaries


func initVertexReduction(parent: Vertex, p_reducingTimeRemaining: float):
	_reducingParentTracker = VertexTracker.new(parent)
	parent.reducingChild = self
	reducingTimeRemaining = p_reducingTimeRemaining


func revertReduction():

	reducingParent.reducingChild = null
	_reducingParentTracker.nullify()
	_reducingParentTracker = null
	reducingTimeRemaining = 0


func changePolygon(
	newPolygon: PolygonGuide.Polygon, newAngle: float, newTransitionDuration: float, direction := AUTO,
	newMacroRadius := -1.0
):

	transitioning = true
	if reducingTimeRemaining > 0: transitioningAndReducing = true
	transitionDuration = newTransitionDuration
	transitionTimeElapsed = 0

	oldAngle = rotation
	angleDelta = angle_difference(oldAngle,newAngle)
	if direction == RIGHT and angleDelta > 0: angleDelta = -2*PI+angleDelta
	elif direction == LEFT and angleDelta < 0: angleDelta = 2*PI+angleDelta

	oldMacroRadius = unadjustedMacroRadius
	if newMacroRadius == -1: macroRadiusDelta = newPolygon.macroRadius - oldMacroRadius
	else: macroRadiusDelta = newMacroRadius - oldMacroRadius


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if transitioning:

		transitionTimeElapsed += delta
		reducingTimeRemaining -= delta
		if transitionTimeElapsed >= transitionDuration:
			transitionTimeElapsed = transitionDuration
			transitioning = false
			if reducingTimeRemaining <= 0:
				onTransitionEnd.emit(self)
		transitionFraction = transitionTimeElapsed/transitionDuration

		rotation = oldAngle + angleDelta*transitionFraction
		macroRadius = oldMacroRadius + macroRadiusDelta*transitionFraction

	unadjustedMacroRadius = macroRadius
	enforceBoundaries()

func enforceBoundaries():

	var yOffset = macroRadius * cos(rotation)
	if yOffset < boundaries.minYOffset:
		macroRadius = boundaries.minYOffset/cos(rotation)
	elif yOffset > boundaries.maxYOffset:
		macroRadius = boundaries.maxYOffset/cos(rotation)

	var horizontalRotation := PI/2 + rotation
	var xOffset = macroRadius * cos(horizontalRotation)
	if xOffset < boundaries.minXOffset:
		macroRadius = boundaries.minXOffset/cos(horizontalRotation)
	if xOffset > boundaries.maxXOffset:
		macroRadius = boundaries.maxXOffset/cos(horizontalRotation)