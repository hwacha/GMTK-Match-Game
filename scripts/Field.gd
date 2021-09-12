extends Node2D


export var max_z = 0
const Card = preload("res://prefabs/Card.tscn")

var selected_card = null

#onready var card_manager = get_node("CardManager")
onready var _card_view = get_node("CardViewer")
onready var person_factory = get_node('PersonFactory')
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()	
	
	var num_cards = 20
	for n in range(num_cards):
		
		var card = Card.instance()
		var x = rng.randi_range(75, 700)
		var y = rng.randi_range(200, 500)
		card.set_position(Vector2(x, y))
		card.z_index = 2 * n
		# have to load the card into the scene before updating it's values
		# kinda weird! feel like there should be a better way to do this
		# will investigate at a later date.
		add_child(card)

		var pd = person_factory.new_person_data()
		print(pd)
		card.load_person_data(pd)

		
	max_z = 2 * num_cards
	

func set_selected_card(card):
	selected_card = card
	if card and card.pair_state == 'unpaired':
		_card_view.load_person_data(card.person_data)
		_card_view.visible = true
	else:
		_card_view.visible = false


func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		get_tree().change_scene("res://prefabs/Field.tscn")
	if Input.is_action_just_pressed("ui_down"):
		pass
