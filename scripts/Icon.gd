extends Node2D


var icon_count = 41

var item_type = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	item_type = rng.randi_range(1, 42)
	get_node("AnimatedSprite").animation = str(item_type)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
