extends Node2D

export var max_z = 0

var selected_card = null
#onready var card_manager = get_node("CardManager")
onready var _card_view = get_node("CardViewer")
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
		
		for dir in ['left', 'right']:
			for i in range(0, len(card.stats[dir])):
				var coin_flip = rng.randi_range(0, 1)
				if coin_flip == 0:
					coin_flip = -1
				card.stats[dir][i] = coin_flip
			card.stats[dir][1] = 0
		
		for i in range(len(card.attributes)):
			card.attributes[i] = rng.randf_range(1.0, 5.0)

		var x = rng.randi_range(75, 700)
		var y = rng.randi_range(200, 500)
		card.set_position(Vector2(x, y))
		card.z_index = 2 * n
		add_child(card)
		
	max_z = 2 * num_cards
	
func _draw():
	
#	if selected_card:
#		var size_1 = selected_card.attributes[0]
#		var size_2 = selected_card.attributes[1]
#		var size_3 = selected_card.attributes[2]
#
#		draw_rect(Rect2(Vector2(800, 450), Vector2(42 * size_1, 12)), Color(0.4, 0.3, 0.1, 1.0))
#		draw_rect(Rect2(Vector2(800, 490), Vector2(42 * size_2, 12)), Color(0.25, 0.7, 0.8, 1.0))
#		draw_rect(Rect2(Vector2(800, 530), Vector2(42 * size_3, 12)), Color(0.7, 0.2, 0.5, 1.0))
	pass
	
func set_selected_card(card):
	selected_card = card
	if card:
		_card_view.visible = true
		_card_view.get_node("Sprite").set_texture(card.get_node("Face").get_texture())
		update()
	else:
		_card_view.visible = false
		_card_view.get_node("Sprite").set_texture(null)
		update()

func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		get_tree().change_scene("res://prefabs/Field.tscn")
	if Input.is_action_just_pressed("ui_down"):
		pass
