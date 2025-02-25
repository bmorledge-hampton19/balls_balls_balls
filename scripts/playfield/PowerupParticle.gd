class_name PowerupParticle
extends ColorRect

var targetPaddle: Paddle

var hanging: bool

var speed: float
var direction: Vector2

signal onAbsorption()

func _ready():
    speed = 50
    direction = Vector2.from_angle(randf()*2*PI)
    hanging = true

func init(p_targetPaddle):
    targetPaddle = p_targetPaddle
    color = targetPaddle.color.color

func _process(delta):

    if not is_instance_valid(targetPaddle):
        queue_free()
        return


    if hanging:
        speed -= 25*delta
        if speed < 0:
            speed = 0
            hanging = false
    
    else:
        var targetPos := targetPaddle.pivot.global_position
        direction = global_position.direction_to(targetPos)
        if speed < 200: speed += 100*delta
        if speed*delta >= (targetPos-global_position).length():
            onAbsorption.emit()
            queue_free()
            return
    
    global_position += speed*direction*delta
