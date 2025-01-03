class_name VariableTimer
extends Timer

@export var baseTime: float
@export var timeDeviation: float

func _ready():
	timeout.connect(resetWaitTime)
	resetWaitTime()

func resetWaitTime():
	wait_time = baseTime + randf_range(-timeDeviation, timeDeviation)
