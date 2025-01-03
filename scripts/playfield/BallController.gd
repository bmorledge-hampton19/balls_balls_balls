class_name BallController
extends Node2D

@export var thrustParticleEmitter: CPUParticles2D

var player: Player
var thurstAcceleration: float = 10
var thrustDirection: Vector2

func _process(_delta):

	thrustDirection = Vector2.ZERO

	if player.isInputPressed(player.leftInput): thrustDirection += Vector2.LEFT
	if player.isInputPressed(player.rightInput): thrustDirection += Vector2.RIGHT
	if player.isInputPressed(player.upInput): thrustDirection += Vector2.UP
	if player.isInputPressed(player.downInput): thrustDirection += Vector2.DOWN

	if thrustDirection != Vector2.ZERO:
		thrustDirection = thrustDirection.normalized()
		thrustParticleEmitter.emitting = true
		thrustParticleEmitter.direction = -thrustDirection
	else:
		thrustParticleEmitter.emitting = false
