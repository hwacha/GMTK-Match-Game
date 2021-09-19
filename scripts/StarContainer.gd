extends Node2D

func update_stars(num_stars):
	var children = get_children()
	var c = num_stars
	for i in range(0, 5):
		if c >= 2:
			children[i].animation = 'full'
			c = c - 2
		elif c == 1:
			children[i].animation = 'half'
			c = c - 1
		else:
			children[i].animation = 'empty'
			
	

