extends Control

signal card_update_ready(card, update)

const UpdateData = preload("res://scripts/UpdateData.gd")

var pd1 = null
var pd2 = null
var relationship_state = null

const global_rate = -0.5
const update_step = 5
const max_name_length = 12

var rng = RandomNumberGenerator.new()
var time_since_update = 0
var waiting_for_update = false

onready var sprite1 = $Container/Person1
onready var sprite2 = $Container/Person2
onready var progress_bar1 = $Container/Person1Happiness
onready var progress_bar2 = $Container/Person2Happiness
onready var name_text = $Container/Names
onready var status_text = $Container/Status
onready var bonus_text = $Container/Bonus
onready var update_text = $Container/Update

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_couple(_pd1, _pd2):
	assert(_pd1 and _pd2)
	pd1 = _pd1
	pd2 = _pd2
	
	sprite1.texture = pd1.face_id
	sprite2.texture = pd2.face_id

	var display_name1 = pd1.first_name
	var display_name2 = pd2.first_name

	if len(display_name1) + len(display_name2) > max_name_length:
		display_name1 = display_name1.substr(0, 3) + '.'
		display_name2 = display_name2.substr(0, 3) + '.'
	name_text.text = "%s+%s" % [display_name1, display_name2]
	status_text.text = ""
	bonus_text.text = ""
	update_text.text = ""
	
	progress_bar1.value = pd1.happiness
	progress_bar2.value = pd2.happiness


func apply_update(update: UpdateData):
	waiting_for_update = false
	relationship_state = update
	status_text.text = "Status: %s" % update.status
	update_text.text = update.text
	if update.value >= 0:
		bonus_text.text = "+%s" % str(update.value)
	else:
		bonus_text.text = "-%s" % str(update.value)

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	if pd1:
		pd1.happiness = clamp(pd1.happiness -  delta * global_rate * pd1.rate, 0, 100)
		progress_bar1.value = pd1.happiness
		if pd1.happiness <= 0:
			pass
	if pd2:
		pd2.happiness = clamp(pd2.happiness -  delta * global_rate * pd2.rate, 0, 100)
		progress_bar2.value = pd2.happiness
		if pd2.happiness <= 0:
			pass
	
	if not waiting_for_update:
		time_since_update += delta
		if time_since_update >= update_step:
			var update = generate_update()
			if update:
				emit_signal('card_update_ready', self, update)
				time_since_update = 0
				waiting_for_update = true
			
			
## SIMULATION CODE
enum Event {BAD, NEUTRAL, GOOD}
const base_event_distribution = [0.1, 0.6, 0.3]
# probability of update being BAD, NEUTRAL, GOOD
const event_likelihoods = {
	UpdateData.MATCHED: [0.5, 0, 0.5],
	UpdateData.TALKING: base_event_distribution,
	UpdateData.DATING_CASUAL: base_event_distribution,
	UpdateData.DATING_OFFICIAL: base_event_distribution,
	UpdateData.MOVED_IN_TOGETHER: base_event_distribution,
	UpdateData.ENGAGED: base_event_distribution,
	UpdateData.MARRIED: base_event_distribution,
	UpdateData.BROKEN_UP: base_event_distribution,
}

func get_outcome(distribution):
	var outcome = rng.randf_range(0, 1)
	var cumulative_prob = 0
	for i in range(0, len(distribution)):
		cumulative_prob += distribution[i]
		if outcome <= cumulative_prob:
			return i
	# shouldn't happen but uh just in case
	assert(false)
	return len(distribution) - 1

# probably of breaking up given BAD or advancing given GOOD
const base_transition_likelihood = [1, 1]
const transition_likelihoods = {
	UpdateData.MATCHED: base_transition_likelihood,
	UpdateData.TALKING: base_transition_likelihood,
	UpdateData.DATING_CASUAL: base_transition_likelihood,
	UpdateData.DATING_OFFICIAL: base_transition_likelihood,
	UpdateData.MOVED_IN_TOGETHER: base_transition_likelihood,
	UpdateData.ENGAGED: base_transition_likelihood,
	UpdateData.MARRIED: base_transition_likelihood,
	UpdateData.BROKEN_UP: base_transition_likelihood,
}

func get_transition(event, transition_likelihood):
	var outcome = rng.randf_range(0, 1)

	print(transition_likelihood)
	match event:
		Event.BAD:
			return outcome < transition_likelihood[0]
		Event.NEUTRAL:
			return false
		Event.GOOD:
			return outcome < transition_likelihood[1]
	print(event)
	assert(false)
	return false

func modify_distribution(distribution, compatibility, rlevel):
	return distribution

func choose(array):
	return array[rng.randi_range(0, len(array) - 1)]

func generate_update():
	var event_distribution = modify_distribution(event_likelihoods[relationship_state.rlevel], 0, 0)
	var outcome = get_outcome(event_distribution)
	var transition = get_transition(outcome, transition_likelihoods[relationship_state.rlevel])
		
	match relationship_state.rlevel:
		UpdateData.MATCHED:
			return update_matched(outcome, transition)
		UpdateData.TALKING:
			return update_talking(outcome, transition)
		UpdateData.DATING_CASUAL:
			return update_dating_casual(outcome, transition)
		UpdateData.DATING_OFFICIAL:
			return update_dating_official(outcome, transition)
		UpdateData.MOVED_IN_TOGETHER:
			return update_moved_in_together(outcome, transition)
		UpdateData.ENGAGED:
			return update_engaged(outcome, transition)
		UpdateData.MARRIED:
			return update_married(outcome, transition)
		UpdateData.BROKEN_UP:
			pass
			#return update_broken_up(outcome, transition)
	return UpdateData.new("DEBUG UPDATE figure it out", 'huh', relationship_state.r_level, 42, 0)
	#return UpdateData.new("Update test!!!!", 'huh', UpdateData.RLevel.ENGAGED, 50, 0)

## MATCHED
const matched_templates_start = [
	'%s messaged %s and asked about their day.',
	'%s messaged %s and opened with a joke.',
	'%s messaged %s and gave them a compliment.',
]

const matched_templates_bad = [
	'%s got a bad vibe and decided to unmatch.',
	'%s found this weird and blocked them.',
	'%s left them on read!'
]

const matched_templates_good = [
	'%s found %s charismatic.',
	'%s messaged %s back and had a great convo.',
	'%s responded with a joke and made %s laugh.'
]


func update_matched(outcome, transition):
	var p1 = pd1
	var p2 = pd2
	if rng.randi_range(0, 1) == 0:
		p1 = pd2
		p2 = pd1

	var text = choose(matched_templates_start) % [p1.first_name, p2.first_name]
	var status = "talking"
	var value = 50
	var rlevel = relationship_state.rlevel
	var rlevel_count = relationship_state.rlevel_count + 1
	match outcome:
		Event.BAD:
			if not transition:
				assert(false)
			var response = choose(matched_templates_bad) % [p2.first_name, p1.first_name]
			status = 'done'
			value = -50
			text = '%s %s ' % [text, response]
			rlevel = UpdateData.BROKEN_UP
			rlevel_count = 0
		Event.NEUTRAL:
			assert(false)
			pass
		Event.GOOD:
			if not transition:
				assert(false)
			var response = choose(matched_templates_good) % [p2.first_name, p1.first_name]
			status = 'talking'
			value = 100
			text = '%s %s ' % [text, response]
			rlevel = UpdateData.TALKING
			rlevel_count = 0
	return UpdateData.new(
		text,
		status,
		rlevel,
		value,
		rlevel_count
	)


## TALKING
func update_talking(outcome, transition):
	pass
	
## DATING_CASUAL
func update_dating_casual(outcome, transition):
	pass

## DATING_OFFICIAL
func update_dating_official(outcome, transition):
	pass

## MOVED_IN_TOGETHER
func update_moved_in_together(outcome, transition):
	pass

## ENGAGED
func update_engaged(outcome, transition):
	pass

## MARRIED
func update_married(outcome, transition):
	pass

## BROKEN UP
func update_broken_up(outcome, transition):
	pass
