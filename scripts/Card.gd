extends Area2D

signal card_entered(card_entered, card_entering)
signal card_exited(card_exited, card_exiting)

const PersonData = preload("res://scripts/PersonData.gd")
const Icon = preload("res://scripts/Icon.gd")
const Posjamb = preload("res://prefabs/PosJamb.tscn")

enum PairState {RESERVOIR, UNPAIRED, PAIRED, CONTAINER}

const offsets = {
	'left': {
		'neu' : Vector2(40, 26),
		'pos' : Vector2(47, 26)
	},
	'right': {
		'neu' : Vector2(-40, 26),
		'pos' : Vector2(-47, 26)
	},
}
const rotations = {
	'left': 180,
	'right': 0,
}
const dir_map = ['left', 'right']
const dir_pairs = {
	'left' : 'right',
	'right': 'left',
}
var stats = {
	'left': [0, 0],
	'right': [0, 0],
}

var person_data: PersonData = null
var pair_state = PairState.UNPAIRED


onready var interjambs = get_node("Interjambs")
onready var textlabel = get_node("LabelContainer/Label")
onready var face = get_node("Face")
onready var base = get_node("Base")

var wobble = false
var wobble_degrees = 0
var wobble_right = false
var target = 10

func _ready():
	pass
	
func load_person_data(pd: PersonData):
	person_data = pd
	stats = pd.stats
	face.texture = pd.face_id
	textlabel.text = pd.first_name
	name = pd.first_name

	for dir in ['left', 'right']:
		for i in range(0, len(stats[dir])):
			if stats[dir][i] == 1:
				var jamb = Posjamb.instance()
				var offset = offsets[dir]['pos']

				jamb.rotation_degrees = rotations[dir]
				jamb.transform.origin.x = offset.x
				jamb.transform.origin.y = offset.y - offset.y * 2 * i
				jamb.z_index = 1
				self.interjambs.add_child(jamb)

	var icons = $Icons.get_children()
	for i in range(0, len(icons)):
		icons[i].set_icon(pd.icon_ids[i])
		icons[i].set_color(pd.like_mask[i])
		

func _process(delta):
	#self.rotation += 5 * delta
	if wobble:
		var speed = 100
		var vel = -1 * speed if wobble_right else 1 * speed
		wobble_degrees += vel * delta
		if (target > 0 and wobble_degrees > target) or (target <= 0 and wobble_degrees < target):
			target = -1 * target
			wobble_right = not wobble_right
	#rotation_degrees = wobble_degrees
	interjambs.rotation_degrees = wobble_degrees
	face.rotation_degrees = wobble_degrees
	base.rotation_degrees = wobble_degrees
	$Stats.rotation_degrees = wobble_degrees
	$Icons.rotation_degrees = wobble_degrees
	$LabelContainer.rotation_degrees = wobble_degrees


func is_colliding(point):
	var rect = get_node('Full').get_shape()
	if not (rect is RectangleShape2D):
		return false
	if (point.x <= position.x + rect.extents.x) and (point.x >= position.x - rect.extents.x):
		if (point.y <= position.y + rect.extents.y) and (point.y >= position.y - rect.extents.y):
			return true
	return false

func _on_Card_area_entered(area):
	pass
	
func _on_Card_area_exited(area):
	pass

func set_color(color):
	get_node('Base').modulate = color
	get_node('Interjambs').modulate = color



func can_pair(target, our_dir):
	if pair_state != PairState.UNPAIRED or target.pair_state != PairState.UNPAIRED:
		return false

	var their_dir = dir_pairs[our_dir]
	var successful_pair = true
	for i in range(0, 2):
		if stats[our_dir][i] + target.stats[their_dir][i] != 0:
			successful_pair = false
			break
	return successful_pair

func set_invisible():
	for child in get_children():
		child.visible = false
	get_node('Stats').visible = true


#func complete_pair():
#	field.set_selected_card(null)
#	self.queue_free()
#	var total = 0
#	for jamb in get_node("Child1").stats[pair_direction]:
#		total += abs(jamb)
#
#	get_parent().get_node("Score").score += 100 * total

func start_wobble():
	#return
	#print(textlabel.text + ' starts to wobble')
	wobble = true
	wobble_degrees = 0
	wobble_right = false
	target = 10
	
	
func stop_wobble():
	#return
	#print(textlabel.text + ' stops wobbling')
	wobble = false
	wobble_degrees = 0
	wobble_right = false
	target = 10


func _on_Boundary_area_entered(area):
	var card = area.get_parent()
	if card != self and card.get_script() == self.script:
		if pair_state == PairState.UNPAIRED and card.pair_state == PairState.UNPAIRED:
			emit_signal('card_entered', self, card)

func _on_Boundary_area_exited(area):
	var card = area.get_parent()
	if card != self and card.get_script() == self.script:
		emit_signal('card_exited', self, card)
	
