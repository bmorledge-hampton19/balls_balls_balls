extends Node

const PAUSE_MENU_PREFAB = preload("res://scenes/global/pause_menu.tscn")

var paused: bool
var pauseMenu: PauseMenu
var transferableController: InputSets.InputSet
var pausable: bool = true


func pause(pauseMusic := true) -> PauseMenu:

    if not pausable: return

    if paused:
        print("ERROR: Already paused")
        return

    paused = true
    get_tree().paused = true
    if pauseMusic: AudioManager.pauseMusic()

    pauseMenu = PAUSE_MENU_PREFAB.instantiate()
    print(pauseMenu)
    return pauseMenu


func unpause(transferControl := false):

    paused = false
    get_tree().paused = false
    AudioManager.resumeMusic()
    transferableController = null

    if not is_instance_valid(pauseMenu):
        return
    else:
        if transferControl: transferableController = pauseMenu.masterInputSelector.masterInputSet
        pauseMenu.queue_free()