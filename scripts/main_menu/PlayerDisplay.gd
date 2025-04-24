class_name PlayerDisplay
extends Node

@export var bumper: Bumper
@export var teamColorRect: ColorRect
@export var teamText: Label
@export var playerIconTextureRect: TextureRect

@export var controllerIconTextureRect: TextureRect
@export var controllerNumLabel: Label
@export var keyboardIconTextureRect: TextureRect

@export var faceButtonsTextureRect: TextureRect
@export var dpadTextureRect: TextureRect
@export var leftStickTextureRect: TextureRect
@export var rightStickTextureRect: TextureRect

@export var keysControl: Control
@export var upKeyTextureRect: TextureRect
@export var rightKeyTextureRect: TextureRect
@export var downKeyTextureRect: TextureRect
@export var leftKeyTextureRect: TextureRect
const controllerPromptsDir = "res://images/controller_prompts/"
const wKey = controllerPromptsDir + "W_Key_Dark.png"
const dKey = controllerPromptsDir + "D_Key_Dark.png"
const sKey = controllerPromptsDir + "S_Key_Dark.png"
const aKey = controllerPromptsDir + "A_Key_Dark.png"
const iKey = controllerPromptsDir + "I_Key_Dark.png"
const lKey = controllerPromptsDir + "L_Key_Dark.png"
const kKey = controllerPromptsDir + "K_Key_Dark.png"
const jKey = controllerPromptsDir + "J_Key_Dark.png"
const upArrowKey = controllerPromptsDir + "Arrow_Up_Key_Dark.png"
const rightArrowKey = controllerPromptsDir + "Arrow_Right_Key_Dark.png"
const downArrowKey = controllerPromptsDir + "Arrow_Down_Key_Dark.png"
const leftArrowKey = controllerPromptsDir + "Arrow_Left_Key_Dark.png"
const eightKey = controllerPromptsDir + "8_Key_Dark.png"
const sixKey = controllerPromptsDir + "6_Key_Dark.png"
const fiveKey = controllerPromptsDir + "5_Key_Dark.png"
const fourKey = controllerPromptsDir + "4_Key_Dark.png"

@export var specialInputTexture: TextureRect
const R1 = controllerPromptsDir + "PS4_R1.png"
const R2 = controllerPromptsDir + "PS4_R2.png"
const L1 = controllerPromptsDir + "PS4_L1.png"
const L2 = controllerPromptsDir + "PS4_L2.png"
const E_KEY = controllerPromptsDir + "E_Key_Dark.png"
const U_KEY = controllerPromptsDir + "U_Key_Dark.png"
const CTRL_KEY = controllerPromptsDir + "Ctrl_Key_Dark.png"
const SPACEBAR = controllerPromptsDir + "Space_Key_Dark.png"
const SEVEN_KEY = controllerPromptsDir + "7_Key_Dark.png"

@export var closeButton: TextureButton

var player: Player
var ball: Ball

var specialInputSpinRate := PI
var specialInputFadingIn: bool
var specialInputFadeInTime := 2.0
var specialInputFullAlphaDuration := 2.0
var specialInputFullAlphaTimeElapsed: float
var specialInputFadingOut: bool
var specialInputFadeOutTime := 2.0
var specialInputZeroAlphaDuration := 4.0
var specialInputZeroAlphaTimeElapsed: float

var spinningPlayerIcon: bool
var playerIconSpinRate := 2*PI


# Called when the node enters the scene tree for the first time.
func _ready():
	specialInputZeroAlphaTimeElapsed = randf_range(0,3.0)

func initPlayerDisplay(p_player: Player):
	player = p_player

	teamColorRect.color = player.teamColor
	teamText.text = "Team " + str(PlayerManager.teamColors.find(player.teamColor) + 1)

	playerIconTextureRect.texture = player.texture

	if player.inputSet.device == -1:
		keyboardIconTextureRect.show()
		keysControl.show()
		match player.inputSet.name:
			InputSets.WASD:
				upKeyTextureRect.texture = preload(wKey)
				rightKeyTextureRect.texture = preload(dKey)
				downKeyTextureRect.texture = preload(sKey)
				leftKeyTextureRect.texture = preload(aKey)
				specialInputTexture.texture = preload(E_KEY)
			InputSets.IJKL:
				upKeyTextureRect.texture = preload(iKey)
				rightKeyTextureRect.texture = preload(lKey)
				downKeyTextureRect.texture = preload(kKey)
				leftKeyTextureRect.texture = preload(jKey)
				specialInputTexture.texture = preload(U_KEY)
			InputSets.ARROW_KEYS:
				upKeyTextureRect.texture = preload(upArrowKey)
				rightKeyTextureRect.texture = preload(rightArrowKey)
				downKeyTextureRect.texture = preload(downArrowKey)
				leftKeyTextureRect.texture = preload(leftArrowKey)
				specialInputTexture.texture = preload(CTRL_KEY)
			InputSets.NUMPAD:
				upKeyTextureRect.texture = preload(eightKey)
				rightKeyTextureRect.texture = preload(sixKey)
				downKeyTextureRect.texture = preload(fiveKey)
				leftKeyTextureRect.texture = preload(fourKey)
				specialInputTexture.texture = preload(SEVEN_KEY)
	else:
		controllerIconTextureRect.show()
		controllerNumLabel.show()
		controllerNumLabel.text = str(player.inputSet.device+1)
		match player.inputSet.name:
			InputSets.FACE_BUTTONS:
				faceButtonsTextureRect.show()
				specialInputTexture.texture = preload(R1)
			InputSets.DPAD:
				dpadTextureRect.show()
				specialInputTexture.texture = preload(L1)
			InputSets.LEFT_JOYSTICK:
				leftStickTextureRect.show()
				specialInputTexture.texture = preload(L2)
			InputSets.RIGHT_JOYSTICK:
				rightStickTextureRect.show()
				specialInputTexture.texture = preload(R2)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var isIconChanged = false
	var isTeamColorChanged = false
	if player.isInputJustPressed(player.leftInput):
		player.icon = PlayerManager.getInactivePlayerIcon(player.icon, true, player.icon, -1)
		isIconChanged = true
	if player.isInputJustPressed(player.rightInput):
		player.icon = PlayerManager.getInactivePlayerIcon(player.icon, true, player.icon, 1)
		isIconChanged = true
	if player.isInputJustPressed(player.upInput):
		var oldColor := player.teamColor
		player.teamColor = PlayerManager.getNextNonFullTeam(player.teamColor, 1)
		PlayerManager.activePlayersByTeamColor[oldColor].erase(player)
		PlayerManager.activePlayersByTeamColor[player.teamColor].append(player)
		isTeamColorChanged = true
	if player.isInputJustPressed(player.downInput):
		var oldColor := player.teamColor
		player.teamColor = PlayerManager.getNextNonFullTeam(player.teamColor, -1)
		PlayerManager.activePlayersByTeamColor[oldColor].erase(player)
		PlayerManager.activePlayersByTeamColor[player.teamColor].append(player)
		isTeamColorChanged = true


	if isIconChanged:
		playerIconTextureRect.texture = player.texture
		ball.ballSprite.texture = player.texture
	if isTeamColorChanged:
		teamColorRect.color = player.teamColor
		teamText.text = "Team " + str(PlayerManager.teamColors.find(player.teamColor) + 1)
		ball.updateColor(player.teamColor)
	

	if specialInputFadingIn:
		specialInputTexture.modulate.a += delta/specialInputFadeInTime
		if specialInputTexture.modulate.a >= 1:
			specialInputTexture.modulate.a = 1
			specialInputFadingIn = false
			specialInputFullAlphaTimeElapsed = 0
	elif specialInputFadingOut:
		specialInputTexture.modulate.a -= delta/specialInputFadeOutTime
		if specialInputTexture.modulate.a <= 0:
			specialInputTexture.modulate.a = 0
			specialInputFadingOut = false
			specialInputZeroAlphaTimeElapsed = 0
	elif specialInputTexture.modulate.a == 1:
		specialInputFullAlphaTimeElapsed += delta
		if specialInputFullAlphaTimeElapsed >= specialInputFullAlphaDuration:
			specialInputFadingOut = true
	elif specialInputTexture.modulate.a == 0:
		specialInputZeroAlphaTimeElapsed += delta
		if specialInputZeroAlphaTimeElapsed >= specialInputZeroAlphaDuration:
			specialInputFadingIn = true
	
	specialInputTexture.rotation += delta*specialInputSpinRate
	if specialInputTexture.rotation > 2*PI: specialInputTexture.rotation -= 2*PI

	if player.isInputJustPressed(player.specialInput) and not spinningPlayerIcon:
		spinningPlayerIcon = true
		AudioManager.playInitiateSpin(player.teamColor)

	if spinningPlayerIcon:
		playerIconTextureRect.rotation += delta*playerIconSpinRate
		if playerIconTextureRect.rotation >= 2*PI:
			playerIconTextureRect.rotation = 0
			spinningPlayerIcon = false
