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
		add_child(card)

		var pd = person_factory.new_person_data()
		print(pd)
		card.load_person_data(pd)


		
	max_z = 2 * num_cards
	

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
