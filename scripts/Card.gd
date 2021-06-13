extends Area2D

var stats = {
	'left': [1, -1, -1],
	'right': [-1, 1, 1],
	'up': [1, 0, 0],
	'down': [-1, 0, 0],
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



onready var interjambs = get_node("Interjambs")
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
	if(get_parent().selected_card == self):
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
				get_parent().selected_card = self
				z_index = get_parent().max_z + 2

		else: # released
			if get_parent().selected_card == self:
				if z_index < local_max_z:
					z_index = local_max_z + 2
				get_parent().max_z = max(z_index, get_parent().max_z)
				
				if in_pairzone:
					var card_to_be_paired = get_parent().get_node("PairZone").card_to_be_paired
					
					if card_to_be_paired:
						print("pairing " + self.name + " with " + card_to_be_paired.name)
						self.queue_free()
						card_to_be_paired.queue_free()
					else:
						get_parent().get_node("PairZone").card_to_be_paired = self
				get_parent().selected_card = null

func is_colliding(point):
	var rect = get_node('CollisionShape2D').get_shape()
	if not (rect is RectangleShape2D):
		return false
	if (point.x <= position.x + rect.extents.x) and (point.x >= position.x - rect.extents.x):
		if (point.y <= position.y + rect.extents.y) and (point.y >= position.y - rect.extents.y):
			return true
	return false

func _on_Card_area_entered(area):
	if get_parent().selected_card != self:
		set_modulate(Color(0,1,0))

func _on_Card_area_exited(area):
	if get_parent().selected_card != self:
		set_modulate(Color(1,1,1))
