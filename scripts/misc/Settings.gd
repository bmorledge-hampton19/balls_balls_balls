extends Node

enum Setting {
    SETTINGS_FORMAT, BALL_SPEED, SPAWN_RATE, PADDLE_SPEED, PADDLE_SIZE, STARTING_LIVES, LIVES_ON_ELIM, PLAYER_CONTROLLED_BALLS,
    FULLSCREEN,
    LINEAR_ACCEL_SPAWN_RATE, SPIRALING_SPAWN_RATE, STOP_AND_START_SPAWN_RATE, DRIFTER_SPAWN_RATE, BEHAVIOR_INTENSITY,
    POWERUP_FREQUENCY, POWERUP_DURATION,
}

enum {BORING, BALLS}
enum {SMOOTH, MIXED, ERRATIC}

var _settingIndices: Dictionary = {
    Setting.SETTINGS_FORMAT : 0,
    Setting.BALL_SPEED : 2,
    Setting.SPAWN_RATE : 1,
    Setting.PADDLE_SPEED : 3,
    Setting.PADDLE_SIZE : 3,
    Setting.STARTING_LIVES : 4,
    Setting.LIVES_ON_ELIM : 1,
    Setting.PLAYER_CONTROLLED_BALLS : 1,
    Setting.FULLSCREEN : 1,

    Setting.LINEAR_ACCEL_SPAWN_RATE : 1,
    Setting.SPIRALING_SPAWN_RATE : 1,
    Setting.STOP_AND_START_SPAWN_RATE : 1,
    Setting.DRIFTER_SPAWN_RATE : 1,
    Setting.BEHAVIOR_INTENSITY : 1,
    Setting.POWERUP_FREQUENCY : 2,
    Setting.POWERUP_DURATION : 1,
}

const SETTING_TITLES: Dictionary = {
    Setting.SETTINGS_FORMAT : "Settings Menu",
    Setting.BALL_SPEED : "Ball Speed",
    Setting.SPAWN_RATE : "Ball Spawn Rate",
    Setting.PADDLE_SPEED : "Paddle Speed",
    Setting.PADDLE_SIZE : "Paddle Size",
    Setting.STARTING_LIVES : "Starting Lives",
    Setting.LIVES_ON_ELIM : "Lives on Elim",
    Setting.PLAYER_CONTROLLED_BALLS : "Zombie Balls",
    Setting.FULLSCREEN : "Fullscreen (F11)",

    Setting.LINEAR_ACCEL_SPAWN_RATE : "Accelerators",
    Setting.SPIRALING_SPAWN_RATE : "Spinners",
    Setting.STOP_AND_START_SPAWN_RATE : "Sleepers",
    Setting.DRIFTER_SPAWN_RATE : "Drifters",
    Setting.BEHAVIOR_INTENSITY : "Intensity",
    Setting.POWERUP_FREQUENCY : "Powerup Rate",
    Setting.POWERUP_DURATION : "Powerup Time",
}

const SETTING_VALUES: Dictionary = {
    Setting.SETTINGS_FORMAT : [BORING, BALLS],
    Setting.BALL_SPEED : [25, 50, 75, 100, 200, 400],
    Setting.SPAWN_RATE : [0.1, 0.2, 0.5, 1.0, 2.0, 5.0],
    Setting.PADDLE_SPEED : [0.1, 0.2, 0.5, 1, 2, 4],
    Setting.PADDLE_SIZE : [0.4, 0.6, 0.75, 1, 1.5, 2],
    Setting.STARTING_LIVES : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 100],
    Setting.LIVES_ON_ELIM : [0, 1, 2, 3, 4, 5],
    Setting.PLAYER_CONTROLLED_BALLS : [false, true],
    Setting.FULLSCREEN : [false, true],

    Setting.LINEAR_ACCEL_SPAWN_RATE : [0, 10, 20, 50, 100],
    Setting.SPIRALING_SPAWN_RATE : [0, 10, 20, 50, 100],
    Setting.STOP_AND_START_SPAWN_RATE : [0, 10, 20, 50, 100],
    Setting.DRIFTER_SPAWN_RATE : [0, 10, 20, 50, 100],
    Setting.BEHAVIOR_INTENSITY : [SMOOTH, MIXED, ERRATIC],
    Setting.POWERUP_FREQUENCY : [0, 0.05, 0.1, 0.25, 0.5, 1.0],
    Setting.POWERUP_DURATION : [5, 10, 15, 25],
}

const SETTING_VALUE_NAMES: Dictionary = {
    Setting.SETTINGS_FORMAT : ["Boring", "Balls"],
    Setting.BALL_SPEED : ["Sluggish", "Leisurely", "Gentle", "Energetic", "Speedy", "Balls on Crack"],
    Setting.SPAWN_RATE : ["Few Balls", "Some Balls", "Balls", "More Balls", "Balls Balls", "Balls Balls Balls"],
    Setting.PADDLE_SPEED : ["Snail-like", "Steady", "Relaxed", "Active", "Peppy", "Uncontrollable"],
    Setting.PADDLE_SIZE : ["Itsy Bitsy", "Smol", "5' 11\"", "6-foot", "loooong", "Anaconda"],
    Setting.STARTING_LIVES : ["Sudden Death", "2", "3", "4", "5", "6", "7", "8", "9", "10", "20", "30", "40", "50", "Marathon"],
    Setting.LIVES_ON_ELIM : ["0", "1", "2", "3", "4", "5"],
    Setting.PLAYER_CONTROLLED_BALLS : ["Nope", "Yup"],
    Setting.FULLSCREEN : ["Nah", "Extra THICC"],

    Setting.LINEAR_ACCEL_SPAWN_RATE : ["None", "Rare", "Uncommon", "Common", "Frequent"],
    Setting.SPIRALING_SPAWN_RATE : ["None", "Rare", "Uncommon", "Common", "Frequent"],
    Setting.STOP_AND_START_SPAWN_RATE : ["None", "Rare", "Uncommon", "Common", "Frequent"],
    Setting.DRIFTER_SPAWN_RATE : ["None", "Rare", "Uncommon", "Common", "Frequent"],
    Setting.BEHAVIOR_INTENSITY : ["Smooth", "Mixed", "Erratic"],
    Setting.POWERUP_FREQUENCY : ["None", "Weak", "Mild", "Potent", "Stronk", "POWERFUL"],
    Setting.POWERUP_DURATION : ["Fleeting", "Brief", "Lengthy", "Enduring"],
}

signal onToggleFullscreen()

func setSetting(setting: Setting, index: int):
    if setting == Setting.FULLSCREEN and index != _settingIndices[Setting.FULLSCREEN]: _toggleFullscreen()
    else: _settingIndices[setting] = index

func getSettingValue(setting: Setting):
    return SETTING_VALUES[setting][_settingIndices[setting]]

func _toggleFullscreen():
    if _settingIndices[Setting.FULLSCREEN] == 0:
        _settingIndices[Setting.FULLSCREEN] = 1
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
    else:
        _settingIndices[Setting.FULLSCREEN] = 0
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    onToggleFullscreen.emit()

func _process(_delta):
    if Input.is_action_just_pressed("FULLSCREEN"): _toggleFullscreen()