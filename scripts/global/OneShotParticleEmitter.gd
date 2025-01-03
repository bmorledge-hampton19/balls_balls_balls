class_name OneShotParticleEmitter
extends CPUParticles2D

func _ready():
    one_shot = true
    emitting = true
    finished.connect(func(): queue_free())
