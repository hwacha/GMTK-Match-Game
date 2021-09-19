extends Node2D

const UpdateData = preload("res://scripts/UpdateData.gd")
const PersonConstants = preload("res://scripts/PersonConstants.gd")

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()

## SIMULATION CODE
enum Event {BAD, NEUTRAL, GOOD}
const base_event_distribution = [0.5, 0, 0.5]
# probability of update being BAD, NEUTRAL, GOOD
const event_likelihoods = {
	UpdateData.MATCHED: [0, 0, 1],
	UpdateData.TALKING: [0, 0, 1],
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
	match event:
		Event.BAD:
			return outcome < transition_likelihood[0]
		Event.NEUTRAL:
			return false
		Event.GOOD:
			return outcome < transition_likelihood[1]
	assert(false)
	return false

func modify_distribution(distribution, compatibility, count):
	return distribution

func choose(array):
	return array[rng.randi_range(0, len(array) - 1)]

func generate_update(pd1, pd2, relationship):
	var event_distribution = modify_distribution(event_likelihoods[relationship.status], 0, 0)
	var outcome = get_outcome(event_distribution)
	var transition = get_transition(outcome, transition_likelihoods[relationship.status])
	
	var p1 = pd1
	var p2 = pd2
	if rng.randi_range(0, 1) == 0:
		p1 = pd2
		p2 = pd1
	
	match relationship.status:
		UpdateData.MATCHED:
			return update_matched(p1, p2, relationship, outcome, transition)
		UpdateData.TALKING:
			return update_talking(p1, p2, relationship, outcome, transition)
	
#		UpdateData.DATING_CASUAL:
#			return update_dating_casual(pd1, pd2, relationship, outcome, transition)
#		UpdateData.DATING_OFFICIAL:
#			return update_dating_official(pd1, pd2, relationship, outcome, transition)
#		UpdateData.MOVED_IN_TOGETHER:
#			return update_moved_in_together(pd1, pd2, relationship, outcome, transition)
#		UpdateData.ENGAGED:
#			return update_engaged(pd1, pd2, relationship, outcome, transition)
#		UpdateData.MARRIED:
#			return update_married(pd1, pd2, relationship, outcome, transition)
#		UpdateData.BROKEN_UP:
#			pass
			#return update_broken_up(outcome, transition)
	if not relationship.status in [UpdateData.BROKEN_UP, UpdateData.MARRIED]:
		return update_any(p1, p2, relationship, outcome, transition)
			
	return UpdateData.new("DEBUG UPDATE %s" % str(rng.randi_range(0, 100)), UpdateData.MARRIED, 0)


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
	'%s found %s charming.',
	'%s messaged %s back and had a great convo.',
	'%s responded with a joke and made %s laugh.'
]

func update_matched(p1, p2, relationship, outcome, transition):

	var text = choose(matched_templates_start) % [p1.first_name, p2.first_name]
	var status = relationship.status
	var count = relationship.count + 1

	match outcome:
		Event.BAD:
			if not transition:
				assert(false)
			var response = choose(matched_templates_bad) % [p2.first_name]
			text = '%s %s ' % [text, response]
			status = UpdateData.BROKEN_UP
			count = 0
		Event.NEUTRAL:
			assert(false)
			pass
		Event.GOOD:
			if not transition:
				assert(false)
			var response = choose(matched_templates_good) % [p2.first_name, p1.first_name]
			text = '%s %s ' % [text, response]
			status = UpdateData.TALKING
			count = 0

	return UpdateData.new(
		text,
		status,
		count
	)

## TALKING

const talking_profile_conversation_roots = [
	'%s talked with %s about %s',
	'%s texted %s about %s',
]

const talking_profile_good = "and it went well. %s and %s both really %s %s."
const talking_profile_good_alt = "and it went well. %s really %ss %s and %s respected the passion."
const talking_profile_neutral = "but it was awkward. %s really %ss %s but %s doesn't care."
const talking_profile_bad = "but it went bad. %s %ss %s, but %s %ss it."
const talking_profile_bad_alt = "but it went poorly. %s really %ss %s and scared %s with the intensity."

const talking_transition_good = [
	"They agreed to meet for a date!",
	"They picked a time to meet in person!",
	"They made plans to see each other."
]

const talking_transition_bad = [
	"%s got angry and blocked them.",
	"%s decided it wasn't going to work.",
]
	
const preferences = ['hate', 'love']

func update_talking(p1, p2, relationship, outcome, transition):
	var use_neutral = true
	var topic = -1
	var p1_preference = 'love'

	if outcome == Event.BAD:
		topic = p1.get_opposite_icon(p2)
	elif outcome == Event.GOOD:
		topic = p1.get_common_icon(p2)
	if topic == -1:
		topic = p1.get_no_overlap_icon(p2)
		use_neutral = true
	var discussion_topic = 'money' # need a placeholder value for edge case
	if topic != -1:
		discussion_topic = PersonConstants.icon_map[topic]
		p1_preference = preferences[p1.icon_ids.find(p1.like_mask, topic)]
	
	var text = choose(talking_profile_conversation_roots) % [p1.first_name, p2.first_name, discussion_topic]
	var status = UpdateData.TALKING
	var count = relationship.count + 1

	match outcome:
		Event.BAD:
			var text_continued = ''
			if use_neutral:
				text_continued = talking_profile_bad_alt % [p1.first_name, p1_preference, discussion_topic, p2.first_name]
			else:
				var p2_preference = 'hate' if p1_preference == 'love' else 'love'
				text_continued = talking_profile_bad % [p1.first_name, p1_preference, discussion_topic, p2.first_name, p2_preference]
			text = '%s, %s' % [text, text_continued]
			if transition:
				text = '%s %s' % [text, choose(talking_transition_bad)]
				status = UpdateData.BROKEN_UP
				count = 0
		Event.NEUTRAL:
			text = '%s, %s' % [text, talking_profile_neutral  % [p1.first_name, p1_preference, discussion_topic, p2.first_name]]
		Event.GOOD:
			var text_continued = ''
			if use_neutral:
				text_continued = talking_profile_good_alt % [p1.first_name, p1_preference, discussion_topic, p2.first_name]
			else:
				text_continued = talking_profile_good % [p1.first_name, p2.first_name, p1_preference, discussion_topic]
			text = '%s, %s' % [text, text_continued]
			if transition:
				text = '%s %s' % [text, choose(talking_transition_good)]
				status = UpdateData.DATING_CASUAL
				count = 0
	return UpdateData.new(
		text,
		status,
		count
	)

enum Activities {
	TEXT
	TALK,
	SHOW,
	FOOD,
	HIKE,
	TRAVEL,
	NIGHT_IN,
	PARTY,
	ERRAND,
}

const generic_activities = [
	Activities.TALK,
	Activities.SHOW,
	Activities.FOOD,
	Activities.HIKE,
	Activities.PARTY,
	Activities.TRAVEL,
	Activities.NIGHT_IN,
	Activities.ERRAND,
]

const activity_map = {
	UpdateData.MATCHED: [],
	UpdateData.TALKING: [],
	UpdateData.DATING_CASUAL: [Activities.SHOW, Activities.FOOD],
	UpdateData.DATING_OFFICIAL:  [Activities.TALK, Activities.SHOW, Activities.FOOD, Activities.HIKE, Activities.PARTY],
	UpdateData.MOVED_IN_TOGETHER: all_activities,
	UpdateData.ENGAGED: all_activities,
	UpdateData.MARRIED: all_activities,
	UpdateData.BROKEN_UP: [],
}

const good_transition_text = {
	UpdateData.DATING_CASUAL: [
		'%s let %s know they would like their relationship to be official. %s agreed!',
		'%s asked %s if they were down to make their relationship official. %s said yes!',
	],
	UpdateData.DATING_OFFICIAL: [
		'%s asked %s if wanted to move in together. %s said yes!',
	],
	UpdateData.MOVED_IN_TOGETHER: [
		'%s proposed to %s. %s said yes!',
		'%s asked %s to married them. %s said yes!'
	],
	UpdateData.ENGAGED: [
		'%s and %s got married. %s delivered beautiful vows',
		"%s and %s tied the knot. this is the happinest day of %s's life!",
	]
}

const good_transition_next = {
	UpdateData.DATING_CASUAL: UpdateData.DATING_OFFICIAL,
	UpdateData.DATING_OFFICIAL: UpdateData.MOVED_IN_TOGETHER,
	UpdateData.MOVED_IN_TOGETHER: UpdateData.ENGAGED,
	UpdateData.ENGAGED: UpdateData.MARRIED,
}

const bad_transition_text = {
	UpdateData.DATING_CASUAL: [
		[
			"%s decided %s's %s was just too %s. It's done.",
			[
				'face',
				'sense of humor',
				'sense of fashion',
				'personality',
				'whole get-up',
			],
			[
				'off_putting',
				'disgusting',
				'much',
				'annoying'
			],
		]
	],
	UpdateData.DATING_OFFICIAL: [
		[
			"%s discovered that %s %s. It's over.",
			[
				"snores really loudly",
				"hates dogs",
				"hates cats",
				"has no friends",
				"doesn't have a job",
				"watches tv with commercials",
				"'s friends are toxic people.",
				"has a twin",
				"skips breakfast",
			],
		]
	],
	UpdateData.MOVED_IN_TOGETHER: [
		[
			"%s decided that that %s %s.",
			[
				"wasn't true love",
				"didn't let them grow",
				"was too controlling",
				"had imcompatible future plans",
			],
		]
	],
	UpdateData.ENGAGED: [
		[
			"%s called off the wedding. %s %s.",
			[
				"was caught cheating",
				"confessed he was in love with someone else",
				"said unforgivable things during a fight",
				"didn't share their french fries",
			],
		]
	],
}

func update_any(p1, p2, relationship, outcome, transition):
	if transition:
		if outcome == Event.GOOD or outcome == Event.NEUTRAL:
			var text_template = choose(good_transition_text[relationship.status])
			var text = text_template % [p1.first_name, p2.first_name, p2.first_name]
			return UpdateData.new(text, good_transition_next[relationship.status], 0)
		elif outcome == Event.BAD:
			var meta_template = choose(bad_transition_text[relationship.status])
			var template = meta_template[0]
			var template_parameters = [p1.first_name, p2.first_name]
			for i in range(1, len(meta_template)):
				var next_word = choose(meta_template[i])
				template_parameters.append(next_word)
			var text = template % template_parameters
			return UpdateData.new(text, UpdateData.BROKEN_UP, 0)
	var activity = choose(activity_map[relationship.status])
	match:
		activity 
		
	
