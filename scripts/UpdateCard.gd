extends Control

signal card_update_ready(card, update)
signal card_fadeout_complete(card)

const UpdateData = preload("res://scripts/UpdateData.gd")
const PersonData = preload("res://scripts/PersonData.gd")

var pd1 = null
var pd2 = null
var relationship_state = null
var compatibility = 0

var update_factory = null
var field = null

const global_rate = -1
const update_step = 1
const fade_out_duration = 10
const max_name_length = 12

var time_since_update = 0
var time_since_fadeout_start = 0
var waiting_for_update = false
var fading_out = false

onready var sprite1 = $Container/Person1
onready var sprite2 = $Container/Person2
onready var progress_bar1 = $Container/Person1Happiness
onready var progress_bar2 = $Container/Person2Happiness
onready var name_text = $Container/Names
onready var status_text = $Container/Status
onready var bonus_text = $Container/Bonus
onready var update_text = $Container/Update

# Called when the node enters the scene tree for the first time.
func _ready():

	if get_parent() and get_parent().get_parent():
		update_factory = get_parent().get_parent().update_factory
	field = get_tree().get_root().get_node('Field')

func load_couple(_pd1, _pd2):
	assert(_pd1 and _pd2)
	pd1 = _pd1
	pd2 = _pd2
	compatibility = PersonData.score_compatibility(pd1, pd2)
	sprite1.texture = pd1.face_id
	sprite2.texture = pd2.face_id

	var display_name1 = pd1.first_name
	var display_name2 = pd2.first_name

	if len(display_name1) + len(display_name2) > max_name_length:
		display_name1 = display_name1.substr(0, 3) + '.'
		display_name2 = display_name2.substr(0, 3) + '.'
	name_text.text = "%s+%s" % [display_name1, display_name2]
	status_text.text = ""
	bonus_text.text = ""
	update_text.text = ""
	
	progress_bar1.value = pd1.happiness
	progress_bar2.value = pd2.happiness


func apply_update(update: UpdateData):
	var value = UpdateData.get_score(update, relationship_state, compatibility)
	
	field.update_score(value)
	relationship_state = update
	status_text.text = "Status: %s" % UpdateData.status_map[update.status]
	update_text.text = update.text

	if value >= 0:
		bonus_text.text = "+%s" % str(value)
	else:
		bonus_text.text = "%s" % str(value)
	
	if update.status != UpdateData.BROKEN_UP and update.status != UpdateData.MARRIED: 
		waiting_for_update = false
	else:
		time_since_fadeout_start = 0
		fading_out = true

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	if relationship_state and relationship_state.status >= UpdateData.DATING_CASUAL and relationship_state.status <= UpdateData.MARRIED:
		if pd1:
			pd1.happiness = clamp(pd1.happiness -  delta * global_rate * pd1.rate, 0, 100)
			progress_bar1.value = pd1.happiness
			if pd1.happiness <= 0:
				pass
		if pd2:
			pd2.happiness = clamp(pd2.happiness -  delta * global_rate * pd2.rate, 0, 100)
			progress_bar2.value = pd2.happiness
			if pd2.happiness <= 0:
				pass
	
	#print(pd1.first_name, waiting_for_update)
	if not waiting_for_update:
		time_since_update += delta
		if time_since_update >= update_step:
			time_since_update = 0
			waiting_for_update = true
			var update = update_factory.generate_update(pd1, pd2, relationship_state)
			emit_signal('card_update_ready', self, update)
	
	if fading_out:
		time_since_fadeout_start += delta 
		var fade_ratio = time_since_fadeout_start / fade_out_duration
		var new_color = 1 - fade_ratio * fade_ratio
		modulate = Color(new_color, new_color, new_color)

		if time_since_fadeout_start >= fade_out_duration:
			fading_out = false
			print('faded out complete')
			emit_signal('card_fadeout_complete', self)
			
