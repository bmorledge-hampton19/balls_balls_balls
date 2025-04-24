extends Node

var musicPlayer: AudioStreamPlayer2D
var paddleSpins: Dictionary
var theBallRumbling: AudioStreamPlayer2D
var playButton: AudioStreamPlayer2D

const ONE_SHOT_AUDIO_PREFAB: PackedScene = preload("res://scenes/global/one_shot_audio.tscn")

const PADDLE_BOUNCE: AudioStream = preload("res://audio/paddle_bounce.wav")
const PADDLE_SMACK: AudioStream = preload("res://audio/paddle_smack.wav")
const PADDLE_STICK: AudioStream = preload("res://audio/paddle_stick.wav")
const PADDLE_UNSTICK: AudioStream = preload("res://audio/paddle_unstick.wav")

const BUMPER_BOUNCE: AudioStream = preload("res://audio/bumper_bounce.wav")
const WALL_BOUNCE: AudioStream = preload("res://audio/wall_bounce.wav")

const GOAL: AudioStream = preload("res://audio/goal.wav")
const BALL_EXPLOSION: AudioStream = preload("res://audio/ball_explosion.wav")
const BLOCK_EXPLOSION: AudioStream = preload("res://audio/block_explosion.wav")

const PADDLE_CHARGE: AudioStream = preload("res://audio/paddle_charge.wav")
const FAILED_CHARGE: AudioStream = preload("res://audio/failed_charge.wav")
const INITIATE_SPIN: AudioStream = preload("res://audio/initiate_spin.wav")
const SUSTAINED_SPIN: AudioStream = preload("res://audio/placeholder.wav") # DEPRECATED

const ABSORB_POWERUP_PARTICLE: AudioStream = preload("res://audio/absorb_powerup_particle.wav")
const CONFER_POWERUP: AudioStream = preload("res://audio/confer_powerup.wav")

const SPAWN_BALL: AudioStream = preload("res://audio/spawn_ball.wav") # Short attack with fadeout; prevent overlap with activate ball.
const ACTIVATE_BASIC_BALL: AudioStream = preload("res://audio/activate_basic_ball.wav")
const ACTIVATE_ACCEL_BALL: AudioStream = preload("res://audio/activate_accel_ball.wav")
const ACTIVATE_SPIRAL_BALL: AudioStream = preload("res://audio/activate_spiral_ball.wav")
const ACTIVATE_START_AND_STOP_BALL: AudioStream = preload("res://audio/activate_start_and_stop_ball.wav")
const ACTIVATE_DRIFTER_BALL: AudioStream = preload("res://audio/activate_drifter_ball.wav")

const INWARD_PULSE: AudioStream = preload("res://audio/inward_pulse.wav") # 3 seconds total. Mostly fade. Or mostly attack?
const THE_BALL_EXPANSION: AudioStream = preload("res://audio/the_ball_expansion.wav")
const THE_BALL_SUCKING_NOISE: AudioStream = preload("res://audio/the_ball_sucking_noise.wav")
const THE_BALL_SUCKING_FLAT: AudioStream = preload("res://audio/the_ball_sucking_flat.wav")
const THE_BALL_RUMBLING: AudioStream = preload("res://audio/the_ball_rumbling.wav") # 4 sec attack, 1 sec sustain, 5 sec fade.

const PLAY_BUTTON: AudioStream = preload("res://audio/play_button.wav")

const BALLS_VOICE: AudioStream = preload("res://audio/balls_voice.wav")
const GO_VOICE: AudioStream = preload("res://audio/go_voice.wav")
const RED_TEAM_VOICE: AudioStream = preload("res://audio/red_team_voice.wav")
const ORANGE_TEAM_VOICE: AudioStream = preload("res://audio/orange_team_voice.wav")
const BROWN_TEAM_VOICE: AudioStream = preload("res://audio/brown_team_voice.wav")
const YELLOW_TEAM_VOICE: AudioStream = preload("res://audio/yellow_team_voice.wav")
const GREEN_TEAM_VOICE: AudioStream = preload("res://audio/green_team_voice.wav")
const BLUE_TEAM_VOICE: AudioStream = preload("res://audio/blue_team_voice.wav")
const PURPLE_TEAM_VOICE: AudioStream = preload("res://audio/purple_team_voice.wav")
const PINK_TEAM_VOICE: AudioStream = preload("res://audio/pink_team_voice.wav")
const WINS_VOICE: AudioStream = preload("res://audio/wins_voice.wav")

const MENU_MUSIC: AudioStream = preload("res://audio/menu_music.wav")
const PLAYFIELD_MUSIC: AudioStream = preload("res://audio/playfield_music.wav")
const FINAL_SHOWDOWN_MUSIC: AudioStream = preload("res://audio/final_showdown_music.wav")
const RED_WINNER_MUSIC: AudioStream = preload("res://audio/red_winner_music.wav")
const ORANGE_WINNER_MUSIC: AudioStream = preload("res://audio/orange_winner_music.wav")
const BROWN_WINNER_MUSIC: AudioStream = preload("res://audio/brown_winner_music.wav")
const YELLOW_WINNER_MUSIC: AudioStream = preload("res://audio/yellow_winner_music.wav")
const GREEN_WINNER_MUSIC: AudioStream = preload("res://audio/green_winner_music.wav")
const BLUE_WINNER_MUSIC: AudioStream = preload("res://audio/blue_winner_music.wav")
const PURPLE_WINNER_MUSIC: AudioStream = preload("res://audio/purple_winner_music.wav")
const PINK_WINNER_MUSIC: AudioStream = preload("res://audio/pink_winner_music.wav")

var teamColorToAudioBus: Dictionary

var fadingOutMusic: bool
var fadeDuration: float
var fadeTimeRemaining: float

var teamVoiceAudio: OneShotAudio
var winsVoiceAudio: OneShotAudio

func _ready():
	for i in range(8):
		teamColorToAudioBus[PlayerManager.teamColors[i]] = "Step" + str(i+1)

	musicPlayer = AudioStreamPlayer2D.new()
	add_child(musicPlayer)
	musicPlayer.bus = "Music"
	musicPlayer.process_mode = Node.PROCESS_MODE_ALWAYS

	theBallRumbling = AudioStreamPlayer2D.new()
	add_child(theBallRumbling)
	theBallRumbling.stream = THE_BALL_RUMBLING

	playButton = AudioStreamPlayer2D.new()
	add_child(playButton)
	playButton.stream = PLAY_BUTTON
	playButton.bus = "PlayButton"


func _process(delta):
	if fadingOutMusic:
		fadeTimeRemaining -= delta
		if fadeTimeRemaining <= 0:
			fadingOutMusic = false
			fadeTimeRemaining = 0
			stopMusic()
		musicPlayer.volume_db = linear_to_db(1.0*fadeTimeRemaining/fadeDuration)


func _playSound(stream: AudioStream, busName: String = "Master", volume_db: float = 0):
	var oneShotAudio = ONE_SHOT_AUDIO_PREFAB.instantiate()
	add_child(oneShotAudio)
	oneShotAudio.init(stream, busName, volume_db)

func _addPaddleSpin(paddle: Paddle):
	paddleSpins[paddle] = AudioStreamPlayer2D.new()
	paddleSpins[paddle].stream = SUSTAINED_SPIN
	paddleSpins[paddle].bus = teamColorToAudioBus[paddle.team.color]


func playPaddleBounce(teamColor: Color):
	_playSound(PADDLE_BOUNCE, teamColorToAudioBus[teamColor])

func playPaddleSmack(teamColor: Color):
	_playSound(PADDLE_SMACK, teamColorToAudioBus[teamColor])

func playPaddleStick(teamColor: Color):
	_playSound(PADDLE_STICK, teamColorToAudioBus[teamColor])

func playPaddleUnstick(teamColor: Color):
	_playSound(PADDLE_UNSTICK, teamColorToAudioBus[teamColor])


func playBumperBounce():
	_playSound(BUMPER_BOUNCE, "Master", linear_to_db(0.75))

func playWallBounce():
	_playSound(WALL_BOUNCE, "Master", linear_to_db(0.8))


func playGoal(teamColor: Color):
	_playSound(GOAL, teamColorToAudioBus[teamColor])

func playBallExplosion():
	_playSound(BALL_EXPLOSION)

func playBlockExplosion():
	_playSound(BLOCK_EXPLOSION)


func playPaddleCharge(teamColor: Color):
	_playSound(PADDLE_CHARGE, teamColorToAudioBus[teamColor], linear_to_db(0.6))

func playFailedCharge(teamColor: Color):
	_playSound(FAILED_CHARGE, teamColorToAudioBus[teamColor], linear_to_db(0.6))

func playInitiateSpin(teamColor: Color):
	_playSound(INITIATE_SPIN, teamColorToAudioBus[teamColor], linear_to_db(0.6))

func playSustainedSpin(paddle: Paddle):
	if paddle not in paddleSpins: _addPaddleSpin(paddle)
	paddleSpins[paddle].play()

func stopSustainedSpin(paddle: Paddle):
	if paddle not in paddleSpins: return
	paddleSpins[paddle].stop()


func playAbsorbPowerupParticle(teamColor: Color):
	_playSound(ABSORB_POWERUP_PARTICLE, teamColorToAudioBus[teamColor], linear_to_db(0.6))

func playConferPowerup(teamColor: Color):
	_playSound(CONFER_POWERUP, teamColorToAudioBus[teamColor])


func playSpawnBall():
	_playSound(SPAWN_BALL)

func playActivateBall(behavior: Ball.Behavior, volumeMod := 1.0):
	var audioStream: AudioStream
	var linear_volume: float = 1
	match behavior:
		Ball.Behavior.CONSTANT_LINEAR:
			audioStream = ACTIVATE_BASIC_BALL
			linear_volume = 0.5
		Ball.Behavior.ACCEL_LINEAR, Ball.Behavior.ANGLER:
			audioStream = ACTIVATE_ACCEL_BALL
		Ball.Behavior.CONSTANT_SPIRAL, Ball.Behavior.ACCEL_SPIRAL:
			audioStream = ACTIVATE_SPIRAL_BALL
			linear_volume = 0.7
		Ball.Behavior.START_AND_STOP, Ball.Behavior.START_AND_STOP_AND_CHANGE_DIRECTION:
			audioStream = ACTIVATE_START_AND_STOP_BALL
		Ball.Behavior.DRIFT:
			audioStream = ACTIVATE_DRIFTER_BALL
	_playSound(audioStream, "Master", linear_to_db(linear_volume*volumeMod))


func playInwardPulse():
	_playSound(INWARD_PULSE)

func playTheBallExpansion():
	_playSound(THE_BALL_EXPANSION)

func playTheBallSucking():
	print("lol, \"ball sucking\"")
	_playSound(THE_BALL_SUCKING_NOISE)
	_playSound(THE_BALL_SUCKING_FLAT)

func playTheBallRumbling():
	theBallRumbling.play()

func stopTheBallRumbling(): # Deprecated?
	theBallRumbling.stop()


func playPlayButton(completionFraction: float = 0):
	if not playButton.playing: playButton.play()
	AudioServer.get_bus_effect(9, 0).pitch_scale = 0.71 + 0.71*completionFraction**2
	playButton.volume_db = linear_to_db(lerp(0.0,0.5,completionFraction))

func stopPlayButton():
	if playButton.playing:
		playButton.stop()


func playBallsVoice():
	_playSound(BALLS_VOICE, "Master", linear_to_db(0.5))

func playGoVoice():
	_playSound(GO_VOICE, "Master", linear_to_db(0.5))

func _playTeamVoice(teamColor: Color):
	var audioStream: AudioStream
	match teamColor:
		Color.RED:
			audioStream = RED_TEAM_VOICE
		Color.ORANGE:
			audioStream = ORANGE_TEAM_VOICE
		Color.SADDLE_BROWN:
			audioStream = BROWN_TEAM_VOICE
		Color.YELLOW:
			audioStream = YELLOW_TEAM_VOICE
		Color.FOREST_GREEN:
			audioStream = GREEN_TEAM_VOICE
		Color.CYAN:
			audioStream = BLUE_TEAM_VOICE
		Color.PURPLE:
			audioStream = PURPLE_TEAM_VOICE
		Color.HOT_PINK:
			audioStream = PINK_TEAM_VOICE
	teamVoiceAudio = ONE_SHOT_AUDIO_PREFAB.instantiate()
	add_child(teamVoiceAudio)
	teamVoiceAudio.init(audioStream)
	teamVoiceAudio.finished.connect(func(): if not is_queued_for_deletion(): _playWinsVoice(teamColor))

func _playWinsVoice(teamColor: Color):
	winsVoiceAudio = ONE_SHOT_AUDIO_PREFAB.instantiate()
	add_child(winsVoiceAudio)
	winsVoiceAudio.init(WINS_VOICE)
	winsVoiceAudio.finished.connect(func(): if not is_queued_for_deletion(): _playWinnerScreenMusic(teamColor))

func _cleanUpWinnerAudio():
	if is_instance_valid(teamVoiceAudio): teamVoiceAudio.queue_free()
	if is_instance_valid(winsVoiceAudio): winsVoiceAudio.queue_free()

func _playMusic(stream: AudioStream):
	musicPlayer.stream_paused = false
	fadingOutMusic = false
	musicPlayer.volume_db = 0
	if musicPlayer.stream == stream: return
	musicPlayer.stream = stream
	musicPlayer.play()

func playMenuMusic():
	_cleanUpWinnerAudio()
	_playMusic(MENU_MUSIC)

func playPlayfieldMusic():
	_playMusic(PLAYFIELD_MUSIC)

func playFinalShowdownMusic():
	_playMusic(FINAL_SHOWDOWN_MUSIC)

func transitionToFinalShowdownMusic():
	playBallExplosion()
	playFinalShowdownMusic()

func _playWinnerScreenMusic(teamColor: Color):
	var audioStream: AudioStream
	match teamColor:
		Color.RED:
			audioStream = RED_WINNER_MUSIC
		Color.ORANGE:
			audioStream = ORANGE_WINNER_MUSIC
		Color.SADDLE_BROWN:
			audioStream = BROWN_WINNER_MUSIC
		Color.YELLOW:
			audioStream = YELLOW_WINNER_MUSIC
		Color.FOREST_GREEN:
			audioStream = GREEN_WINNER_MUSIC
		Color.CYAN:
			audioStream = BLUE_WINNER_MUSIC
		Color.PURPLE:
			audioStream = PURPLE_WINNER_MUSIC
		Color.HOT_PINK:
			audioStream = PINK_WINNER_MUSIC
	_playMusic(audioStream)

func playWinnerAudio(teamColor: Color):
	_playTeamVoice(teamColor)


func clearOneShotAudios():
	for child in get_children():
		if child is OneShotAudio: child.queue_free()

func pauseMusic():
	musicPlayer.stream_paused = true

func resumeMusic():
	if musicPlayer.stream != null: musicPlayer.stream_paused = false

func stopMusic():
	musicPlayer.stop()
	musicPlayer.stream = null

func fadeOutMusic(duration: float = 2.0):
	fadingOutMusic = true
	fadeDuration = duration
	fadeTimeRemaining = duration