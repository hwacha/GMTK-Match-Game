extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var radius = 23
var offset = Vector2(0, 43)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
#	var rng = RandomNumberGenerator.new()
#	rng.randomize()
	var parent = get_parent()
	if parent.pair_state in ['unpaired', 'paired']:
		draw_attributes(parent.attributes)
		draw_axises(len(parent.attributes))
		self.z_index = 0
	elif parent.pair_state == 'pair_container':
		self.z_index = 2
		print(parent.name)
		draw_axises(len(parent.attributes))
		draw_attributes(parent.get_node('Child1').attributes)
		draw_attributes(parent.get_node('Child2').attributes)
		

	
func draw_attributes(attributes):
	print(attributes)

	var rotation = 2 * PI / len(attributes)
	var points = PoolVector2Array()
	for i in range(0 , len(attributes)):
		points.append(offset + Vector2(0, attributes[i] / 5 * radius).rotated(rotation/2 + i * rotation))
	#points.append(points[0])
	draw_colored_polygon(points, Color(0.7, 0.2, 0.5, 0.4), PoolVector2Array(), null, null, true)

func draw_axises(num_attributes):
	var rotation = 2 * PI / num_attributes
	var outline = PoolVector2Array()
	for i in range(0, num_attributes):
		outline.append(offset + Vector2(0, radius).rotated(rotation/2 + i * rotation))
	outline.append(outline[0])
	#draw_polyline(outline, Color(0, 0, 0, 0.4), 1.0, true)
	for point in outline:
		draw_line(offset, point, Color(0, 0, 0, 0.3), 1.0, true)
	

	
#	var size_1 = get_parent().attributes[0]
#	var size_2 = get_parent().attributes[1]
#	var size_3 = get_parent().attributes[2]
#	draw_rect(Rect2(Vector2(-35, 35), Vector2(14 * size_1, 4)), Color(0.4, 0.3, 0.1, 1.0))
#	draw_rect(Rect2(Vector2(-35, 42), Vector2(14 * size_2, 4)), Color(0.25, 0.7, 0.8, 1.0))
#	draw_rect(Rect2(Vector2(-35, 49), Vector2(14 * size_3, 4)), Color(0.7, 0.2, 0.5, 1.0))

#	draw_line(Vector2(-36, 35), Vector2(-36, 53), Color(0.0, 0.0, 0.0, 1.0), 2.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
#	update()
