extends Control

const mainMenuScene: PackedScene = preload("res://scenes/MainMenu.tscn")

@export var drBeanControl: Control
@export var notTextControl: Control
@export var ball: Ball
@export var drBeanSprite: Sprite2D
@export var drBeanAnimationPlayer: AnimationPlayer

@export var trailPrefab: PackedScene
@export var trailsCanvasGroup: CanvasGroup

@export var idleTexture: Texture2D
@export var aimingTexture: Texture2D
@export var smackTexture: Texture2D

@export var topWall: Wall
@export var bottomWall: Wall
@export var leftWall: Wall
@export var rightWall: Wall

@export var noise: FastNoiseLite

var fadeInDelay: float = 1.0
var fadingIn: bool
var fadeInDuration: float = 2.0

var timeUntilFadeOut: float = 10.0
var fadingOut: bool
var fadeOutDuration: float = 2.0

var drBeanAnchor: Vector2

enum BeanState {IDLE, AIMING, SMACK}
var beanState: BeanState
var texturesByBeanState: Dictionary
var hFramesByBeanState: Dictionary

var jittering: bool
var noisePos: float
var jitterSpeed: float = 5

enum {NONE, CLOCKWISE, COUNTERCLOCKWISE}
var lastCircle: int

func updateAnimation():
    drBeanAnimationPlayer.play(BeanState.keys()[beanState].to_lower())
    drBeanSprite.texture = texturesByBeanState[beanState]
    drBeanSprite.hframes = hFramesByBeanState[beanState]


func _ready():

    texturesByBeanState = {
        BeanState.IDLE : idleTexture, BeanState.AIMING : aimingTexture, BeanState.SMACK : smackTexture,
    }
    hFramesByBeanState = {
        BeanState.IDLE : 9, BeanState.AIMING : 1, BeanState.SMACK : 3,
    }

    drBeanControl.modulate.a = 0

    var newTrail: Trail = trailPrefab.instantiate()
    ball.trail = newTrail
    trailsCanvasGroup.add_child(newTrail)
    ball.updateColor(Color8(87,159,228))
    ball.radius = 5

    beanState = BeanState.IDLE

    drBeanAnchor = notTextControl.position

    InputSets.onAnyCircle.connect(onCircle)


func _process(delta):

    if Input.is_action_just_pressed("PRIMARY_MENU_BUTTON") or Input.is_action_just_pressed("SECONDARY_MENU_BUTTON"):
        transitionToNextScene()
    processFades(delta)
    if jittering: processJitter(delta)
    else: notTextControl.position = drBeanAnchor
    processWalls()
    

func processFades(delta):
    if fadeInDelay > 0:
        fadeInDelay -= delta
        if fadeInDelay <= 0:
            fadingIn = true
            updateAnimation()
    
    if fadingIn:
        drBeanControl.modulate.a += delta/fadeInDuration
        if drBeanControl.modulate.a >= 1:
            drBeanControl.modulate.a = 1
            fadingIn = false
    
    if timeUntilFadeOut > 0:
        timeUntilFadeOut -= delta
        if timeUntilFadeOut <= 0: fadingOut = true
    
    if fadingOut:
        drBeanControl.modulate.a -= delta/fadeOutDuration
        if drBeanControl.modulate.a <= 0:
            drBeanControl.modulate.a = 0
            drBeanAnimationPlayer.stop()
            get_tree().create_timer(0.5).timeout.connect(transitionToNextScene)


func processJitter(delta):
    noisePos += delta*jitterSpeed
    notTextControl.position = Vector2(
        round(noise.get_noise_2d(0, noisePos)*2.4)*2,
        round(noise.get_noise_2d(100, noisePos)*2.4)*2
    ) + drBeanAnchor


func processWalls():
    topWall.sideLength = size.x
    topWall.position.x = size.x
    bottomWall.sideLength = size.x
    leftWall.sideLength = size.y
    rightWall.sideLength = size.y
    rightWall.position = size


func clickOnPaddle():
    if fadingOut: return
    if beanState == BeanState.AIMING:
        beanState = BeanState.SMACK
        updateAnimation()
        jittering = false
        timeUntilFadeOut = 5.0

func clickOnBall():
    if fadingOut: return
    if beanState == BeanState.IDLE:
        beanState = BeanState.AIMING
        updateAnimation()
        timeUntilFadeOut = 4.0
        jittering = true
    elif beanState == BeanState.AIMING:
        beanState = BeanState.SMACK
        updateAnimation()
        jittering = false
        timeUntilFadeOut = 5.0


func onCircle(_inputSet, clockwise: bool):
    if fadingOut: return
    if lastCircle == NONE:
        if clockwise: lastCircle = CLOCKWISE
        else: lastCircle = COUNTERCLOCKWISE
        clickOnBall()
    elif (lastCircle == COUNTERCLOCKWISE and clockwise) or (lastCircle == CLOCKWISE and not clockwise):
        clickOnBall()


func transitionToNextScene():
    get_tree().change_scene_to_packed(mainMenuScene)
