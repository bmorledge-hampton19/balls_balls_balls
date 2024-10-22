extends Node

const teamColors: Array[Color] = [
	Color.RED,
	Color.ORANGE,
	Color.YELLOW,
	Color.FOREST_GREEN,
	Color.CYAN,
	Color.PURPLE,
	Color.HOT_PINK,
	Color.SADDLE_BROWN,
]

enum PlayerIcon {
	CIRCLE,
	BASKETBALL, FOOTBALL, SOCCER_BALL, TENNIS_BALL,
	BEAR, CAT, FOX, PUFFERFISH, SAND_DOLLAR,
	EYE,
	RED_ROSE, SUNFLOWER,
	EARTH, MOON, SUN, MARS,
	WII_1, WII_2,
	XBOX_Y, XBOX_B, XBOX_A, XBOX_X,
	PS3_TRIANGLE, PS3_CIRCLE, PS3_CROSS, PS3_SQUARE,
	CAR_TIRE, RECORD, SAW_BLADE,
	GRENADE,
	COOKIE, DONUT, PIZZA, WATERMELON,
	ATOM, DNA, MITOCHONDRIA, RADIOACTIVE,
}

const playerIconDir := "res://images/player_icons/"
func getPlayerIconTexture(playerIcon: PlayerIcon) -> Texture2D:
	match playerIcon:
		PlayerIcon.CIRCLE:
			return preload(playerIconDir + "circle.png")
		PlayerIcon.BASKETBALL:
			return preload(playerIconDir + "basketball.png")
		PlayerIcon.FOOTBALL:
			return preload(playerIconDir + "football.png")
		PlayerIcon.SOCCER_BALL:
			return preload(playerIconDir + "soccer_ball.png")
		PlayerIcon.TENNIS_BALL:
			return preload(playerIconDir + "tennis_ball.png")
		
		PlayerIcon.BEAR:
			return preload(playerIconDir + "bear.png")
		PlayerIcon.CAT:
			return preload(playerIconDir + "cat.png")
		PlayerIcon.FOX:
			return preload(playerIconDir + "fox.png")
		PlayerIcon.PUFFERFISH:
			return preload(playerIconDir + "pufferfish.png")
		PlayerIcon.SAND_DOLLAR:
			return preload(playerIconDir + "sand_dollar.png")
		
		PlayerIcon.EYE:
			return preload(playerIconDir + "eye.png")		

		PlayerIcon.RED_ROSE:
			return preload(playerIconDir + "red_rose.png")
		PlayerIcon.SUNFLOWER:
			return preload(playerIconDir + "sunflower.png")
		
		PlayerIcon.EARTH:
			return preload(playerIconDir + "earth.png")
		PlayerIcon.MOON:
			return preload(playerIconDir + "moon.png")
		PlayerIcon.SUN:
			return preload(playerIconDir + "sun.png")
		PlayerIcon.MARS:
			return preload(playerIconDir + "mars.png")

		PlayerIcon.WII_1:
			return preload(playerIconDir + "Wii_1.png")
		PlayerIcon.WII_2:
			return preload(playerIconDir + "Wii_2.png")
		
		PlayerIcon.XBOX_Y:
			return preload(playerIconDir + "360_Y.png")
		PlayerIcon.XBOX_B:
			return preload(playerIconDir + "360_B.png")
		PlayerIcon.XBOX_A:
			return preload(playerIconDir + "360_A.png")
		PlayerIcon.XBOX_X:
			return preload(playerIconDir + "360_X.png")
		
		PlayerIcon.PS3_TRIANGLE:
			return preload(playerIconDir + "PS3_Triangle.png")
		PlayerIcon.PS3_CIRCLE:
			return preload(playerIconDir + "PS3_Circle.png")
		PlayerIcon.PS3_CROSS:
			return preload(playerIconDir + "PS3_Cross.png")
		PlayerIcon.PS3_SQUARE:
			return preload(playerIconDir + "PS3_Square.png")

		PlayerIcon.CAR_TIRE:
			return preload(playerIconDir + "car_tire.png")
		PlayerIcon.RECORD:
			return preload(playerIconDir + "record.png")
		PlayerIcon.SAW_BLADE:
			return preload(playerIconDir + "saw_blade.png")

		PlayerIcon.GRENADE:
			return preload(playerIconDir + "grenade.png")
		
		PlayerIcon.COOKIE:
			return preload(playerIconDir + "cookie.png")
		PlayerIcon.DONUT:
			return preload(playerIconDir + "donut.png")
		PlayerIcon.PIZZA:
			return preload(playerIconDir + "pizza.png")
		PlayerIcon.WATERMELON:
			return preload(playerIconDir + "watermelon.png")
		
		PlayerIcon.ATOM:
			return preload(playerIconDir + "atom.png")
		PlayerIcon.DNA:
			return preload(playerIconDir + "DNA.png")
		PlayerIcon.MITOCHONDRIA:
			return preload(playerIconDir + "mitochondria.png")
		PlayerIcon.RADIOACTIVE:
			return preload(playerIconDir + "radioactive.png")
		
		_:
			return preload("res://icon.svg")

var isIconActive: Dictionary

var playersByInputSet: Dictionary
var activePlayersByTeamColor: Dictionary


func _ready():
	# print(Input.get_connected_joypads())
	# var multiplayerInputs: Array[DeviceInput] = []
	# for input in Input.get_connected_joypads():
	# 	multiplayerInputs.append(DeviceInput.new(input))
	# for input in multiplayerInputs:
	# 	print(input.get_name())
	for playerIcon in PlayerIcon.values():
		isIconActive[playerIcon] = false
	for teamColor in teamColors:
		activePlayersByTeamColor[teamColor] = [] as Array[Player]
	# initTestPlayers()

func _process(_delta):
	pass
	# print(Input.get_connected_joypads())

func getInactivePlayerIcon(inactivateMe = null, autoActivate = true, startIndex = 0, step = 1) -> PlayerIcon:
	var iconToReturn: PlayerIcon
	while isIconActive[PlayerIcon.values()[startIndex]]:
		startIndex = wrapi(startIndex+step, 0, len(PlayerIcon))
	iconToReturn = PlayerIcon.values()[startIndex]
	if inactivateMe != null: isIconActive[inactivateMe] = false
	if autoActivate: isIconActive[iconToReturn] = true
	return iconToReturn

func getLeastActiveTeamColor() -> Color:
	var leastActiveTeamColor := Color.BLACK
	var leastTeamMembers := 999999
	for color in teamColors:
		var teamMembers = len(activePlayersByTeamColor[color])
		if teamMembers < leastTeamMembers:
			leastActiveTeamColor = color
			leastTeamMembers = teamMembers
	return leastActiveTeamColor

func getNextNonFullTeam(currentColor: Color, step = 1) -> Color:
	var currentIndex := wrapi(teamColors.find(currentColor)+step, 0, len(teamColors))
	while len(activePlayersByTeamColor[teamColors[currentIndex]]) >= 8:
		currentIndex = wrapi(currentIndex+step, 0, len(teamColors))
	return teamColors[currentIndex]


func getActiveTeamColors() -> Array[Color]:
	var activeTeamColors: Array[Color] = []
	for color in teamColors:
		if activePlayersByTeamColor[color]: activeTeamColors.append(color)
	return activeTeamColors


# Really just for testing.
func forceAddPlayer(teamColor: Color, inputSet: InputSets.InputSet, playerIcon: PlayerIcon, sdInput = 0):
	var newPlayer := Player.new(teamColor, inputSet, playerIcon)
	newPlayer.addSDInput(sdInput)
	playersByInputSet[inputSet] = newPlayer
	activePlayersByTeamColor[teamColor].append(newPlayer)
	newPlayer.active = true

func getNewPlayer(inputSet: InputSets.InputSet) -> Player:
	var teamColor = getLeastActiveTeamColor()
	var playerIcon = getInactivePlayerIcon()
	var newPlayer := Player.new(teamColor, inputSet, playerIcon)
	playersByInputSet[inputSet] = newPlayer
	return newPlayer

func getPlayerForInputSet(inputSet: InputSets.InputSet) -> Player:
	var player: Player
	if inputSet in playersByInputSet:
		player = playersByInputSet[inputSet]
		if isIconActive[player.icon]: player.icon = getInactivePlayerIcon()
		else: isIconActive[player.icon] = true
		if len(activePlayersByTeamColor[player.teamColor]) >= 8: player.teamColor = getLeastActiveTeamColor()
	else:
		player = getNewPlayer(inputSet)
	activePlayersByTeamColor[player.teamColor].append(player)
	player.active = true
	return player

func deactivatePlayer(player: Player):
	isIconActive[player.icon] = false
	activePlayersByTeamColor[player.teamColor] as Array[Player].erase(player)
	player.active = false

func clearPlayers():
	for inputSet in playersByInputSet:
		inputSet.unassignPlayer()
		isIconActive[playersByInputSet[inputSet].icon] = false
	playersByInputSet.clear()
	activePlayersByTeamColor.clear()


func initTestPlayers():
			forceAddPlayer(teamColors[0], InputSets.inputSets[0], getInactivePlayerIcon(), KEY_ENTER)
			forceAddPlayer(teamColors[0], InputSets.inputSets[1], getInactivePlayerIcon(), KEY_ENTER)
			forceAddPlayer(teamColors[0], InputSets.inputSets[2], getInactivePlayerIcon(), KEY_ENTER)
			forceAddPlayer(teamColors[0], InputSets.inputSets[3], getInactivePlayerIcon(), KEY_ENTER)
			forceAddPlayer(teamColors[0], InputSets.inputSets[4], getInactivePlayerIcon(), KEY_ENTER)
			forceAddPlayer(teamColors[0], InputSets.inputSets[5], getInactivePlayerIcon(), KEY_ENTER)
			forceAddPlayer(teamColors[0], InputSets.inputSets[6], getInactivePlayerIcon(), KEY_ENTER)
			forceAddPlayer(teamColors[0], InputSets.inputSets[7], getInactivePlayerIcon(), KEY_ENTER)
			forceAddPlayer(getLeastActiveTeamColor(), InputSets.inputSets[8], getInactivePlayerIcon(), KEY_Z)
			forceAddPlayer(getLeastActiveTeamColor(), InputSets.inputSets[9], getInactivePlayerIcon(), KEY_X)
			# forceAddPlayer(getLeastActiveTeamColor(), InputSets.inputSets[10], getInactivePlayerIcon(), KEY_C)
			# forceAddPlayer(getLeastActiveTeamColor(), InputSets.inputSets[11], getInactivePlayerIcon(), KEY_V)
			# forceAddPlayer(getLeastActiveTeamColor(), InputSets.inputSets[12], getInactivePlayerIcon(), KEY_B)
			# forceAddPlayer(getLeastActiveTeamColor(), InputSets.inputSets[13], getInactivePlayerIcon(), KEY_N)
			# forceAddPlayer(getLeastActiveTeamColor(), InputSets.inputSets[14], getInactivePlayerIcon(), KEY_M)
