extends Node2D

const PersonData = preload("res://scripts/PersonData.gd")
const Icon = preload("res://prefabs/Icon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

const similarity_start = Vector2(-48*2.5 + 2, 21)
const difference_start1 = Vector2(-48*2.5 + 2, 73)
const difference_start2 =  difference_start1 + Vector2(48 * 3, 0)
const icon_offset = 35


func load_pair_data(pd1: PersonData, pd2: PersonData):
	
	for child in $SimilarityContainer.get_children():
		$SimilarityContainer.remove_child(child)

	for child in $DifferenceContainer.get_children():
		$DifferenceContainer.remove_child(child)
	
	for child in $DifferenceContainer2.get_children():
		$DifferenceContainer2.remove_child(child)
	
	$None1.visible = false
	$None2.visible = false

	$Sprite1.texture = pd1.face_id
	$Sprite2.texture = pd2.face_id
	$NameAge1.text = "%s, %s" % [pd1.first_name, pd1.age]
	$NameAge2.text = "%s, %s" % [pd2.first_name, pd2.age]
	
	var similarity_count = 0
	var difference_count = 0
	
	
	for i in range(0, len(pd1.icon_ids)):
		var match_loc = pd2.icon_ids.find(pd1.icon_ids[i])
		if match_loc != -1:
			if pd1.like_mask[i] == pd2.like_mask[match_loc]:
				var icon = Icon.instance()
				$SimilarityContainer.add_child(icon)
				icon.set_position(Vector2(similarity_start.x + icon_offset * similarity_count, similarity_start.y))
				similarity_count += 1
				icon.set_icon(pd1.icon_ids[i])
				icon.set_color(pd1.like_mask[i])
			else:
				var icon1 = Icon.instance()
				$DifferenceContainer.add_child(icon1)
				icon1.set_position(Vector2(difference_start1.x + icon_offset * difference_count, difference_start1.y))
				icon1.set_icon(pd1.icon_ids[i])
				icon1.set_color(pd1.like_mask[i])
				
				var icon2 = Icon.instance()
				$DifferenceContainer2.add_child(icon2)
				icon2.set_position(Vector2(difference_start2.x + icon_offset * difference_count, difference_start2.y))
				icon2.set_icon(pd2.icon_ids[match_loc])
				icon2.set_color(pd2.like_mask[match_loc])
				
				difference_count += 1
	if len($SimilarityContainer.get_children()) == 0:
		$None1.visible = true
	if len($DifferenceContainer.get_children()) == 0:
		$None2.visible = true
	
	var compatibility = len($SimilarityContainer.get_children()) - len($DifferenceContainer.get_children())
		
	var compatibility_text = ''
	if compatibility <= -2:
		compatibility_text = 'TERRIBLE'
	elif compatibility == -1:
		compatibility_text = 'LOW'
	elif compatibility == 0:
		compatibility_text = 'NORMAL'
	elif compatibility == 1:
		compatibility_text = 'HIGH'
	elif compatibility >= 2:
		compatibility_text = 'AMAZING'
	
	$CompatibilityValue.text = compatibility_text
