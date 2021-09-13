extends Node2D


const start = Vector2(0, 0)

const row_offset_x = 5
const row_offset_y = 90

const col_offset_x = 95
const col_offset_y = 15


const cards_per_row = 2


var cards = []

func _ready():
	pass

func add_card(card):
	card.pair_state = card.PairState.RESERVOIR
	self.add_child(card)
	self.update_positions() 

func remove_card(card):
	for c in self.get_children():
		if c == card:
			card.pair_state = card.PairState.UNPAIRED
			self.remove_child(card)
			break
	self.update_positions()
		
	
func update_positions():
	var child_cards = self.get_children()
	for i in range(0, len(child_cards)):
		var col = i % cards_per_row
		var row = i / cards_per_row
		var new_x = self.position.x + col * col_offset_x + row * row_offset_x
		var new_y = self.position.y + col * col_offset_y + row * row_offset_y
		child_cards[i].set_position(Vector2(new_x, new_y))
		


#func _process(delta):
#	pass
