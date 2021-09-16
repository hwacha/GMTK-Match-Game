extends Node2D

const PersonData = preload("res://scripts/PersonData.gd")
const Icon = preload("res://prefabs/Icon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

const like_start = Vector2(-30, 127)
const hate_start = Vector2(-30, 173)
const icon_offset = 35


func load_person_data(pd: PersonData):
	
	for child in $HateContainer.get_children():
		$HateContainer.remove_child(child)

	for child in $LikeContainer.get_children():
		$LikeContainer.remove_child(child)

	$Sprite.texture = pd.face_id
	$NameAge.text = "%s, %s" % [pd.first_name, pd.age]
	$Bio.text = pd.bio
	
	var like_count = 0
	var hate_count = 0

	for i in range(0, len(pd.icon_ids)):
		var icon = Icon.instance()
		match pd.like_mask[i]:
			0:
				$HateContainer.add_child(icon)
				icon.set_position(Vector2(hate_start.x + icon_offset * hate_count, hate_start.y))
				hate_count += 1
			1:
				$LikeContainer.add_child(icon)
				icon.set_position(Vector2(like_start.x + icon_offset * like_count, like_start.y))
				like_count += 1
		icon.set_icon(pd.icon_ids[i])
		icon.set_color(pd.like_mask[i])

