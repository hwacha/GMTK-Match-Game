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
var rate = 1
var happiness = 100

func _init(
	_stats=null,
	_icon_ids=null,
	_like_mask=null,
	_face_id=null,
	_first_name=null,
	_gender=null,
	_age=null,
	_bio=null,
	_rate=null
):
	stats = _stats
	icon_ids = _icon_ids
	like_mask = _like_mask
	face_id = _face_id
	first_name = _first_name
	gender = _gender
	age = _age
	bio = _bio
	rate = _rate

static func score_compatibility(pd: PersonData, pd2: PersonData) -> int:
	var score = 0
	for i in range(0, len(pd.icon_ids)):
		var j = pd2.icon_ids.find(pd.icon_ids[i])
		if j != -1:
			if pd.like_mask[i] == pd2.like_mask[j]:
				score += 1
			else:
				score -= 1
	return score

func get_common_icon(pd2):
	var candidates = []
	for i in range(0, len(icon_ids)):
		var j = pd2.icon_ids.find(icon_ids[i])
		if j != -1 and like_mask[i] == pd2.like_mask[j]:
			candidates.append(icon_ids[i])
	if len(candidates) == 0:
		return -1
	randomize()
	candidates.shuffle()
	return candidates[0]

func get_opposite_icon(pd2):
	var candidates = []
	for i in range(0, len(icon_ids)):
		var j = pd2.icon_ids.find(icon_ids[i])
		if j != -1 and like_mask[i] != pd2.like_mask[j]:
			candidates.append(icon_ids[i])
	if len(candidates) == 0:
		return -1
	randomize()
	candidates.shuffle()
	return candidates[0]

func get_no_overlap_icon(pd2):
	var candidates = []
	for i in range(0, len(icon_ids)):
		if not icon_ids[i] in pd2.icon_ids:
			candidates.append(icon_ids[i])
	if len(candidates) == 0:
		return -1
	randomize()
	candidates.shuffle()
	return candidates[0]
	
