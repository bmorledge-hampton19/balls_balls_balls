class_name GameManager
extends Control

@export var camera: Camera2D

var polygon: PolygonGuide.Polygon

@export var leftScoreboard: Scoreboard
@export var rightScoreboard: Scoreboard
@export var playField: Control

class PlayfieldBoundaries:
	var minYOffset: float = -270
	var maxYOffset: float = 270
	var minXOffset: float = -480
	var maxXOffset: float = 480
var boundaries := PlayfieldBoundaries.new()

var transitioning := false
var transitionDuration: float
var transitionTimeElapsed: float
var transitionFraction: float

var oldCenterHeight: float
var centerHeightDelta: float

var oldPlayfieldWidth: float
var playfieldWidthDelta: float

@export var vertexPrefab: PackedScene
@export var verticesControl: Control
var vertices: Array[Vertex]

@export var playfieldBackground: Foreground
@export var theBall: TheBall

@export var wallPrefab: PackedScene
@export var wallsControl: Control
var walls: Dictionary

@export var teamPrefab: PackedScene
@export var teamsControl: Control
var teams: Dictionary

@export var bumperPrefab: PackedScene
@export var bumpersControl: Control
var bumpers: Dictionary

@export var ballManager: BallManager

var scalingInPlayfield: bool
var spinningInPlayField: bool
var spinningAndScalingRatio: float
var targetSpinRotation := PI*4

var fadingInPlayfieldBackground: bool

var fadingInScoreboards: bool
var scoreboardFadeRatio: float

@export var titleText: TitleText
var titleTextBalls := 3
var reduceTitleTextBallsTimer := Timer.new()

var standardTransitionDuration := 10.0

var radiusIncreasePerLostTeam: float
var maxRadiusIncreaseFromTime: float = 54
var radiusIncreaseFromTimeSoFar: float
var timeBetweenRadiusIncreases: float = 30
var timeUntilRadiusIncrease: float = 30

@export var backboardControl: Control
@export var backboardPrefab: PackedScene

@export var winnerPlayfieldPrefab: PackedScene
var transitioningToWinnerScreen

func _ready():

	ResourceLoader.load_threaded_request("res://scenes/WinnerScreen.tscn")
	ResourceLoader.load_threaded_request("res://scenes/Playfield.tscn")
	ResourceLoader.load_threaded_request("res://scenes/MainMenu.tscn")

	ScreenShaker.setCamera(camera)
	AudioManager.stopMusic()

	var activeTeamColors := PlayerManager.getActiveTeamColors()
	activeTeamColors.shuffle()
	polygon = PolygonGuide.polygons[len(activeTeamColors)]
	radiusIncreasePerLostTeam = 54.0/(len(activeTeamColors)-2)
	var teamNum := 0

	for player in PlayerManager.playersByInputSet.values():
		player.goals = 0
		player.goalsAtLastPowerup = 0

	if polygon.sides > 2:

		vertices.append(vertexPrefab.instantiate())
		verticesControl.add_child(vertices[-1])
		vertices[-1].initVertex(polygon.internalAngle*+0.5, polygon.macroRadius, boundaries)

		for teamColor in activeTeamColors:
			
			if teamNum < len(activeTeamColors)-1:
				vertices.append(vertexPrefab.instantiate())
				verticesControl.add_child(vertices[-1])
				vertices[-1].initVertex(polygon.internalAngle*(-teamNum - 0.5), polygon.macroRadius, boundaries)
			else: teamNum = -1

			var newTeam: Team = teamPrefab.instantiate()
			teams[vertices[teamNum]] = newTeam
			teamsControl.add_child(newTeam)
			newTeam.initTeam(
				polygon, vertices[teamNum], vertices[teamNum+1],
				PlayerManager.activePlayersByTeamColor[teamColor], teamColor
			)
			leftScoreboard.addLivesCounter(teamColor, newTeam)
			for player in PlayerManager.activePlayersByTeamColor[teamColor]:
				rightScoreboard.addGoalsCounter(player)
			
			teamNum += 1

		leftScoreboard.modulate.a = 0
		rightScoreboard.modulate.a = 0
		spinningInPlayField = true
		ballManager.explodeAllBalls()

	else:

		leftScoreboard.textControl.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		rightScoreboard.textControl.set_anchors_preset(Control.PRESET_CENTER_LEFT)
		leftScoreboard.beginFade(0)
		rightScoreboard.beginFade(0)

		for angle in [
			polygon.internalAngle/2, -polygon.internalAngle/2,
			polygon.internalAngle/2 - PI, -polygon.internalAngle/2 + PI
		]:
			vertices.append(vertexPrefab.instantiate())
			verticesControl.add_child(vertices[-1])
			vertices[-1].initVertex(angle, polygon.macroRadius, boundaries)

		var leftTeam: Team = teamPrefab.instantiate()
		teams[vertices[-1]] = leftTeam
		teamsControl.add_child(leftTeam)
		leftTeam.initTeam(
			polygon, vertices[-1], vertices[0],
			PlayerManager.activePlayersByTeamColor[activeTeamColors[0]], activeTeamColors[0]
		)
		leftScoreboard.addLivesCounter(activeTeamColors[0], leftTeam)
		for player in PlayerManager.activePlayersByTeamColor[activeTeamColors[0]]:
				rightScoreboard.addGoalsCounter(player)

		var rightTeam = teamPrefab.instantiate()
		teams[vertices[1]] = rightTeam
		teamsControl.add_child(rightTeam)
		rightTeam.initTeam(
			polygon, vertices[1], vertices[2],
			PlayerManager.activePlayersByTeamColor[activeTeamColors[1]], activeTeamColors[1]
		)
		leftScoreboard.addLivesCounter(activeTeamColors[1], rightTeam)
		for player in PlayerManager.activePlayersByTeamColor[activeTeamColors[1]]:
				rightScoreboard.addGoalsCounter(player)

		var newWall: Wall = wallPrefab.instantiate()
		walls[vertices[0]] = newWall
		wallsControl.add_child(newWall)
		newWall.initWall(vertices[0], vertices[1])

		newWall = wallPrefab.instantiate()
		walls[vertices[2]] = newWall
		wallsControl.add_child(newWall)
		newWall.initWall(vertices[2], vertices[3])

		ballManager.prepForFinale(standardTransitionDuration*0.25)
		prepForFinale(leftTeam, rightTeam, true)


	for vertex in vertices:
		bumpers[vertex] = bumperPrefab.instantiate()
		bumpersControl.add_child(bumpers[vertex])
		bumpers[vertex].initBumper(vertex)
	
	for vertex in teams:
		(teams[vertex] as Team).eliminateTeam.connect(reduceBoard)

	if polygon.sides%2 == 0:
		updatePlayfieldCenter(270)
	else:
		updatePlayfieldCenter(polygon.macroRadius)
	updatePlayfieldWidth(polygon.maxWidth)

	ballManager.off = true
	scalingInPlayfield = true
	playField.scale = Vector2.ZERO
	playfieldBackground.modulate.a = 0
	titleText.hide()


func removeVertex(vertex: Vertex):

	for i in range(len(vertex.trackers)-1,-1,-1):
		vertex.trackers[i].switchVertex(walls[vertex].rightVertex)
	if vertex.reducingChild != null:
		vertex.reducingParent.reducingChild = vertex.reducingChild
		pathReducingVertex(vertex.reducingChild)

	walls[vertex].queue_free()
	walls.erase(vertex)
	if vertex in bumpers and vertex.reducingParent in bumpers:
		bumpers[vertex].queue_free()
		bumpers.erase(vertex)
	elif vertex in bumpers:
		bumpers[vertex.reducingParent] = bumpers[vertex]
		bumpers.erase(vertex)
	vertex.queue_free()


func checkBumpers():

	var verticesWithWallToLeft := {}
	var verticesWithWallToRight := {}

	for vertex in walls:
		var wall: Wall = walls[vertex]
		if wall.rightVertex in bumpers: verticesWithWallToLeft[wall.rightVertex] = null
		if wall.leftVertex in bumpers: verticesWithWallToRight[wall.leftVertex] = null
	
	for vertex in verticesWithWallToLeft:
		if vertex in verticesWithWallToRight:
			bumpers[vertex].queue_free()
			bumpers.erase(vertex)


func reduceBoard(eliminatedTeam: Team):

	if not eliminatedTeam in teams.values(): return

	if polygon.sides == 2:
		var winningTeam: Team
		if teams.values()[0] == eliminatedTeam: winningTeam = teams.values()[1]
		else: winningTeam = teams.values()[0]
		PlayerManager.winningTeamColor = winningTeam.color
		# get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/WinnerScreen.tscn"))
		teams.clear()
		beginTransitionToWinnerScreen()
		return

	var newVertexArray: Array[Vertex] = []
	var vertexToEliminateIndex: int
	polygon = PolygonGuide.polygons[polygon.sides-1]

	transitioning = true
	transitionDuration = standardTransitionDuration
	transitionTimeElapsed = 0

	oldCenterHeight = verticesControl.position.y
	if polygon.sides%2 == 0:
		centerHeightDelta = 270 - oldCenterHeight
	else:
		centerHeightDelta = polygon.macroRadius - oldCenterHeight

	oldPlayfieldWidth = 960 - leftScoreboard.size.x*2
	playfieldWidthDelta = polygon.maxWidth - oldPlayfieldWidth

	var newWall: Wall = wallPrefab.instantiate()
	walls[eliminatedTeam.leftVertex] = newWall
	wallsControl.add_child(newWall)
	newWall.initWall(eliminatedTeam.leftVertex, eliminatedTeam.rightVertex)
	checkBumpers()

	for vertex in teams:
		var team = teams[vertex] as Team
		if team == eliminatedTeam:
			vertexToEliminateIndex = vertices.find(vertex)
			leftScoreboard.fadeOutLivesCounter(team)
		else:
			team.changePolygon(polygon, standardTransitionDuration)
			team.addLives(Settings.getSettingValue(Settings.Setting.LIVES_ON_ELIM))
			leftScoreboard.livesCounters[team].showBonusCounter(Settings.getSettingValue(Settings.Setting.LIVES_ON_ELIM))

	if polygon.sides > 2:

		theBall.initiateGrowth(3, radiusIncreasePerLostTeam/3.0)

		var currentVertexIndex: int
		if vertexToEliminateIndex == 1: currentVertexIndex = -1
		else: currentVertexIndex = 1
		vertices[currentVertexIndex].changePolygon(polygon, polygon.internalAngle*0.5, standardTransitionDuration)
		newVertexArray.append(vertices[currentVertexIndex])

		var reducingVertex := eliminatedTeam.leftVertex
		var reducingParent := eliminatedTeam.rightVertex
		reducingVertex.initVertexReduction(reducingParent, standardTransitionDuration)
		reducingVertex.onTransitionEnd.connect(removeVertex)

		var currentVertex := vertices[currentVertexIndex]
		var previousVertex: Vertex
		var targetAngle: float
		var transitionDirection: int
		while len(newVertexArray) < polygon.sides:

			currentVertexIndex += 1
			if currentVertexIndex == len(vertices): currentVertexIndex -= len(vertices)
			if currentVertexIndex == vertexToEliminateIndex:
				currentVertexIndex += 1
				if currentVertexIndex == len(vertices): currentVertexIndex -= len(vertices)
			previousVertex = currentVertex
			currentVertex = vertices[currentVertexIndex]
			targetAngle = polygon.internalAngle*(-len(newVertexArray) + 0.5)

			if (
				doesPathIntersect(previousVertex, currentVertex, targetAngle, Vertex.RIGHT) or
				doesPathOvertake(previousVertex, currentVertex, targetAngle, Vertex.RIGHT)
			):
				transitionDirection = Vertex.LEFT
			else:
				transitionDirection = Vertex.RIGHT

			currentVertex.changePolygon(polygon, targetAngle, standardTransitionDuration, transitionDirection)
			newVertexArray.append(currentVertex)

	elif polygon.sides == 2:

		leftScoreboard.textControl.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		rightScoreboard.textControl.set_anchors_preset(Control.PRESET_CENTER_LEFT)
		leftScoreboard.beginFade(4)
		rightScoreboard.beginFade(4)

		var bottomWallVertex: Vertex
		var leftTeamVertex: Vertex
		var rightTeamVertex: Vertex
		var topWallVertex: Vertex

		bottomWallVertex = vertices[vertexToEliminateIndex]
		leftTeamVertex = vertices[vertexToEliminateIndex-1]
		rightTeamVertex = vertices[vertexToEliminateIndex-2]
		topWallVertex = (teams[rightTeamVertex] as Team).rightVertex

		var topWall: Wall = null

		for vertex in walls:
			if vertex == topWallVertex:
				topWall = walls[vertex]
				vertex.revertReduction()
				vertex.onTransitionEnd.disconnect(removeVertex)
				break

		if topWall == null:

			topWallVertex = vertexPrefab.instantiate()
			verticesControl.add_child(topWallVertex)
			topWallVertex.initVertex(leftTeamVertex.rotation, leftTeamVertex.unadjustedMacroRadius, boundaries)
			(teams[rightTeamVertex] as Team)._rightVertexTracker.switchVertex(topWallVertex)

			var newBumper: Bumper = bumperPrefab.instantiate()
			bumpers[topWallVertex] = newBumper
			bumpersControl.add_child(newBumper)
			newBumper.initBumper(topWallVertex)

			topWall = wallPrefab.instantiate()
			walls[topWallVertex] = topWall
			wallsControl.add_child(topWall)
			topWall.initWall(topWallVertex, leftTeamVertex)

		bottomWallVertex.changePolygon(polygon, polygon.internalAngle*0.5, standardTransitionDuration)

		var targetAngle: float
		var transitionDirection: int

		targetAngle = polygon.internalAngle*-0.5
		if (
			doesPathIntersect(bottomWallVertex, rightTeamVertex, targetAngle, Vertex.RIGHT) or
			doesPathOvertake(bottomWallVertex, rightTeamVertex, targetAngle, Vertex.RIGHT)
		): transitionDirection = Vertex.LEFT
		else: transitionDirection = Vertex.RIGHT
		rightTeamVertex.changePolygon(polygon, targetAngle, standardTransitionDuration, transitionDirection)

		targetAngle = polygon.internalAngle*0.5-PI
		if (
			doesPathIntersect(rightTeamVertex, topWallVertex, targetAngle, Vertex.RIGHT) or
			doesPathOvertake(rightTeamVertex, topWallVertex, targetAngle, Vertex.RIGHT)
		): transitionDirection = Vertex.LEFT
		else: transitionDirection = Vertex.RIGHT
		topWallVertex.changePolygon(polygon, targetAngle, standardTransitionDuration, transitionDirection)

		targetAngle = polygon.internalAngle*-0.5+PI
		if (
			doesPathIntersect(topWallVertex, leftTeamVertex, targetAngle, Vertex.RIGHT) or
			doesPathOvertake(topWallVertex, leftTeamVertex, targetAngle, Vertex.RIGHT)
		): transitionDirection = Vertex.LEFT
		else: transitionDirection = Vertex.RIGHT
		leftTeamVertex.changePolygon(polygon, targetAngle, standardTransitionDuration, transitionDirection)

		newVertexArray = [bottomWallVertex, rightTeamVertex, topWallVertex, leftTeamVertex]

		ballManager.prepForFinale(standardTransitionDuration*0.25)
		prepForFinale(teams[leftTeamVertex], teams[rightTeamVertex])

	teams.erase(vertices[vertexToEliminateIndex])
	vertices = newVertexArray
	for vertex in vertices:
		while vertex.reducingChild != null:
			pathReducingVertex(vertex.reducingChild)
			vertex = vertex.reducingChild
	
	for player in PlayerManager.activePlayersByTeamColor[eliminatedTeam.color]:
		player.paddle = null
		if Settings.getSettingValue(Settings.Setting.PLAYER_CONTROLLED_BALLS):
			ballManager.queuePlayerControlledBall(player)
	eliminatedTeam.queue_free()


func doesPathIntersect(pathedVertex: Vertex, pathingVertex: Vertex, destinationAngle: float, direction: int) -> bool:
	if direction == pathedVertex.transitionDirection or direction == Vertex.NONE:
		return false
	else:
		var angleToIntersection := angle_difference(pathingVertex.rotation, pathedVertex.targetAngle)
		var angleToDestination := angle_difference(pathingVertex.rotation, destinationAngle)
		if direction == Vertex.LEFT:
			if angleToIntersection < 0: angleToIntersection = 2*PI + angleToIntersection
			if angleToDestination < 0: angleToDestination = 2*PI + angleToDestination
			if angleToDestination > angleToIntersection: return true
		elif direction == Vertex.RIGHT:
			if angleToIntersection > 0: angleToIntersection = -2*PI + angleToIntersection
			if angleToDestination > 0: angleToDestination = -2*PI + angleToDestination
			if angleToDestination < angleToIntersection: return true
	return false


func doesPathOvertake(pathedVertex: Vertex, pathingVertex: Vertex, destinationAngle: float, direction: int) -> bool:
	if direction != pathedVertex.transitionDirection or direction == Vertex.NONE:
		return false
	else:
		var angleToPathedVertex := angle_difference(pathingVertex.rotation, pathedVertex.rotation)
		if angleToPathedVertex == 0: return false
		var angleToDestination := angle_difference(pathingVertex.rotation, destinationAngle)
		if direction == Vertex.LEFT:
			if angleToPathedVertex < 0: angleToPathedVertex = 2*PI + angleToPathedVertex
			if angleToDestination < 0: angleToDestination = 2*PI + angleToDestination
			if angleToDestination > angleToPathedVertex + pathedVertex.angleDelta: return true
		elif direction == Vertex.RIGHT:
			if angleToPathedVertex > 0: angleToPathedVertex = -2*PI + angleToPathedVertex
			if angleToDestination > 0: angleToDestination = -2*PI + angleToDestination
			if angleToDestination < angleToPathedVertex + pathedVertex.angleDelta: return true
	return false


func pathReducingVertex(reducingVertex: Vertex):

	var targetParent: Vertex = reducingVertex.reducingParent
	while targetParent.transitionDuration - targetParent.transitionTimeElapsed < reducingVertex.reducingTimeRemaining-0.01:
		targetParent = targetParent.reducingParent
	var direction: int
	var targetAngle: float
	var targetMacroRadius: float

	if is_equal_approx(
		reducingVertex.reducingTimeRemaining, targetParent.transitionDuration - targetParent.transitionTimeElapsed
	):
		targetAngle = targetParent.targetAngle
		targetMacroRadius = targetParent.targetMacroRadius
	else:
		var parentTransitionTimeFraction = (
			(reducingVertex.reducingTimeRemaining+targetParent.transitionTimeElapsed) / targetParent.transitionDuration
		)
		targetAngle = (
			targetParent.oldAngle + targetParent.angleDelta * parentTransitionTimeFraction
		)
		targetMacroRadius = (
			targetParent.oldMacroRadius + targetParent.macroRadiusDelta * parentTransitionTimeFraction
		)

	if targetParent.transitionDirection == Vertex.NONE or targetParent.transitionDirection == Vertex.RIGHT:
		direction = Vertex.RIGHT
	else:
		var angleToDestination := angle_difference(reducingVertex.rotation, targetAngle)

		if angleToDestination < 0: angleToDestination = 2*PI + angleToDestination
		if angleToDestination < targetParent.angleDelta: direction = Vertex.LEFT
		else: direction = Vertex.RIGHT

		# if reducingParent.transitionDirection == Vertex.LEFT:
		# 	if angleToDestination < 0: angleToDestination = 2*PI + angleToDestination
		# 	if angleToDestination < reducingParent.angleDelta: direction = Vertex.LEFT
		# 	else: direction = Vertex.RIGHT

		# elif reducingParent.transitionDirection == Vertex.RIGHT:
		# 	if angleToDestination > 0: angleToDestination = -2*PI + angleToDestination
		# 	if angleToDestination > reducingParent.angleDelta: direction = Vertex.RIGHT
		# 	else: direction = Vertex.LEFT
	
	reducingVertex.changePolygon(polygon, targetAngle, reducingVertex.reducingTimeRemaining, direction, targetMacroRadius)


func getAllVertices() -> Array[Vertex]:
	var allVertices: Array[Vertex]
	for vertex in vertices:
		allVertices.append(vertex)
		while vertex.reducingChild != null:
			vertex = vertex.reducingChild
			allVertices.append(vertex)
	allVertices.sort_custom(
		func(vertex1: Vertex, vertex2: Vertex): 
			return angle_difference(vertex1.rotation, 0) < angle_difference(vertex2.rotation, 0)
	)
	return allVertices

func startCountdown():
	print("Starting countdown")
	titleText.show()
	reduceTitleTextBallsTimer.timeout.connect(reduceTitleTextBalls)
	reduceTitleTextBallsTimer.wait_time = 1.5
	reduceTitleTextBallsTimer.one_shot = true
	add_child(reduceTitleTextBallsTimer)
	reduceTitleTextBallsTimer.start()
	AudioManager.playBallsVoice()

func reduceTitleTextBalls():

	if titleTextBalls > 0: reduceTitleTextBallsTimer.start()
	
	titleTextBalls -= 1

	if titleTextBalls == -1:
		if polygon.sides > 2 or Settings.getSettingValue(Settings.Setting.STARTING_LIVES) > 1: AudioManager.playPlayfieldMusic()
		else: AudioManager.playFinalShowdownMusic()
	elif titleTextBalls == 0:
		titleText.characters = [
			'G','o','!'
		]
		ballManager.off = false
		titleText.updateText()
		AudioManager.playGoVoice()
	elif titleTextBalls == 1:
		titleText.characters = [
			'B', 'a', 'l', 'l', 's',
		]
		titleText.size.y = 117
		titleText.position.y = 211
		titleText.updateText()
		AudioManager.playBallsVoice()
	elif titleTextBalls == 2:
		titleText.characters = [
			'B', 'a', 'l', 'l', 's', ' ',
			'B', 'a', 'l', 'l', 's',
		]
		titleText.size.y = 234
		titleText.position.y = 153
		titleText.updateText()
		AudioManager.playBallsVoice()

func queueStartingSpins():
	var initialDelay := 0.0
	var additiveDelay := 2.0/len(PlayerManager.activePlayers)
	for team in teams.values():
		team.paddleManager.chargePaddles(initialDelay, additiveDelay)
		initialDelay += len(team.players)*additiveDelay


func _process(delta):

	if (
		(Input.is_action_just_pressed("SECONDARY_MENU_BUTTON") or Input.is_action_just_pressed("PRIMARY_MENU_BUTTON")) and
		not transitioningToWinnerScreen
	):
		var pauseMenu := PauseManager.pause()
		pauseMenu.initOptions(["Resume", "Restart", "Return to Main Menu"],
							  [PauseManager.unpause, restart, returnToMainMenu])
		add_child(pauseMenu)

	processStartingEffects(delta)

	if not ballManager.off: timeUntilRadiusIncrease -= delta
	if timeUntilRadiusIncrease <= 0:
		var radiusIncrease = (maxRadiusIncreaseFromTime - radiusIncreaseFromTimeSoFar) * 0.25
		theBall.initiateGrowth(1, radiusIncrease)
		timeUntilRadiusIncrease = timeBetweenRadiusIncreases
		radiusIncreaseFromTimeSoFar = radiusIncrease

	if transitioning:

		transitionTimeElapsed += delta
		if transitionTimeElapsed >= transitionDuration:
			transitionTimeElapsed = transitionDuration
			transitioning = false
			if polygon.sides == 2:
				ballManager.off = false
		transitionFraction = transitionTimeElapsed/transitionDuration

		var playfieldCenter = oldCenterHeight + centerHeightDelta*transitionFraction
		updatePlayfieldCenter(playfieldCenter)
		var playfieldWidth = oldPlayfieldWidth + playfieldWidthDelta*transitionFraction
		updatePlayfieldWidth(playfieldWidth)

	var vertexPositions: Array[Vector2]
	for vertex in getAllVertices():
		vertexPositions.append(playfieldBackground.to_local(vertex.global_position))
	playfieldBackground.polygon = PackedVector2Array(vertexPositions)


func processStartingEffects(delta: float):

	if spinningInPlayField or scalingInPlayfield:
		spinningAndScalingRatio = lerp(spinningAndScalingRatio, 1.075, delta/2)
		if spinningAndScalingRatio >= 1.0:
			spinningAndScalingRatio = 1.0
		if scalingInPlayfield: playField.scale = Vector2.ONE*spinningAndScalingRatio
		if spinningInPlayField: verticesControl.rotation = targetSpinRotation * spinningAndScalingRatio
		if spinningAndScalingRatio == 1.0:
			spinningInPlayField = false
			scalingInPlayfield = false
			fadingInPlayfieldBackground = true
			AudioManager.playSpawnBall()
	
	if fadingInPlayfieldBackground:
		playfieldBackground.modulate.a = lerp(playfieldBackground.modulate.a, 1.1, delta)
		if playfieldBackground.modulate.a >= 0.5 and scoreboardFadeRatio == 0 and not playfieldBackground.finalTwoFadingIn:
			if polygon.sides > 2: fadingInScoreboards = true
			else:
				playfieldBackground.fadeInFinalTwoGraphics(teams[vertices[-1]], teams[vertices[1]], 4)
				addBackboards(teams[vertices[-1]], teams[vertices[1]])
				playfieldBackground.afterfinalTwoFadeIn.connect(
					func(): get_tree().create_timer(3.0, false).timeout.connect(startCountdown)
				)
				playfieldBackground.afterfinalTwoFadeIn.connect(
					queueStartingSpins
				)
		if playfieldBackground.modulate.a >= 1:
			playfieldBackground.modulate.a = 1
			fadingInPlayfieldBackground = false
	
	if fadingInScoreboards:
		scoreboardFadeRatio = lerp(scoreboardFadeRatio, 1.1, delta)
		if scoreboardFadeRatio >= 1.0:
			scoreboardFadeRatio = 1.0
			fadingInScoreboards = false
			queueStartingSpins()
			get_tree().create_timer(3.0, false).timeout.connect(startCountdown)
		leftScoreboard.modulate.a = scoreboardFadeRatio
		rightScoreboard.modulate.a = scoreboardFadeRatio

	if titleTextBalls == -1:
		var newAlpha = titleText.self_modulate.a - 0.5*delta
		if newAlpha < 0:
			newAlpha = 0
			titleTextBalls = -1
		titleText.self_modulate = Color(titleText.self_modulate, newAlpha)

func updatePlayfieldCenter(playfieldCenter: float):

	verticesControl.position.y = playfieldCenter
	ballManager.position.y = playfieldCenter

	boundaries.minYOffset = -playfieldCenter - 0.1
	boundaries.maxYOffset = 540-playfieldCenter + 0.1

	playfieldBackground.updateCenter(playfieldCenter)


func updatePlayfieldWidth(playfieldWidth: float):

	var scoreBoardWidth = (960-playfieldWidth)/2
	leftScoreboard.set_deferred("size", Vector2(scoreBoardWidth, leftScoreboard.size.y))
	rightScoreboard.position.x = 960-scoreBoardWidth
	rightScoreboard.set_deferred("size", Vector2(scoreBoardWidth, rightScoreboard.size.y))

	boundaries.minXOffset = -480 + scoreBoardWidth - 0.1
	boundaries.maxXOffset = 480 - scoreBoardWidth + 0.1


func prepForFinale(leftTeam: Team, rightTeam: Team, atBeginning: bool = false):
	timeUntilRadiusIncrease = 99999

	if atBeginning: playfieldBackground.grid.hide()
	else: playfieldBackground.suckGrid(standardTransitionDuration)
	playfieldBackground.bringTheBallToFront()


	leftTeam.onLivesChanged.connect(func(_lives): playfieldBackground.leftLives.addShake())
	playfieldBackground.leftLives.livesLabel.text = str(leftTeam.livesRemaining)
	leftTeam.onLivesChanged.connect(func(lives): playfieldBackground.leftLives.updateText(lives))
	leftTeam.onLivesChanged.connect(func(_lives): playfieldBackground.modulateDividerSpeed(true, 2))

	rightTeam.onLivesChanged.connect(func(_lives): playfieldBackground.rightLives.addShake())
	playfieldBackground.rightLives.livesLabel.text = str(rightTeam.livesRemaining)
	rightTeam.onLivesChanged.connect(func(lives): playfieldBackground.rightLives.updateText(lives))
	rightTeam.onLivesChanged.connect(func(_lives): playfieldBackground.modulateDividerSpeed(false, 2))

	if not atBeginning:
		playfieldBackground.fadeInFinalTwoGraphics(
			leftTeam, rightTeam, standardTransitionDuration*0.25, standardTransitionDuration
		)
		get_tree().create_timer(standardTransitionDuration, false).timeout.connect(func(): addBackboards(leftTeam, rightTeam))

	if atBeginning: theBall.forceSizeChange(200, 0)
	else: theBall.forceSizeChange(200, standardTransitionDuration)

	if not atBeginning:
		AudioManager.fadeOutMusic()
		get_tree().create_timer(standardTransitionDuration, false).timeout.connect(playFinalShowdownMusic)
	elif Settings.getSettingValue(Settings.Setting.STARTING_LIVES) > 1:
		leftTeam.onLivesChanged.connect(func(_none): transitionToFinalShowdownMusic())
		rightTeam.onLivesChanged.connect(func(_none): transitionToFinalShowdownMusic())

func playFinalShowdownMusic(): AudioManager.playFinalShowdownMusic()


func addBackboards(leftTeam: Team, rightTeam: Team):
	var leftBackboard: Backboard = backboardPrefab.instantiate()
	backboardControl.add_child(leftBackboard)
	leftBackboard.color = leftTeam.color*0.75

	var rightBackboard: Backboard = backboardPrefab.instantiate()
	backboardControl.add_child(rightBackboard)
	rightBackboard.color = rightTeam.color*0.75
	rightBackboard.rotation = PI
	rightBackboard.position = Vector2(960,540)


func transitionToFinalShowdownMusic():
	if AudioManager.musicPlayer.stream == AudioManager.PLAYFIELD_MUSIC and not AudioManager.fadingOutMusic:
		AudioManager.transitionToFinalShowdownMusic()


func beginTransitionToWinnerScreen():
	transitioningToWinnerScreen = true
	ballManager.explodeAllBalls()
	ballManager.off = true
	ScreenShaker.addShake(40, -1)
	var transitionTime: float = 5
	theBall.reparent(self)
	theBall.forceSizeChange(1000, transitionTime, PlayerManager.winningTeamColor)
	get_tree().create_timer(transitionTime, false).timeout.connect(transitionToWinnerScreen)
	AudioManager.playTheBallRumbling()
	AudioManager.fadeOutMusic()

func transitionToWinnerScreen():

	var winnerPlayfield: WinnerScreen = winnerPlayfieldPrefab.instantiate()
	get_parent().add_child(winnerPlayfield)
	winnerPlayfield.camera = camera
	winnerPlayfield.background = ballManager.background
	winnerPlayfield.preparePlayfield()

	var transitionTime: float = 5
	winnerPlayfield.theBall.radius = 1000
	winnerPlayfield.theBall.forceSizeChange(54, transitionTime, PlayerManager.winningTeamColor)
	get_tree().create_timer(transitionTime, false).timeout.connect(winnerPlayfield.reparentTheBall)
	ScreenShaker.clearShakes()
	ScreenShaker.addShake(40, transitionTime)
	get_tree().create_timer(transitionTime, false).timeout.connect(func(): AudioManager.playWinnerAudio(PlayerManager.winningTeamColor))

	queue_free()


func restart():
	PauseManager.unpause()
	AudioManager.clearOneShotAudios()
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/Playfield.tscn"))

func returnToMainMenu():
	PauseManager.unpause()
	AudioManager.clearOneShotAudios()
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/MainMenu.tscn"))
