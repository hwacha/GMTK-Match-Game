extends Node2D



const COLOR_LIKE = Color(0, 1, 0, 0.35)
const COLOR_HATE = Color(1, 0, 0, 0.35)
const COLOR_NEUTRAL = Color(0, 0, 0, 0)

onready var ColorRect = $ColorRect
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_color(color: int):
	match color:
		0:
			ColorRect.color = COLOR_HATE
		1:
			ColorRect.color = COLOR_LIKE
		_:
			ColorRect.color = COLOR_NEUTRAL


func set_icon(icon: int):
	self.animation = str(icon)
