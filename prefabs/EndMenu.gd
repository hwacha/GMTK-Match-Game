extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var score_singleton = get_tree().get_root().get_node('ScoreSingleton')
	$Score.text = '%06d' % score_singleton.score

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Button_pressed():
	get_tree().change_scene("res://prefabs/Field.tscn")
