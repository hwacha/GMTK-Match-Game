extends Control

const UpdateData = preload("res://scripts/UpdateData.gd")

var pd1 = null
var pd2 = null

var global_rate = 0
var relationship_level = 0

const max_name_length = 12

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
	pass # Replace with function body.

func load_couple(_pd1, _pd2):
	assert(_pd1 and _pd2)
	pd1 = _pd1
	pd2 = _pd2
	
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
	status_text.text = "Status: %s" % update.status
	update_text.text = update.text
	if update.value >= 0:
		bonus_text.text = "+%s" % str(update.value)
	else:
		bonus_text.text = "-%s" % str(update.value)

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	if pd1:
		pd1.happiness = pd1.happiness -  delta * global_rate * pd1.rate
		progress_bar1.value = pd1.happiness
		if pd1.happiness <= 0:
			pass
	if pd2:
		pd2.happiness = pd2.happiness -  delta * global_rate * pd1.rate
		progress_bar2.value = pd2.happiness
		if pd2.happiness <= 0:
			pass
