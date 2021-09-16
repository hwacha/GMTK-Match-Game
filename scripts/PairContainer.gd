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
	
