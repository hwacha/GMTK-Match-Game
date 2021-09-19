extends Node2D

func update_stars(num_stars):
	var children = get_children()
	for i in range(0, 5):
		if 2*i <= num_stars:
			children[i].animation = 'full'
		elif 2*i <= num_stars + 1:
			children[i].animation = 'half'
		else:
			children[i].animation = 'empty'
			
	

