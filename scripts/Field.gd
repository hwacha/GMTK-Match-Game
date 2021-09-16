extends Node2D


export var max_z = 0
const _Card = preload("res://prefabs/Card.tscn")
const Card = preload("res://scripts/Card.gd")
const _PairContainer = preload("res://prefabs/PairContainer.tscn")
const PairContainer = preload("res://scripts/PairContainer.gd")

var selected_card = null
var view_card = null
var target_card = null
var target_direction = null

#onready var card_manager = get_node("CardManager")
onready var _card_view = get_node("PersonViewer")
onready var _pair_view = get_node("PairViewer")
onready var person_factory = get_node('PersonFactory')

var rng = RandomNumberGenerator.new()

var reservoir_cards = []
var prev_mouse_pos = null

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	var num_cards = 20
	for n in range(num_cards):
		
		var card = _Card.instance()
		var x = rng.randi_range(275, 680)
		var y = rng.randi_range(100, 500)
		card.set_position(Vector2(x, y))
		card.z_index = 2 * n
		# have to load the card into the scene before updating it's values
		# kinda weird! feel like there should be a better way to do this
		# will investigate at a later date.
		add_child(card)

		var pd = person_factory.new_person_data()
		card.load_person_data(pd)
		card.connect("card_entered", self, "_card_entered")
		card.connect("card_exited", self, "_card_exited")
	max_z = 2 * num_cards

	var num_reservoir = 6
	for n in range(num_reservoir):
		add_card_to_reservoir()


func set_selected_card(card):
	if card != null:
		print('so this is getting called again huh')
	if selected_card != card:
		update_target(null, null)

	selected_card = card
	
	if card:
		if card.pair_state == Card.PairState.RESERVOIR:
			var old_position = card.global_position
			$Reservoir.remove_card(card)
			self.add_child(card)
			card.global_position = old_position
		max_z += 2
		card.z_index = max_z
	# right now RESERVOIR will be updated to UNPAIRED so this will hit then too
#
#	if card and card.pair_state == card.PairState.UNPAIRED:
#		_card_view.load_person_data(card.person_data)
#		_card_view.visible = true
#		_pair_view.visible = false
#	elif card and card.pair_state == card.PairState.CONTAINER:
#		_pair_view.load_pair_data(card.get_node('Child1').person_data, card.get_node('Child2').person_data)
#		_card_view.visible = false
#		_pair_view.visible = true
#	else:
#		_card_view.visible = false
#		_pair_view.visible = false

func pull_for_view_card():
		var intersections = get_world_2d().get_direct_space_state().intersect_point(get_viewport().get_mouse_position(), 32, [], 1, false, true)
		var local_max_z_index = -1
		var selected = null
		for intersection in intersections:
			var object = intersection.collider
			if object.get_script() in [Card, PairContainer] and object.pair_state != Card.PairState.PAIRED:
				if object.z_index > local_max_z_index:
					selected = object
					local_max_z_index = object.z_index
		update_view_card(selected)
	
func update_view_card(card):
	view_card = card

	if card and card.pair_state in [Card.PairState.UNPAIRED, Card.PairState.RESERVOIR]:
		_card_view.load_person_data(card.person_data)
		_card_view.visible = true
		_pair_view.visible = false

	elif card and card.pair_state == Card.PairState.CONTAINER:
		_pair_view.load_pair_data(card.target.person_data, card.selected.person_data)
		_card_view.visible = false
		_pair_view.visible = true
	else:
		_card_view.visible = false
		_pair_view.visible = false

func add_card_to_reservoir():
	var card = _Card.instance()
	max_z += 2
	card.z_index = max_z
	$Reservoir.add_card(card)
	var pd = person_factory.new_person_data()
	card.load_person_data(pd)
	card.connect("card_entered", self, "_card_entered")
	card.connect("card_exited", self, "_card_exited")
		
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		get_tree().change_scene("res://prefabs/Field.tscn")
	
	var mouse_position = get_viewport().get_mouse_position()
	
	if Input.is_action_just_pressed('mouse_left'):
		set_selected_card(view_card)
	
	if Input.is_action_pressed('mouse_left'):
		if selected_card:
			if selected_card.pair_state in [Card.PairState.CONTAINER, Card.PairState.UNPAIRED, Card.PairState.RESERVOIR]:
				selected_card.set_position(mouse_position)
				if selected_card.pair_state in [Card.PairState.UNPAIRED, Card.PairState.RESERVOIR]:
					selected_card.set_position(Vector2(min(selected_card.transform.origin.x, 1024), selected_card.transform.origin.y))
			else:
				pass
	
	if Input.is_action_just_released('mouse_left'):
		if target_card != null:
			pair_selected_with_target()
		set_selected_card(null)
	
	if Input.is_action_just_pressed('mouse_right'):
		if selected_card and selected_card.pair_state == Card.PairState.CONTAINER:
			selected_card.unpair()

	# note, because of this: right now, it's possible we could somehow click before we have something as our selected card
	# plausible but I think it's fine for now
	# TODO: remove the frame of lag
	if not selected_card: #and mouse_position != prev_mouse_pos:
		pull_for_view_card()
	prev_mouse_pos = mouse_position
				
	#elif Input.is_action_just_pressed('mouse_right')
		
#	if pair_state == PairState.PAIRED:
#		return
#	if event is InputEventMouseButton: # mouse has happened in the frame
#		if event.button_index == BUTTON_LEFT:
#			var overlapping =  get_overlapping_areas()
#			var point = event.position
#			var local_max_z = z_index
#			var in_pairzone = false
#			for area in overlapping:
#				if area.name == "PairZone":
#					in_pairzone = true
#				if area.get_script() == get_script() and area.z_index > local_max_z and area.is_colliding(point):
#					local_max_z = area.z_index
#
#			if event.is_pressed():
#				if z_index == local_max_z:
#					field.set_selected_card(self)
#					event
#					z_index = field.max_z + 2
#
#			else: # released
#				if field.selected_card == self:
#					if z_index < local_max_z:
#						z_index = local_max_z + 2
#					field.max_z = max(z_index, field.max_z)
#
#					if pair_state == PairState.CONTAINER and in_pairzone:
#						complete_pair()
#					if pair_state == PairState.UNPAIRED and target_pair['card'] != null and target_pair['card'].pair_state == PairState.UNPAIRED:
#						attempt_pair_with_target()
#					field.set_selected_card(null)
#		if event.button_index == BUTTON_RIGHT:
#			if event.is_pressed() and pair_state == PairState.CONTAINER:
#				unpair()
#
#
#update
#
#
#

func update_target(new_target,  direction):
	target_direction = direction

	if target_card:
		target_card.set_color(Color(1, 1, 1, 1))
	target_card = new_target
	if target_card:
		target_card.set_color(Color(0.8, 0.2, 0, 1))
	

func _card_exited(exited, exiting):

	if exited == exiting:
		return
	
	if  not (selected_card in [exited, exiting]):
		return

	var new_target = null
	if selected_card == exited:
		new_target = exiting
	else:
		new_target = exited
	
	if new_target == target_card:
		#print('target released: %s', target_card.person_data.first_name)
		update_target(null, null)

	
func _card_entered(entered, entering):
	#print('cards %s, %s' % [entered, entering])

	if not selected_card in [entered, entering]:
		return
	var direction = null
	var new_target = null
	if selected_card == entered:
		new_target = entering
		direction = 'right'
	else:
		new_target = entered
		direction = 'left'
		
	print('potential target: %s from %s' % [new_target.person_data.first_name, direction])
	if selected_card.can_pair(new_target, direction):
		update_target(new_target, direction)
		print('new target: %s', target_card.person_data.first_name)
	else:
		print('pair failed!')


#func _on_Reservoir_input_event(viewport, event, shape_idx):
#	if event is InputEventMouseButton: # mouse has happened in the frame
#		if event.button_index == BUTTON_LEFT:
#			if event.is_pressed():
#				 print('press recieved')


func pair_selected_with_target():
	var curr_target = target_card
	var curr_direction = target_direction
	var curr_selected = selected_card
	print('pairing %s with target %s from direction %s' % [curr_selected.person_data.first_name, curr_target.person_data.first_name, curr_direction])
	curr_selected.pair_state = Card.PairState.PAIRED
	curr_target.pair_state = Card.PairState.PAIRED
	var pair_container = _PairContainer.instance()
	max_z += 2
	pair_container.z_index = max_z
	self.add_child(pair_container) 
	pair_container.position = Vector2((curr_target.position.x + curr_selected.position.x)/2, curr_target.position.y).floor()
	
	# this stuff is absolutely fucked. when we remove the target card,
	# we trigger a exit event, unsetting our target and direction

	curr_target.z_index = 0
	curr_selected.z_index = 0
	self.remove_child(curr_target)
	self.remove_child(curr_selected)
	pair_container.add_child(curr_target)
	pair_container.add_child(curr_selected)
	
	var side_offset = Vector2(94 / 2, 0)
	
	if curr_direction == 'right':
		selected_card.position = side_offset
		curr_target.position =  -1 * side_offset
	elif curr_direction == 'left':
		selected_card.position = -1 * side_offset
		curr_target.position =  side_offset
	#print(pair_container, curr_target)
	pair_container.complete_pair(curr_target, curr_selected, curr_direction)
	set_selected_card(null)
	update_view_card(null)
	#pull_for_view_card()


var unpair_offset = 22 / 2

var unpair_offsets = {
	'right': Vector2(unpair_offset, 0),
	'left': Vector2(-1 * unpair_offset, 0),
}

