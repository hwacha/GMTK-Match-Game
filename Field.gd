extends Node

export var max_z = 0

var selected_card = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func set_selected_card(card):
	yield(get_tree(), "idle_frame")
	selected_card = card

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
