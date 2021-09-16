extends Area2D

const Card = preload("res://scripts/Card.gd")

const unpair_offset = 22 / 2
const unpair_offsets = {
	'right': Vector2(unpair_offset, 0),
	'left': Vector2(-1 * unpair_offset, 0),
}

var selected = null
var target = null
var direction = null
var pair_state = Card.PairState.CONTAINER

func _ready():
	pass # Replace with function body.

func complete_pair(_selected, _target, _direction):
	selected = _selected
	target = _target
	direction = _direction
	
	
func unpair():
#	for name in ['Child1', 'Child2']:
#		var child = get_node(name)
#		child.set_name('Card')
#		remove_child(child)
#		var multiplier = 1 if name == 'Child1' else -1
#		child.transform.origin = child.transform.origin + transform.origin + offset * multiplier
#		child.pair_state = PairState.UNPAIRED
#		field.add_child(child)
#		child.z_index = z_index
#	field.remove_child(self)
#	queue_free()
#	field.set_selected_card(null)
#
#func _process(delta):
	pass
