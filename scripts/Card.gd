extends Area2D

signal card_entered(card_entered, card_entering)
signal card_exited(card_exited, card_exiting)
signal person_card_quit(card)

const PersonData = preload("res://scripts/PersonData.gd")
const Icon = preload("res://scripts/Icon.gd")
const Posjamb = preload("res://prefabs/PosJamb.tscn")

enum PairState {RESERVOIR, UNPAIRED, PAIRED, CONTAINER}

const offsets = {
	'left': {
		'neu' : Vector2(40, 26),
		'pos' : Vector2(53, 45)
	},
	'right': {
		'neu' : Vector2(-40, 26),
		'pos' : Vector2(-53, 45)
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
var global_rate = 12.0

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
	
	if stats['right'][0] == 1:
		$BoundaryLeft/Upper.disabled = false
	if stats['right'][1] == 1:
		$BoundaryLeft/Lower.disabled = false
	if stats['left'][0] == 1:
		$BoundaryRight/Upper.disabled = false
	if stats['left'][1] == 1:
		$BoundaryRight/Lower.disabled = false

	var icons = $Icons.get_children()
	for i in range(0, len(icons)):
		icons[i].set_icon(pd.icon_ids[i])
		icons[i].set_color(pd.like_mask[i])
		
	$ProgressBar.value = pd.happiness

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
	$Icons.rotation_degrees = wobble_degrees
	$LabelContainer.rotation_degrees = wobble_degrees
	
	if person_data:
		person_data.happiness = person_data.happiness -  delta * global_rate * person_data.rate
		$ProgressBar.value = person_data.happiness
		if person_data.happiness <= 0:
			emit_signal("person_card_quit", self)
	
	
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

func start_wobble():
	wobble = true
	wobble_degrees = 0
	wobble_right = false
	target = 10

func stop_wobble():
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
