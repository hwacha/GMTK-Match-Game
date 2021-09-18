extends ScrollContainer

const UpdateCard = preload("res://prefabs/UpdateCard.tscn")
const UpdateData = preload("res://scripts/UpdateData.gd")

const match_text = "%s matched with %s!"
const match_status = "matched"

onready var update_container = $UpdateContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_couple(pd1, pd2, score_delta):
	var new_card = UpdateCard.instance()
	new_card.connect("card_update_ready", self, "_on_card_update_ready")
	update_container.add_child(new_card)
	update_container.move_child(new_card, 0)
	
	new_card.load_couple(pd1, pd2)
	var custom_match_text = match_text % [pd1.first_name, pd2.first_name]
	var match_update = UpdateData.new(custom_match_text, match_status, UpdateData.MATCHED, score_delta, 0)
	new_card.apply_update(match_update)

func _on_card_update_ready(card, update):
	card.apply_update(update)
	update_container.move_child(card, 0)
	
