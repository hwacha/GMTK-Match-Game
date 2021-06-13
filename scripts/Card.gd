extends Area2D

var stats = {
	'left': [0, 0, 0],
	'right': [0, 0, 0],
	'up': [0, 0, 0],
	'down': [0, 0, 0],
}

var offsets = {
	'left': {
		'neu' : Vector2(40, 26),
		'pos' : Vector2(47, 26)
	},
	'up': {
		'neu' : Vector2(26, -72),
		'pos' : Vector2(26, -79),
	},
	'right': {
		'neu' : Vector2(-40, 26),
		'pos' : Vector2(-47, 26)
	},
	'down': {
		'neu' : Vector2(26, 72),
		'pos' : Vector2(26, 79),
	},
}

var rotations = {
	'left': 180,
	'right': 0,
	'up': 90,
	'down': -90
}

var target_pair = {
	'card': null,
	'dir': 'up',
}

var dir_map = ['up', 'right', 'left', 'down']

var dir_pairs = {
	'left' : 'right',
	'right': 'left',
	'up': 'down',
	'down': 'up',
}

var paired = false

onready var interjambs = get_node("Interjambs")
onready var field = get_tree().get_root().get_node('Field')

func _ready():
	var neujamb_prefab = load("res://prefabs/NeuJamb.tscn")
	var posjamb_prefab = load("res://prefabs/PosJamb.tscn")
	for dir in ['left', 'right', 'up', 'down']:
		for i in range(0, len(stats[dir])):
			var jamb = null
			var offset = null
			if stats[dir][i] == 0:
				jamb = neujamb_prefab.instance()
				offset = offsets[dir]['neu']
			if stats[dir][i] == 1:
				jamb = posjamb_prefab.instance()
				offset = offsets[dir]['pos']
			if stats[dir][i] in [0, 1]:
				jamb.rotation_degrees = rotations[dir]
				if dir in ['left', 'right']:
					jamb.transform.origin.x = offset.x
					jamb.transform.origin.y = offset.y - offset.y * i
				else:
					jamb.transform.origin.x = offset.x - offset.x * i
					jamb.transform.origin.y = offset.y
				jamb.z_index = 1
				self.interjambs.add_child(jamb)

func _process(delta):
	if (field.selected_card == self):
		if paired:
			get_parent().set_position(get_viewport().get_mouse_position())
		else:
			set_position(get_viewport().get_mouse_position())

# TODO move pair zone code to here.
func _on_Card_input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton: # mouse has happened in the frame
	
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
				field.selected_card = self
				z_index = field.max_z + 2

		else: # released
			if field.selected_card == self:
				if z_index < local_max_z:
					z_index = local_max_z + 2
				field.max_z = max(z_index, field.max_z)
				
				if in_pairzone:
					var card_to_be_paired = field.get_node("PairZone").card_to_be_paired
					
					if card_to_be_paired:
						print("pairing " + self.name + " with " + card_to_be_paired.name)
						self.queue_free()
						card_to_be_paired.queue_free()
					else:
						field.get_node("PairZone").card_to_be_paired = self
				if not paired and target_pair['card'] != null:
					attempt_pair_with_target()
				field.selected_card = null

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
		set_modulate(Color(0,1,0))

func _on_Card_area_exited(area):
	if field.selected_card != self:
		set_modulate(Color(1,1,1))


func _on_Boundaries_area_shape_entered(area_id, area, area_shape, local_shape):
	var our_dir = dir_map[local_shape]
	var their_dir = dir_map[area_shape]
	if their_dir == dir_pairs[our_dir]:
		target_pair['dir'] = our_dir
		target_pair['card'] = area.get_parent()
		


func _on_Boundaries_area_shape_exited(area_id, area, area_shape, local_shape):
	# TODO: Potential edge cases here where cards aren't untargetted. Be careful
	var our_dir = dir_map[local_shape]
	var their_dir = dir_map[area_shape]
	if their_dir == dir_pairs[our_dir] and area.get_parent() == target_pair['card']:
		target_pair['dir'] = null
		target_pair['card'] = null

func attempt_pair_with_target():
	var target = target_pair['card']
	var our_dir = target_pair['dir']
	var their_dir = dir_pairs[our_dir]
	
	var successful_pair = true
	for i in range(0, 3):
		if stats[our_dir][i] + target.stats[their_dir][i] != 0:
			successful_pair = false
			break
	print('We attempt to pair ', self.name, ' ', 'from direction ' , target_pair['dir'], ' with ', target_pair['card'].name, ' ', 'from direction ' , dir_pairs[target_pair['dir']])
	print('suceeds' if successful_pair else 'failed')

	if successful_pair:
		paired = true
		target.paired = true
		var pair_container = Node2D.new()
		field.add_child(pair_container) 
		field.remove_child(self)
		pair_container.add_child(self)
		field.remove_child(target)
		pair_container.add_child(target)
		var side_offset = 94
		var top_offset = 158
		if our_dir == 'left':
			transform.origin.y = target.transform.origin.y
			transform.origin.x = target.transform.origin.x + side_offset
		elif our_dir == 'right':
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
		

