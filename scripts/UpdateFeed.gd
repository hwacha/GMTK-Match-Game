extends ScrollContainer

signal update_score(score_delta)

const UpdateCard = preload("res://prefabs/UpdateCard.tscn")
const UpdateData = preload("res://scripts/UpdateData.gd")

const match_text = "%s matched with %s!"

onready var update_container = $UpdateContainer
onready var update_factory = $UpdateFactory

# this is very sloppy but for now

func add_couple(pd1, pd2):
	var new_card = UpdateCard.instance()
	new_card.connect("card_update_ready", self, "_on_card_update_ready")
	new_card.connect("card_fadeout_complete", self, "_on_card_fadeout_complete")
	update_container.add_child(new_card)
	update_container.move_child(new_card, 0)
	
	new_card.load_couple(pd1, pd2)
	var custom_match_text = match_text % [pd1.first_name, pd2.first_name]
	var match_update = UpdateData.new(custom_match_text, UpdateData.MATCHED, 0)
	new_card.apply_update(match_update)

func _on_card_update_ready(card, update):
	card.apply_update(update)
	update_container.move_child(card, 0)

	
func _on_card_fadeout_complete(card):
	print('fade_out_complete')
	print(UpdateData.BROKEN_UP == card.relationship_state.status)
	if card.relationship_state.status == UpdateData.BROKEN_UP:
		print('in branch')
		get_parent().post_breakup(card.pd1, card.pd2)
	update_container.remove_child(card)
