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
var bio = ''

func _init(
	_stats=null,
	_icon_ids=null,
	_like_mask=null,
	_face_id=null,
	_first_name=null,
	_gender=null,
	_age=null,
	_bio=null
):
	stats = _stats
	icon_ids = _icon_ids
	like_mask = _like_mask
	face_id = _face_id
	first_name = _first_name
	gender = _gender
	age = _age
	bio = _bio
	
#
#static func score_compatibility(pd: PersonData, pd2: PersonData) -> int:
#	var score = 0
#	for i in range(0, len(pd.icons)):
#		var j = pd2.find(pd.icons[i])
#		if j != -1:
#			if pd.like_mask[i] == pd2.like_mask[j]:
#				score += 1
#			else:
#				score -= 1
#	return score
