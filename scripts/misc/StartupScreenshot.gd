extends Node

var firstFrame := true
var captureTaken := false

func _ready():
    get_window().size = Vector2(3840,2160)

func _process(_delta):
    if firstFrame:
        firstFrame = false
        return
    if not captureTaken:
        get_viewport().get_texture().get_image().save_png("res://screenshot.png")
        captureTaken = true