extends Node

class Polygon:
	var sides: int
	var sideLength: float
	var microRadius: float
	var macroRadius: float
	var paddleWidthMultiplier: float
	func _init(p_sides: int, p_sideLength: float, p_microRadius: float, p_macroRadius: float, p_paddleWidthMultiplier):
		sides = p_sides
		sideLength = p_sideLength
		microRadius = p_microRadius
		macroRadius = p_macroRadius
		paddleWidthMultiplier = p_paddleWidthMultiplier

var polygons: Array[Polygon]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	polygons.append(null); polygons.append(null)
	polygons.append(Polygon.new(2, 540, 270, 381.84, 0.9))
	polygons.append(Polygon.new(3, 623.54, 180, 360, 0.85))
	polygons.append(Polygon.new(4, 540, 270, 381.84, 1))
	polygons.append(Polygon.new(5, 350.91, 241.50, 298.50, 0.9))
	polygons.append(Polygon.new(6, 311.77, 270, 311.77, 0.75))
	polygons.append(Polygon.new(7, 246.50, 255.93, 284.07, 0.725))
	polygons.append(Polygon.new(8, 223.68, 270, 292.25, 0.7))
