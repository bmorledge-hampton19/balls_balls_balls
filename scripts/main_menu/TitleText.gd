class_name TitleText
extends RichTextLabel

var characters: Array[String] = [
	'B', 'a', 'l', 'l', 's', ' ',
	'B', 'a', 'l', 'l', 's', ' ',
	'B', 'a', 'l', 'l', 's',
]

var hueBaseValues: Array[float] = [
	0.0, 1.0/15.0, 2.0/15.0, 3.0/15.0, 4.0/15.0, 0.0,
	5.0/15.0, 6.0/15.0, 7.0/15.0, 8.0/15.0, 9.0/15.0, 0.0,
	10.0/15.0, 11.0/15.0, 12.0/15.0, 13.0/15.0, 14.0/15.0,
]

var hueOffset := 0.0
var hueUpdateRate := 0.2

var seizureMode := false

var meanSize := 120.0
var maxSizeVariation := 40.0
# Size update is tied to refresh rate because font size has to be an integer
# and this is the only reasonable way I could find to make it smooth.

var sizes: Array[float] = [
	meanSize + maxSizeVariation, meanSize + maxSizeVariation*5/7, meanSize + maxSizeVariation*3/7,
	meanSize + maxSizeVariation*1/7, meanSize - maxSizeVariation*1/7, 0.0,
	meanSize - maxSizeVariation*3/7, meanSize - maxSizeVariation*5/7, meanSize - maxSizeVariation,
	meanSize - maxSizeVariation*5/7, meanSize - maxSizeVariation*3/7, 0.0,
	meanSize - maxSizeVariation*1/7, meanSize + maxSizeVariation*1/7, meanSize + maxSizeVariation*3/7,
	meanSize + maxSizeVariation*5/7, meanSize + maxSizeVariation
]
var growing: Array[bool] = [
	false, true, true, true, true, true,
	true, true, true, false, false, true,
	false, false, false, false, false
]

# Called when the node enters the scene tree for the first time.
func _ready():
	# for character in characters:
	# 	sizes.append(randf_range(meanSize-maxSizeVariation, meanSize+maxSizeVariation))
	# 	growing.append(bool(randi_range(0, 1)))
	updateText()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	hueOffset += hueUpdateRate*delta
	while hueOffset > 1: hueOffset -= 1
	if seizureMode:
		for i in range(len(sizes)):
			if growing[i]:
				sizes[i] += 1
				if sizes[i] > meanSize + maxSizeVariation:
					growing[i] = false
					sizes[i] += meanSize + maxSizeVariation - sizes[i]
			else:
				sizes[i] -= 1
				if sizes[i] < meanSize - maxSizeVariation:
					growing[i] = true
					sizes[i] += meanSize - maxSizeVariation - sizes[i] 
	updateText()

func updateText():
	clear()
	push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
	for i in range(len(characters)):
		if characters[i] == ' ':
			if seizureMode: push_font_size(int(meanSize + maxSizeVariation))
			append_text(' ')
			if seizureMode: pop()
		else:
			var thisHue: float = hueBaseValues[i] + hueOffset
			while thisHue > 1: thisHue -= 1
			push_color(Color.from_hsv(thisHue, 1, 1))
			if seizureMode: push_font_size(int(sizes[i]))
			append_text(characters[i])
			if seizureMode: pop()
			pop()
