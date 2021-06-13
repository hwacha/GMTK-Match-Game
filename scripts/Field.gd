extends Node

export var max_z = 0

var selected_card = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		get_tree().change_scene("res://prefabs/Field.tscn")
