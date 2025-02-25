class_name OneShotAudio
extends AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	finished.connect(selfDestruct)
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func selfDestruct():
	queue_free()