extends Node2D


var sprite_array = []
var name_array = []

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	# faces
	var path = "res://assets/pixel_faces/"
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with('.png'):
			var texture = load(path + file_name)
			sprite_array.append(texture)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	# names
	path  = "res://assets/names.txt"
	var f = File.new()
	f.open(path, File.READ)
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		name_array.append(line)
	f.close()
	return

func new_sprite_texture():
	return sprite_array[rng.randi_range(0, len(sprite_array) - 1)]

func new_name():
	return name_array[rng.randi_range(0, len(name_array) - 1)]
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
