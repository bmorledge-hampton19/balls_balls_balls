extends Node

var screenshotNextFrame := false
var returnToResolution: Vector2

func _process(_delta):

    if screenshotNextFrame:
        get_viewport().get_texture().get_image().save_png("res://screenshot.png")
        DisplayServer.window_set_size(returnToResolution)
        screenshotNextFrame = false

    if Input.is_key_pressed(KEY_F12):
        screenshotNextFrame = true
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        returnToResolution = DisplayServer.window_get_size()
        DisplayServer.window_set_size(Vector2(3840,2160))