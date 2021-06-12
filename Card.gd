extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if(get_parent().selected_card == self):
		set_position(get_viewport().get_mouse_position())

# TODO move pair zone code to here.
func _on_Card_input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton: # mouse has happened in the frame
	
		var overlapping =  get_overlapping_areas()
		var point = event.position
		var local_max_z = z_index
		for area in overlapping:
			if area.get_script() == get_script() and area.z_index > local_max_z and area.is_colliding(point):
				local_max_z = area.z_index
		
		if event.is_pressed():
			if z_index == local_max_z:
				get_parent().selected_card = self
				print(get_parent().selected_card.name)
				z_index = get_parent().max_z + 1

		else: # released
			if get_parent().selected_card == self:
				if z_index < local_max_z:
					z_index = local_max_z + 1
				get_parent().max_z = max(z_index, get_parent().max_z)
				get_parent().set_selected_card(null)

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
