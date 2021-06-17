extends Node

export var max_z = 0

var selected_card = null
#onready var card_manager = get_node("CardManager")
# Called when the node enters the scene tree for the first time.
func _ready():
	var card_prefab = load("res://prefabs/Card.tscn")
	var num_cards = 20
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for n in range(num_cards):
		# NOTE: this will be moved to Field
		# for more intelligent generation
		
		var card = card_prefab.instance()
		
#		var guaranteed_jamb_dir = 1 if n % 2 == 0 else -1
		
		for dir in ['left', 'right', 'up', 'down']:
			for i in range(0, len(card.stats[dir])):
				var coin_flip = rng.randi_range(0, 1)
				if coin_flip == 0:
					coin_flip = -1
				card.stats[dir][i] = coin_flip

		var x = rng.randi_range(75, 700)
		var y = rng.randi_range(200, 500)
		card.set_position(Vector2(x, y))
		card.z_index = 2 * n
		add_child(card)
		
	max_z = 2 * num_cards

func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		get_tree().change_scene("res://prefabs/Field.tscn")
	if Input.is_action_just_pressed("ui_down"):
		pass
