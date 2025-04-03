class_name BreakableBlock
extends Area2D

@export var colorRect: ColorRect
@export var collider: CollisionShape2D
@export var particleEmitterPrefab: PackedScene

var color: Color:
    set(value):
        color = value
        colorRect.color = color

var timeBeforeFadeIn: float

func _ready():
    modulate.a = 0
    timeBeforeFadeIn = randf_range(1.0,2.0)

func _process(delta):
    if timeBeforeFadeIn > 0:
        timeBeforeFadeIn -= delta
    if modulate.a < 1 and timeBeforeFadeIn <= 0:
        modulate.a += 0.5*delta
        if modulate.a > 1: modulate.a = 1


func explode():

    colorRect.hide()
    collider.disabled = true

    var particleEmitter: OneShotParticleEmitter = particleEmitterPrefab.instantiate()
    add_child(particleEmitter)
    particleEmitter.position = Vector2(5,27)
    particleEmitter.color = color
    particleEmitter.finished.connect(queue_free)

    AudioManager.playBlockExplosion()