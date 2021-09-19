extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var confirm = get_tree().get_root().get_node("Sound").get_node("BoopHighF");


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	confirm.play();
	get_tree().change_scene("res://prefabs/Field.tscn")
