extends Area2D

# the single card waiting to be paired
var card_to_be_paired = null

func _ready():
	pass

func _process(delta):
	pass

# TODO move this code to the Card signal.
func _on_PairZone_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		# we're dropping a card onto the pair zone.
		if not event.is_pressed() and get_parent().selected_card:
			if card_to_be_paired:
				print("pairing " + get_parent().selected_card.name  + " with " + card_to_be_paired.name)
				# TODO delete paired cards
				# card_to_be_paired = null
			else:
				print("adding " + get_parent().selected_card.name)
				card_to_be_paired = get_parent().selected_card
				print(card_to_be_paired.name + ' on deck')
