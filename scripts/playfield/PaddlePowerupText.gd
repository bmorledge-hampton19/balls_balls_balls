class_name PaddlePowerupText
extends Label

var elapsed_time: float

func _process(delta):

    elapsed_time += delta

    position.y -= 25*delta
    if elapsed_time > 1: self_modulate.a = lerp(self_modulate.a, 0.0, delta)
    if self_modulate.a < 0.05: queue_free()
