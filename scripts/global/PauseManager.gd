extends Node

const PAUSE_MENU_PREFAB = preload("res://scenes/global/pause_menu.tscn")

var paused: bool
var pauseMenu: PauseMenu
var transferableController: InputSets.InputSet
var pausable: bool = true


func pause() -> PauseMenu:

    if not pausable: return

    if paused:
        print("ERROR: Already paused")
        return

    paused = true
    get_tree().paused = true

    pauseMenu = PAUSE_MENU_PREFAB.instantiate()
    print(pauseMenu)
    return pauseMenu


func unpause(transferControl := false):

    paused = false
    get_tree().paused = false
    transferableController = null

    if not is_instance_valid(pauseMenu):
        return
    else:
        if transferControl: transferableController = pauseMenu.masterInputSelector.masterInputSet
        pauseMenu.queue_free()