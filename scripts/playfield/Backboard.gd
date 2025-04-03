class_name Backboard
extends Control

@export var breakableBlocks: Array[BreakableBlock]

var color: Color:
    set(value):
        color = value
        for breakableBlock in breakableBlocks:
            breakableBlock.color = color