extends Node

const teamColors: Array[Color] = [
	Color.RED,
	Color.ORANGE,
	Color.YELLOW,
	Color.FOREST_GREEN,
	Color.CYAN,
	Color.PURPLE,
	Color.HOT_PINK,
	Color.WHITE,
]

var players: Array[Player]
var playersByTeamColor: Dictionary


func _ready():
	# print(Input.get_connected_joypads())
	# var multiplayerInputs: Array[DeviceInput] = []
	# for input in Input.get_connected_joypads():
	# 	multiplayerInputs.append(DeviceInput.new(input))
	# for input in multiplayerInputs:
	# 	print(input.get_name())
	initTestPlayers()

func _process(_delta):
	pass
	# print(Input.get_connected_joypads())

func addPlayer(teamColor: Color, inputSet: InputSets.InputSet, sdInput = 0):
	var newPlayer := Player.new(teamColor, inputSet, sdInput)
	players.append(newPlayer)
	if teamColor not in playersByTeamColor: playersByTeamColor[teamColor] = [] as Array[Player]
	playersByTeamColor[teamColor].append(newPlayer)

func clearPlayers():
	players.clear()
	playersByTeamColor.clear()


func initTestPlayers():
	for color in teamColors:
		match color:
			Color.YELLOW:
				addPlayer(color, InputSets.inputSets[6], KEY_ENTER)
			Color.RED:
				addPlayer(color, InputSets.inputSets[7])
			Color.HOT_PINK:
				addPlayer(color, InputSets.inputSets[7])
			Color.PURPLE:
				addPlayer(color, InputSets.inputSets[7])
			Color.ORANGE:
				addPlayer(color, InputSets.inputSets[7])
			Color.FOREST_GREEN:
				addPlayer(color, InputSets.inputSets[7])
			Color.CYAN:
				addPlayer(color, InputSets.inputSets[7])
			Color.WHITE:
				addPlayer(color, InputSets.inputSets[7])
