extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var size_1 = get_parent().attributes[0]
	var size_2 = get_parent().attributes[1]
	var size_3 = get_parent().attributes[2]
	draw_rect(Rect2(Vector2(-35, 35), Vector2(14 * size_1, 4)), Color(0.4, 0.3, 0.1, 1.0))
	draw_rect(Rect2(Vector2(-35, 42), Vector2(14 * size_2, 4)), Color(0.25, 0.7, 0.8, 1.0))
	draw_rect(Rect2(Vector2(-35, 49), Vector2(14 * size_3, 4)), Color(0.7, 0.2, 0.5, 1.0))
#	draw_line(Vector2(-36, 35), Vector2(-36, 53), Color(0.0, 0.0, 0.0, 1.0), 2.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
#	update()
