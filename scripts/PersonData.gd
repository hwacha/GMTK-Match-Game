class_name PersonData

var stats = {
	'left': [0, 0],
	'right': [0, 0],
}
 
var icon_ids = [0, 0, 0, 0]
var like_mask = [0, 0, 0, 0]

var face_id = null
var first_name = 'James'
var gender = 'male'
var age = 28
var bio = 'Hi! This is my dating profile :)'

func _init(
	stats=null,
	icon_ids=null,
	like_mask=null,
	face_id=null,
	first_name=null,
	gender=null,
	age=null,
	bio=null
):
	stats = stats
	icon_ids = icon_ids
	like_mask = like_mask
	face_id = face_id
	gender = gender
	age = age
	bio = bio
	
