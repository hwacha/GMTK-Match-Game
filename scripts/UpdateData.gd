class_name UpdateData

enum {
	MATCHED,
	TALKING,
	DATING_CASUAL,
	DATING_OFFICIAL,
	MOVED_IN_TOGETHER,
	ENGAGED,
	MARRIED,
	BROKEN_UP, 
}

const status_map = {
	MATCHED: 'matched',
	TALKING: 'talking',
	DATING_CASUAL: 'dating',
	DATING_OFFICIAL: 'commited',
	MOVED_IN_TOGETHER: 'cohabitating',
	ENGAGED: 'engaged',
	MARRIED: 'married',
	BROKEN_UP: 'broken up'
}

const value_map = {
	MATCHED: 25,
	TALKING: 50,
	DATING_CASUAL: 100,
	DATING_OFFICIAL: 250,
	MOVED_IN_TOGETHER: 500,
	ENGAGED: 1000,
	MARRIED: 2500,
}

const event_mutlipliers = [-1, 1, 2]

static func get_score(next_state, current_state, compatibility=0):
	var multiplier = 0

	if compatibility <= -2:
		multiplier = 0
	elif compatibility == -1:
		multiplier = 0.2
	elif compatibility == 0:
		multiplier = 1
	elif compatibility == 1:
		multiplier = 2
	elif compatibility > 2:
		multiplier = 4
	
	var event_multiplier = event_mutlipliers[next_state.event_type]
	if next_state.status != BROKEN_UP:
		return value_map[next_state.status] * multiplier * event_multiplier
	else:
		if current_state == null:
			assert(false)
			return 0
	
		return -2 * value_map[current_state.status]


var text = ""
var status = 0
var count = 0
var event_type = 1

func _init(
	_text,
	_status,
	_count=0,
	_event_type=1
):
	text = _text
	status = _status
	count = _count
	event_type = _event_type




