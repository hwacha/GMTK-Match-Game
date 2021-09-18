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

var text = ""
var status = ""
var rlevel = 0
var value = 0
var rlevel_count = 0

func _init(
	_text,
	_status,
	_rlevel,
	_value,
	_rlevel_count=0
):
	text = _text
	status = _status
	rlevel = _rlevel
	value = _value
	rlevel_count = _rlevel_count




