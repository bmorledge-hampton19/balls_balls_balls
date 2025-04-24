extends Node

enum Setting {
    SETTINGS_FORMAT, BALL_SIZE, BALL_SPEED, SPAWN_RATE, PADDLE_SPEED, PADDLE_SIZE, STARTING_LIVES, LIVES_ON_ELIM, 
    FULLSCREEN,
    # LINEAR_ACCEL_SPAWN_RATE,
    ANGLER_SPAWN_RATE, SPIRALING_SPAWN_RATE, STOP_AND_START_SPAWN_RATE, DRIFTER_SPAWN_RATE, BEHAVIOR_INTENSITY, PLAYER_CONTROLLED_BALLS,
    POWERUP_FREQUENCY, POWERUP_DURATION,
    SPIN_TYPE,
    PRESET,
}

enum {BORING, BALLS}
enum {SMOOTH, MIXED, ERRATIC}
enum {CUSTOM, DEFAULT, POWERPALOOZA, QUIRKY, SPINNERS_PARADISE, PRECISION, SLOW_MO, PAIN, SUDDEN_DEATH, TOURNAMENT}

var presets := {
    DEFAULT : {
        Setting.BALL_SIZE : 1, Setting.BALL_SPEED : 2, Setting.SPAWN_RATE : 1,
        Setting.PADDLE_SPEED : 3, Setting.PADDLE_SIZE : 3,
        Setting.STARTING_LIVES : 4, Setting.LIVES_ON_ELIM : 1,
        Setting.ANGLER_SPAWN_RATE : 1, Setting.SPIRALING_SPAWN_RATE : 1,
        Setting.STOP_AND_START_SPAWN_RATE : 1, Setting.DRIFTER_SPAWN_RATE : 1,
        Setting.PLAYER_CONTROLLED_BALLS : 1,
        Setting.POWERUP_FREQUENCY : 3, Setting.POWERUP_DURATION : 1,
    },
    POWERPALOOZA : {
        Setting.BALL_SIZE : 1, Setting.BALL_SPEED : 2, Setting.SPAWN_RATE : 2,
        Setting.PADDLE_SPEED : 3, Setting.PADDLE_SIZE : 3,
        Setting.STARTING_LIVES : 9, Setting.LIVES_ON_ELIM : 1,
        Setting.ANGLER_SPAWN_RATE : 1, Setting.SPIRALING_SPAWN_RATE : 1,
        Setting.STOP_AND_START_SPAWN_RATE : 1, Setting.DRIFTER_SPAWN_RATE : 1,
        Setting.PLAYER_CONTROLLED_BALLS : 1,
        Setting.POWERUP_FREQUENCY : 4, Setting.POWERUP_DURATION : 3,
    },
    QUIRKY : {
        Setting.BALL_SIZE : 1, Setting.BALL_SPEED : 2, Setting.SPAWN_RATE : 1,
        Setting.PADDLE_SPEED : 3, Setting.PADDLE_SIZE : 4,
        Setting.STARTING_LIVES : 4, Setting.LIVES_ON_ELIM : 1,
        Setting.ANGLER_SPAWN_RATE : 4, Setting.SPIRALING_SPAWN_RATE : 4,
        Setting.STOP_AND_START_SPAWN_RATE : 4, Setting.DRIFTER_SPAWN_RATE : 4,
        Setting.PLAYER_CONTROLLED_BALLS : 1,
        Setting.POWERUP_FREQUENCY : 3, Setting.POWERUP_DURATION : 1,
    },
    SPINNERS_PARADISE : {
        Setting.BALL_SIZE : 2, Setting.BALL_SPEED : 0, Setting.SPAWN_RATE : 3,
        Setting.PADDLE_SPEED : 1, Setting.PADDLE_SIZE : 4,
        Setting.STARTING_LIVES : 9, Setting.LIVES_ON_ELIM : 1,
        Setting.ANGLER_SPAWN_RATE : 1, Setting.SPIRALING_SPAWN_RATE : 1,
        Setting.STOP_AND_START_SPAWN_RATE : 1, Setting.DRIFTER_SPAWN_RATE : 1,
        Setting.PLAYER_CONTROLLED_BALLS : 1,
        Setting.POWERUP_FREQUENCY : 3, Setting.POWERUP_DURATION : 1,
    },
    PRECISION : {
        Setting.BALL_SIZE : 0, Setting.BALL_SPEED : 3, Setting.SPAWN_RATE : 1,
        Setting.PADDLE_SPEED : 5, Setting.PADDLE_SIZE : 1,
        Setting.STARTING_LIVES : 4, Setting.LIVES_ON_ELIM : 1,
        Setting.ANGLER_SPAWN_RATE : 1, Setting.SPIRALING_SPAWN_RATE : 1,
        Setting.STOP_AND_START_SPAWN_RATE : 1, Setting.DRIFTER_SPAWN_RATE : 1,
        Setting.PLAYER_CONTROLLED_BALLS : 1,
        Setting.POWERUP_FREQUENCY : 3, Setting.POWERUP_DURATION : 1,
    },
    SLOW_MO : {
        Setting.BALL_SIZE : 1, Setting.BALL_SPEED : 0, Setting.SPAWN_RATE : 0,
        Setting.PADDLE_SPEED : 0, Setting.PADDLE_SIZE : 3,
        Setting.STARTING_LIVES : 2, Setting.LIVES_ON_ELIM : 1,
        Setting.ANGLER_SPAWN_RATE : 1, Setting.SPIRALING_SPAWN_RATE : 1,
        Setting.STOP_AND_START_SPAWN_RATE : 1, Setting.DRIFTER_SPAWN_RATE : 1,
        Setting.PLAYER_CONTROLLED_BALLS : 1,
        Setting.POWERUP_FREQUENCY : 3, Setting.POWERUP_DURATION : 1,
    },
    PAIN : {
        Setting.BALL_SIZE : 1, Setting.BALL_SPEED : 4, Setting.SPAWN_RATE : 2,
        Setting.PADDLE_SPEED : 0, Setting.PADDLE_SIZE : 1,
        Setting.STARTING_LIVES : 9, Setting.LIVES_ON_ELIM : 3,
        Setting.ANGLER_SPAWN_RATE : 0, Setting.SPIRALING_SPAWN_RATE : 0,
        Setting.STOP_AND_START_SPAWN_RATE : 0, Setting.DRIFTER_SPAWN_RATE : 0,
        Setting.PLAYER_CONTROLLED_BALLS : 0,
        Setting.POWERUP_FREQUENCY : 0, Setting.POWERUP_DURATION : 0,
    },
    SUDDEN_DEATH : {
        Setting.BALL_SIZE : 1, Setting.BALL_SPEED : 1, Setting.SPAWN_RATE : 0,
        Setting.PADDLE_SPEED : 3, Setting.PADDLE_SIZE : 4,
        Setting.STARTING_LIVES : 0, Setting.LIVES_ON_ELIM : 0,
        Setting.ANGLER_SPAWN_RATE : 1, Setting.SPIRALING_SPAWN_RATE : 1,
        Setting.STOP_AND_START_SPAWN_RATE : 1, Setting.DRIFTER_SPAWN_RATE : 1,
        Setting.PLAYER_CONTROLLED_BALLS : 0,
        Setting.POWERUP_FREQUENCY : 4, Setting.POWERUP_DURATION : 2,
    },
    TOURNAMENT : {
        Setting.BALL_SIZE : 1, Setting.BALL_SPEED : 2, Setting.SPAWN_RATE : 1,
        Setting.PADDLE_SPEED : 3, Setting.PADDLE_SIZE : 3,
        Setting.STARTING_LIVES : 9, Setting.LIVES_ON_ELIM : 0,
        Setting.ANGLER_SPAWN_RATE : 1, Setting.SPIRALING_SPAWN_RATE : 1,
        Setting.STOP_AND_START_SPAWN_RATE : 1, Setting.DRIFTER_SPAWN_RATE : 1,
        Setting.PLAYER_CONTROLLED_BALLS : 0,
        Setting.POWERUP_FREQUENCY : 0, Setting.POWERUP_DURATION : 0,
    },
}

var _settingIndices: Dictionary = {
    Setting.SETTINGS_FORMAT : 0,
    Setting.BALL_SIZE : 1,
    Setting.BALL_SPEED : 2,
    Setting.SPAWN_RATE : 1,
    Setting.PADDLE_SPEED : 3,
    Setting.PADDLE_SIZE : 3,
    Setting.STARTING_LIVES : 4,
    Setting.LIVES_ON_ELIM : 1,
    Setting.PLAYER_CONTROLLED_BALLS : 1,
    Setting.FULLSCREEN : 1,

    Setting.ANGLER_SPAWN_RATE : 1,
    Setting.SPIRALING_SPAWN_RATE : 1,
    Setting.STOP_AND_START_SPAWN_RATE : 1,
    Setting.DRIFTER_SPAWN_RATE : 1,
    Setting.BEHAVIOR_INTENSITY : 1,
    Setting.POWERUP_FREQUENCY : 3,
    Setting.POWERUP_DURATION : 1,
    Setting.SPIN_TYPE : 0,
    Setting.PRESET : 1,
}

const SETTING_TITLES: Dictionary = {
    Setting.SETTINGS_FORMAT : "Settings Menu",
    Setting.BALL_SIZE : "Ball Size",
    Setting.BALL_SPEED : "Ball Speed",
    Setting.SPAWN_RATE : "Ball Spawn Rate",
    Setting.PADDLE_SPEED : "Paddle Speed",
    Setting.PADDLE_SIZE : "Paddle Size",
    Setting.STARTING_LIVES : "Starting Lives",
    Setting.LIVES_ON_ELIM : "Lives on Elim",
    Setting.PLAYER_CONTROLLED_BALLS : "Zombie Balls",
    Setting.FULLSCREEN : "Fullscreen (F11)",

    Setting.ANGLER_SPAWN_RATE : "Ankle Breakers",
    Setting.SPIRALING_SPAWN_RATE : "Spinners",
    Setting.STOP_AND_START_SPAWN_RATE : "Sleepers",
    Setting.DRIFTER_SPAWN_RATE : "Drifters",
    Setting.BEHAVIOR_INTENSITY : "Intensity",
    Setting.POWERUP_FREQUENCY : "Powerup Rate",
    Setting.POWERUP_DURATION : "Powerup Time",
    Setting.SPIN_TYPE : "Spin Behavior",
    Setting.PRESET : "Preset",
}

const SETTING_VALUES: Dictionary = {
    Setting.SETTINGS_FORMAT : [BORING, BALLS],
    Setting.BALL_SPEED : [25, 50, 75, 100, 200, 400],
    Setting.BALL_SIZE : [3, 5, 10, 15],
    Setting.SPAWN_RATE : [0.1, 0.25, 0.5, 1.0, 2.0, 5.0],
    Setting.PADDLE_SPEED : [0.1, 0.2, 0.5, 1, 2, 4],
    Setting.PADDLE_SIZE : [0.4, 0.6, 0.75, 1, 1.5, 2],
    Setting.STARTING_LIVES : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 100],
    Setting.LIVES_ON_ELIM : [0, 1, 2, 3, 4, 5],
    Setting.PLAYER_CONTROLLED_BALLS : [false, true],
    Setting.FULLSCREEN : [false, true],

    Setting.ANGLER_SPAWN_RATE : [0, 10, 20, 50, 100],
    Setting.SPIRALING_SPAWN_RATE : [0, 10, 20, 50, 100],
    Setting.STOP_AND_START_SPAWN_RATE : [0, 10, 20, 50, 100],
    Setting.DRIFTER_SPAWN_RATE : [0, 10, 20, 50, 100],
    Setting.BEHAVIOR_INTENSITY : [SMOOTH, MIXED, ERRATIC],
    Setting.POWERUP_FREQUENCY : [1000, 10, 5, 2, 1],
    Setting.POWERUP_DURATION : [5, 10, 15, 25],
    Setting.SPIN_TYPE : [],
    Setting.PRESET : [CUSTOM, DEFAULT, POWERPALOOZA, QUIRKY, SPINNERS_PARADISE, PRECISION, SLOW_MO, PAIN, SUDDEN_DEATH, TOURNAMENT]
}

const SETTING_VALUE_NAMES: Dictionary = {
    Setting.SETTINGS_FORMAT : ["Boring", "Balls"],
    Setting.BALL_SIZE : ["hamster", "dog", "bull", "elephant"],
    Setting.BALL_SPEED : ["Sluggish", "Leisurely", "Gentle", "Energetic", "Speedy", "Balls on Crack"],
    Setting.SPAWN_RATE : ["Few Balls", "Some Balls", "Balls", "More Balls", "Balls Balls", "Balls Balls Balls"],
    Setting.PADDLE_SPEED : ["Snail-like", "Steady", "Relaxed", "Active", "Peppy", "Uncontrollable"],
    Setting.PADDLE_SIZE : ["Itsy Bitsy", "Smol", "5' 11\"", "6-foot", "loooong", "Anaconda"],
    Setting.STARTING_LIVES : ["Sudden Death", "2", "3", "4", "5", "6", "7", "8", "9", "10", "20", "30", "40", "50", "Marathon"],
    Setting.LIVES_ON_ELIM : ["0", "1", "2", "3", "4", "5"],
    Setting.PLAYER_CONTROLLED_BALLS : ["Nope", "Yup"],
    Setting.FULLSCREEN : ["Nah", "Extra THICC"],

    Setting.ANGLER_SPAWN_RATE : ["None", "Rare", "Uncommon", "Common", "Frequent"],
    Setting.SPIRALING_SPAWN_RATE : ["None", "Rare", "Uncommon", "Common", "Frequent"],
    Setting.STOP_AND_START_SPAWN_RATE : ["None", "Rare", "Uncommon", "Common", "Frequent"],
    Setting.DRIFTER_SPAWN_RATE : ["None", "Rare", "Uncommon", "Common", "Frequent"],
    Setting.BEHAVIOR_INTENSITY : ["Smooth", "Mixed", "Erratic"],
    Setting.POWERUP_FREQUENCY : ["Never", "10 goals", "5 goals", "2 goals", "GOOOOOOAL"],
    Setting.POWERUP_DURATION : ["Fleeting", "Brief", "Lengthy", "POWERFUL"],
    Setting.SPIN_TYPE : [],
    Setting.PRESET : ["Custom", "Default", "Power-palooza", "Quirky", "Spinner's Paradise", "Precise", "Slow-mo",
                      "Pain", "Sudden Death", "Tournament"]
}

signal onToggleFullscreen()

func setSetting(setting: Setting, index: int):
    if setting == Setting.FULLSCREEN and index != _settingIndices[Setting.FULLSCREEN]: _toggleFullscreen()
    elif setting == Setting.PRESET: setPreset(index)
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


signal onCheckPresets()
signal onSetPreset()

func checkPresets():
    for preset in presets:
        var presetSettings = presets[preset]
        var matchesPreset := true
        for setting in presetSettings:
            if _settingIndices[setting] != presetSettings[setting]:
                matchesPreset = false
                break
        if matchesPreset:
            _settingIndices[Setting.PRESET] = preset
            onCheckPresets.emit()
            return preset
    
    _settingIndices[Setting.PRESET] = CUSTOM
    onCheckPresets.emit()
    return CUSTOM

func setPreset(preset: int):
    for setting in presets[preset]:
        _settingIndices[setting] = presets[preset][setting]
    _settingIndices[Setting.PRESET] = preset
    onSetPreset.emit()


func _process(_delta):
    if Input.is_action_just_pressed("FULLSCREEN"): _toggleFullscreen()