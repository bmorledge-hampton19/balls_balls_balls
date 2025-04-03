extends Node

class Polygon:
	var sides: int
	var internalAngle: float
	var sideLength: float
	var microRadius: float
	var macroRadius: float
	var paddleWidthMultiplier: float
	var paddleSpeedMultiplier: float
	var maxWidth: float
	func _init(p_sides: int):
		sides = p_sides
		if sides > 2:
			internalAngle = 2*PI/sides
		else:
			internalAngle = atan(470.0/270.0)*2
		sideLength = sideLengths[sides]
		microRadius = microRadii[sides]
		macroRadius = macroRadii[sides]
		paddleWidthMultiplier = paddleWidthMultipliers[sides]
		paddleSpeedMultiplier = paddleSpeedMultipliers[sides]
		maxWidth = maxWidths[sides]

const sideLengths := {
	2 : 540,
	3 : 623.54,
	4 : 540,
	5 : 350.91,
	6 : 311.77,
	7 : 246.50,
	8 : 223.68
}

const microRadii := {
	2 : 470, # 480 for full viewport rect
	3 : 180,
	4 : 270,
	5 : 241.50,
	6 : 270,
	7 : 255.93,
	8 : 270
}

const macroRadii := {
	2 : 542.03, # 550.73 for full viewport rect
	3 : 360,
	4 : 381.84,
	5 : 298.50,
	6 : 311.77,
	7 : 284.07,
	8 : 292.25
}

const paddleWidthMultipliers := {
	2 : 0.9,
	3 : 1,
	4 : 0.9,
	5 : 0.8,
	6 : 0.75,
	7 : 0.725,
	8 : 0.7
}

const paddleSpeedMultipliers := {
	2 : 2.5,
	3 : 1.7,
	4 : 1.3,
	5 : 1,
	6 : 0.8,
	7 : 0.625,
	8 : 0.5
}

const maxWidths := {
	2 : 960, # 960 for full viewport rect
	3 : 623.54,
	4 : 540,
	5 : 567.78,
	6 : 623.54,
	7 : 553.90,
	8 : 540
}

var polygons: Array[Polygon]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	polygons.append(null); polygons.append(null)
	polygons.append(Polygon.new(2))
	polygons.append(Polygon.new(3))
	polygons.append(Polygon.new(4))
	polygons.append(Polygon.new(5))
	polygons.append(Polygon.new(6))
	polygons.append(Polygon.new(7))
	polygons.append(Polygon.new(8))
