extends Node

var powerupTextPrefab: PackedScene = preload("res://scenes/objects/paddle_powerup_text.tscn")
var powerupParticlePrefab: PackedScene = preload("res://scenes/objects/powerup_particle.tscn")

var ballManager: BallManager
var particleControl: Control

enum Type {NONE, SPIN_CYCLE, DUPLICATOR, STICKY, BALL_BOOSTER, WIDE_PADDLE, FAST_PADDLE}

var durationMult := {
    Type.NONE : 0,
    Type.SPIN_CYCLE : 1.0,
    Type.DUPLICATOR : 1.25,
    Type.STICKY : 1.5,
    Type.BALL_BOOSTER : 1.25,
    Type.WIDE_PADDLE : 1.0,
    Type.FAST_PADDLE : 1.0,
}

var powerupName := {
    Type.NONE : "",
    Type.SPIN_CYCLE : "Spin Cycle",
    Type.DUPLICATOR : "Mitosis",
    Type.STICKY : "Sticky Paddle",
    Type.BALL_BOOSTER : "Ball Booster",
    Type.WIDE_PADDLE : "Wide Paddle",
    Type.FAST_PADDLE : "Fast Paddle",
}

func cloneBall(ball: Ball):
    if is_instance_valid(ballManager): ballManager.cloneBall(ball)

func initPowerupAnimation(powerupType: Type, paddle: Paddle, globalGoalPos: Vector2):
    print("initializing powerup animation...")
    for i in range(10):
        var powerupParticle: PowerupParticle = powerupParticlePrefab.instantiate()
        particleControl.add_child(powerupParticle)
        powerupParticle.global_position = globalGoalPos
        powerupParticle.init(paddle)
        powerupParticle.onAbsorption.connect(func(): conferPowerupParticle(powerupType, paddle))


func conferPowerupParticle(powerupType: Type, paddle: Paddle):
    if not is_instance_valid(paddle): return

    paddle.absorbedPowerupParticles += 1
    AudioManager.playAbsorbPowerupParticle(paddle.team.color)
    if paddle.absorbedPowerupParticles % 10: return

    paddle.powerupDurations[powerupType] += (
        Settings.getSettingValue(Settings.Setting.POWERUP_DURATION) *
        PowerupManager.durationMult[powerupType]
    )

    var powerupText: PaddlePowerupText = powerupTextPrefab.instantiate()
    powerupText.text = powerupName[powerupType]
    powerupText.self_modulate = paddle.color.color
    paddle.textControl.add_child(powerupText)
    AudioManager.playConferPowerup(paddle.team.color)
