class_name PauseMenuOption
extends Node

@export var label: Label
@export var leftBall: ColorRect
@export var rightBall: ColorRect

const lowlightColor: Color = Color.DIM_GRAY

var rightBumped: bool
var leftBumped: bool
var highlighted: bool

signal onConfirmOption()


func _process(_delta):

    if highlighted:
        leftBall.position.x = sin(Time.get_ticks_msec()/500.0)*-5 - 5
        rightBall.position.x = sin(Time.get_ticks_msec()/500.0)*5 + 5
    else:
        leftBall.position.x = 0
        rightBall.position.x = 0


func lowlight():
    highlighted = false

    leftBumped = false
    rightBumped = false

    leftBall.color = lowlightColor
    rightBall.color = lowlightColor

    label.modulate = lowlightColor

func highlight():
    highlighted = true

    leftBumped = false
    rightBumped = false
    
    leftBall.color = Color.WHITE
    rightBall.color = Color.WHITE

    label.modulate = Color.WHITE


func bumpLeft():
    leftBall.color = Color.FOREST_GREEN
    leftBumped = true
    if rightBumped: onConfirmOption.emit()

func bumpRight():
    rightBall.color = Color.FOREST_GREEN
    rightBumped = true
    if leftBumped: onConfirmOption.emit()