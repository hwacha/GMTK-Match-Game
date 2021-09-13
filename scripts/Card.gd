extends Area2D

const PersonData = preload("res://scripts/PersonData.gd")
const Icon = preload("res://scripts/Icon.gd")

const Posjamb = preload("res://prefabs/PosJamb.tscn")

enum PairState {RESERVOIR, UNPAIRED, PAIRED, CONTAINER}


var stats = {
	'left': [0, 0],
	'right': [0, 0],
}

var person_data: PersonData = null


var offsets = {
	'left': {
		'neu' : Vector2(40, 26),
		'pos' : Vector2(47, 26)
	},
	'right': {
		'neu' : Vector2(-40, 26),
		'pos' : Vector2(-47, 26)
	},
}

var rotations = {
	'left': 180,
	'right': 0,
}

var target_pair = {
	'card': null,
	'dir': 'left',
}

var dir_map = ['left', 'right']

var dir_pairs = {
	'left' : 'right',
	'right': 'left',
}

var pair_state = PairState.UNPAIRED

var pair_direction = null

onready var interjambs = get_node("Interjambs")
onready var field = get_tree().get_root().get_node('Field')
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
	#set_color(colors[0])
	var right_boundary = 1024
	var pair_zone_boundary = right_boundary - 135 - 200
	if (field.selected_card == self):
		if pair_state in [PairState.CONTAINER, PairState.UNPAIRED]:
			set_position(get_viewport().get_mouse_position())
			if pair_state == PairState.UNPAIRED:
				set_position(Vector2(min(transform.origin.x, pair_zone_boundary), transform.origin.y))
		else:
			pass

# TODO move pair zone code to here.
func _on_Card_input_event(viewport, event, shape_idx):
	if pair_state == PairState.PAIRED:
		return
	if event is InputEventMouseButton: # mouse has happened in the frame
		if event.button_index == BUTTON_LEFT:
			var overlapping =  get_overlapping_areas()
			var point = event.position
			var local_max_z = z_index
			var in_pairzone = false
			for area in overlapping:
				if area.name == "PairZone":
					in_pairzone = true
				if area.get_script() == get_script() and area.z_index > local_max_z and area.is_colliding(point):
					local_max_z = area.z_index
			
			if event.is_pressed():
				if z_index == local_max_z:
					field.set_selected_card(self)
					z_index = field.max_z + 2
					

			else: # released
				if field.selected_card == self:
					if z_index < local_max_z:
						z_index = local_max_z + 2
					field.max_z = max(z_index, field.max_z)
					
					if pair_state == PairState.CONTAINER and in_pairzone:
						complete_pair()
					if pair_state == PairState.UNPAIRED and target_pair['card'] != null and target_pair['card'].pair_state == PairState.UNPAIRED:
						attempt_pair_with_target()
					field.set_selected_card(null)
		if event.button_index == BUTTON_RIGHT:
			if event.is_pressed() and pair_state == PairState.CONTAINER:
				unpair()

func is_colliding(point):
	var rect = get_node('Full').get_shape()
	if not (rect is RectangleShape2D):
		return false
	if (point.x <= position.x + rect.extents.x) and (point.x >= position.x - rect.extents.x):
		if (point.y <= position.y + rect.extents.y) and (point.y >= position.y - rect.extents.y):
			return true
	return false

func _on_Card_area_entered(area):
	if field.selected_card != self:
		#set_modulate(Color(0,1,0))
		pass

func _on_Card_area_exited(area):
	if field.selected_card != self:
		#set_modulate(Color(1,1,1))
		pass


func _on_Boundaries_area_shape_entered(area_id, area, area_shape, local_shape):
	if self == field.selected_card:
		var our_dir = dir_map[local_shape]
		var their_dir = dir_map[area_shape]
		if their_dir == dir_pairs[our_dir]:
			target_pair['dir'] = our_dir
			var prev_target = target_pair['card']
			target_pair['card'] = area.get_parent()
			if prev_target != target_pair['card'] and can_pair():
				if prev_target != null:
					prev_target.stop_wobble()
				target_pair['card'].start_wobble()

func set_color(color):
	get_node('Base').modulate = color
	get_node('Interjambs').modulate = color

func _on_Boundaries_area_shape_exited(area_id, area, area_shape, local_shape):
	# TODO: Potential edge cases here where cards aren't untargetted. Be careful

	var our_dir = dir_map[local_shape]
	var their_dir = dir_map[area_shape]
	if area != null:
		var exited_card = area.get_parent()
		if self == field.selected_card and exited_card and exited_card.wobble:
			#print("card ", self, 'left  area ', exited_card)
			exited_card.stop_wobble()
		if their_dir == dir_pairs[our_dir] and exited_card == target_pair['card']:
			target_pair['dir'] = null
			target_pair['card'] = null


func can_pair():


	var target = target_pair['card']
	var our_dir = target_pair['dir']
	var their_dir = dir_pairs[our_dir]
	if our_dir in ['up', 'down']:
		return false
	if not target:
		return false

	if pair_state != PairState.UNPAIRED or target.pair_state != PairState.UNPAIRED:
		return false

	var successful_pair = true
	for i in range(0, 2):
		if stats[our_dir][i] + target.stats[their_dir][i] != 0:
			successful_pair = false
			break
	return successful_pair

func attempt_pair_with_target():
	if can_pair():
		var target = target_pair['card']
		var our_dir = target_pair['dir']
		var their_dir = dir_pairs[our_dir]
		#print('We attempt to pair ', self.name, ' ', 'from direction ' , target_pair['dir'], ' with ', target_pair['card'].name, ' ', 'from direction ' , dir_pairs[target_pair['dir']])

		pair_state = PairState.PAIRED
		target.pair_state = PairState.PAIRED
		var pair_container = load("res://prefabs/Card.tscn").instance()
		pair_container.set_invisible()
		pair_container.pair_state = PairState.CONTAINER
		
		# expand the bounding box to be 2x the normal size on the appropriate axis
		var bounding_box = pair_container.get_node('Full')
		var curr_extents = bounding_box.get_shape().get_extents()
		# turns out the shape is a singleton for all cards that persists in memory
		# between scene reloads, very weird, so create a new one
		bounding_box.shape = RectangleShape2D.new()
		
		if our_dir in ['left', 'right']:
			bounding_box.shape.set_extents(Vector2(curr_extents.x * 2, curr_extents.y))
		else:
			bounding_box.shape.set_extents(Vector2(curr_extents.x , curr_extents.y * 2))

		field.add_child(pair_container) 
		field.remove_child(self)
		self.set_name('Child1')
		self.z_index = 0
		self.stop_wobble()
		pair_container.add_child(self)
		field.max_z += 2
		pair_container.z_index = field.max_z
		field.remove_child(target)
		target.set_name('Child2')
		target.z_index = 0
		target.stop_wobble()
		pair_container.add_child(target)
		pair_container.pair_direction = our_dir
		
		var side_offset = 94
		var top_offset = 158
		if our_dir == 'right':
			transform.origin.y = target.transform.origin.y
			transform.origin.x = target.transform.origin.x + side_offset
		elif our_dir == 'left':
			transform.origin.y = target.transform.origin.y
			transform.origin.x = target.transform.origin.x - side_offset
		elif our_dir == 'up':
			transform.origin.x = target.transform.origin.x
			transform.origin.y = target.transform.origin.y + top_offset
		elif our_dir == 'down':
			transform.origin.x = target.transform.origin.x
			transform.origin.y = target.transform.origin.y - top_offset
		
		
		pair_container.transform.origin = (transform.origin + target.transform.origin) / 2
		
		transform.origin = transform.origin - pair_container.transform.origin 
		target.transform.origin = target.transform.origin - pair_container.transform.origin
		

func set_invisible():
	for child in get_children():
		child.visible = false
	get_node('Stats').visible = true

func complete_pair():
	field.set_selected_card(null)
	self.queue_free()
	var total = 0
	for jamb in get_node("Child1").stats[pair_direction]:
		total += abs(jamb)

	get_parent().get_node("Score").score += 100 * total


var unpair_offset = 22 / 2

var unpair_offsets = {
	'right': Vector2(unpair_offset, 0),
	'left': Vector2(-1 * unpair_offset, 0),
	'down': Vector2(0, -1 * unpair_offset),
	'up': Vector2(0, unpair_offset),
}
func unpair():
	var offset = unpair_offsets[pair_direction]
	for name in ['Child1', 'Child2']:
		var child = get_node(name)
		child.set_name('Card')
		remove_child(child)
		var multiplier = 1 if name == 'Child1' else -1
		child.transform.origin = child.transform.origin + transform.origin + offset * multiplier
		child.pair_state = PairState.UNPAIRED
		field.add_child(child)
		child.z_index = z_index
	field.remove_child(self)
	queue_free()
	field.set_selected_card(null)

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
