class_name OneShotAudio
extends AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(p_stream: AudioStream, busName: String = "Master", p_volume_db: float = 0):
	stream = p_stream
	bus = busName
	volume_db = p_volume_db
	finished.connect(selfDestruct)
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func selfDestruct():
	queue_free()