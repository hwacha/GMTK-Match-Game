extends Node2D

export var max_z = 0
const _Card = preload("res://prefabs/Card.tscn")
const Card = preload("res://scripts/Card.gd")
const _PairContainer = preload("res://prefabs/PairContainer.tscn")
const PairContainer = preload("res://scripts/PairContainer.gd")
const EndMenu = preload("res://prefabs/EndMenu.tscn")
var selected_card = null
var view_card = null
var target_card = null
var target_direction = null

var in_pairzone = false
var score = 0
var lives = 10

onready var _card_view = get_node("PersonViewer")
onready var _pair_view = get_node("PairViewer")
onready var person_factory = get_node('PersonFactory')

var rng = RandomNumberGenerator.new()

var prev_mouse_pos = null

var graveyard = []

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	var num_cards = 4
	for n in range(num_cards):
		add_card_to_field()

	var num_reservoir = 10
	for n in range(num_reservoir):
		add_card_to_reservoir()

func _finish_add_card(card):
	var pd = person_factory.new_person_data()
	card.load_person_data(pd)
	card.connect("card_entered", self, "_card_entered")
	card.connect("card_exited", self, "_card_exited")
	card.connect("person_card_quit", self, "_person_card_quit")
	max_z += 2
	card.z_index = max_z

func add_card_to_field():
	var card = _Card.instance()
	# have to load the card into the scene before updating it's values
	# kinda weird! feel like there should be a better way to do this
	add_child(card)
	
	_finish_add_card(card)

	var x = rng.randi_range(288 + 100, 764 - 100)
	var y = rng.randi_range(200, 300)
	card.set_position(Vector2(x, y))

func add_card_to_reservoir():
	var card = _Card.instance()
	$Reservoir.add_card(card)
	_finish_add_card(card)


func set_selected_card(card):
	assert(not card or card.pair_state != Card.PairState.PAIRED)

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
		return selected
	
func update_view_card(card):
	view_card = card
	
	# new case: when we have the card selected, and have a target, we show both
	if card and card == selected_card and target_card:
		_pair_view.load_pair_data(selected_card.person_data, target_card.person_data)
		_card_view.visible = false
		_pair_view.visible = true
	#  single card hover/selected
	elif card and card.pair_state in [Card.PairState.UNPAIRED, Card.PairState.RESERVOIR]:
		_card_view.load_person_data(card.person_data)
		_card_view.visible = true
		_pair_view.visible = false
	# pair hover/selected
	elif card and card.pair_state == Card.PairState.CONTAINER:
		_pair_view.load_pair_data(card.target.person_data, card.selected.person_data)
		_card_view.visible = false
		_pair_view.visible = true
	# nothing under mouse
	else:
		_card_view.visible = false
		_pair_view.visible = false

func _process(delta):
	#if Input.is_action_just_pressed("ui_up"):
	#	get_tree().change_scene("res://prefabs/Field.tscn")
	
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
		elif in_pairzone and selected_card and selected_card.pair_state == Card.PairState.CONTAINER:
			submit_pair()
		set_selected_card(null)
		update_view_card(null)
	
	if Input.is_action_just_pressed('mouse_right'):
		if view_card and view_card.pair_state == Card.PairState.CONTAINER:
			unpair(view_card)

	# note: we're relying on a physics proccess, which means it could get a
	# frame out of sync. seems responsive enough for now.
	if not selected_card: #and mouse_position != prev_mouse_pos:
		update_view_card(pull_for_view_card())
	else:
		update_view_card(selected_card)
	prev_mouse_pos = mouse_position


func update_target(new_target,  direction):
	target_direction = direction

	if target_card:
		target_card.set_color(Color(1, 1, 1, 1))
	target_card = new_target
	if target_card:
		target_card.set_color(Color(float(239) / 255, float(236) / 255, float(207) / 255, 1))


func pair_selected_with_target():
	assert(selected_card.pair_state == Card.PairState.UNPAIRED)
	assert(target_card.pair_state == Card.PairState.UNPAIRED)
	
	# when we remove the target card, we trigger a exit event
	# unsetting our target and direction. this is cursed so we're
	# stashing the current object references before we mess with them
	var curr_target = target_card
	var curr_direction = target_direction
	var curr_selected = selected_card

	curr_selected.pair_state = Card.PairState.PAIRED
	curr_target.pair_state = Card.PairState.PAIRED
	var pair_container = _PairContainer.instance()
	max_z += 2
	pair_container.z_index = max_z
	self.add_child(pair_container) 
	pair_container.position = Vector2((curr_target.position.x + curr_selected.position.x)/2, curr_target.position.y).floor()

	curr_target.z_index = 0
	curr_selected.z_index = 0
	self.remove_child(curr_target)
	self.remove_child(curr_selected)
	pair_container.add_child(curr_target)
	pair_container.add_child(curr_selected)
	
	var side_offset = Vector2(108 / 2, 0)
	
	if curr_direction == 'right':
		selected_card.position = side_offset
		curr_target.position =  -1 * side_offset
	elif curr_direction == 'left':
		selected_card.position = -1 * side_offset
		curr_target.position =  side_offset

	pair_container.complete_pair(curr_target, curr_selected, curr_direction)
	set_selected_card(null)
	update_view_card(null)


const unpair_offset = Vector2(11, 0)

func unpair(pair_container):
	var was_view = (pair_container == view_card)

	for card in [pair_container.target, pair_container.selected]:
		var original_pos = card.global_position
		pair_container.remove_child(card)

		var multiplier = 1 if card == pair_container.selected else -1
		if pair_container.direction == 'right':
			multiplier = -1 if card == pair_container.selected else 1

		card.global_position = original_pos + unpair_offset * multiplier
		card.pair_state = Card.PairState.UNPAIRED
		self.add_child(card)
		card.z_index = max_z

	self.remove_child(pair_container)
	pair_container.queue_free()
	if was_view:
		set_selected_card(null)
		update_view_card(null)

func submit_pair():
	var pair_container = selected_card
	assert(pair_container.pair_state == Card.PairState.CONTAINER)
	set_selected_card(null)
	update_view_card(null)
	
	var pd1 = pair_container.selected.person_data
	var pd2 = pair_container.target.person_data
	
	$UpdateFeed.add_couple(pd1, pd2)
	pair_container.queue_free()
	

## Handle Signals
func _card_exited(exited, exiting):
	assert(exited != exiting)
	if  not (selected_card in [exited, exiting]):
		return

	var new_target = null
	if selected_card == exited:
		new_target = exiting
	else:
		new_target = exited

	if new_target == target_card:
		update_target(null, null)
	
func _card_entered(entered, entering):
	assert(entering != entered)
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

	if selected_card.can_pair(new_target, direction):
		update_target(new_target, direction)
	else:
		pass

func _on_PairZone_area_entered(area):
	in_pairzone = true

func _on_PairZone_area_exited(area):
	in_pairzone = false

func _person_card_quit(card):
	var pd = card.person_data
	process_death(pd)
	match card.pair_state:
		Card.PairState.RESERVOIR:
			$Reservoir.remove_card(card)
		Card.PairState.PAIRED:
			var pair_container = card.get_parent()
			unpair(pair_container)
			self.remove_child(card)
		Card.PairState.UNPAIRED:
			self.remove_child(card)
	

func update_score(value):
	score += value
	$Score.text = str(score)

func process_death(pd):
	lives = lives - 1
	$StarContainer.update_stars(lives)
	if lives <= 0:
		end_game()
	
func post_breakup(pd1, pd2):
	for pd in [pd1, pd2]:
		var card = _Card.instance()
		add_child(card)
		card.load_person_data(pd)
		card.connect("card_entered", self, "_card_entered")
		card.connect("card_exited", self, "_card_exited")
		card.connect("person_card_quit", self, "_person_card_quit")
		max_z += 2
		card.z_index = max_z
		var x = rng.randi_range(288 + 100, 764 - 100)
		var y = rng.randi_range(200, 300)
		card.set_position(Vector2(x, y))

func end_game():
	
	var score_singleton = get_tree().get_root().get_node('ScoreSingleton')
	score_singleton.score = score
	get_tree().change_scene("res://prefabs/EndMenu.tscn")
	queue_free()
	
	
