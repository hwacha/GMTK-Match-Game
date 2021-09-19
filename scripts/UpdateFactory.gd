extends Node2D

const UpdateData = preload("res://scripts/UpdateData.gd")
const PersonConstants = preload("res://scripts/PersonConstants.gd")

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(Event.BAD == 0)
	#print(Event.NEUTRAL == 1)
	#print(Event.GOOD == 2)
	rng.randomize()

## SIMULATION CODE
enum Event {BAD, NEUTRAL, GOOD}

const base_event_distribution = [0.2, 0.4, 0.4]
# probability of update being BAD, NEUTRAL, GOOD
const event_likelihoods = {
	UpdateData.MATCHED: base_event_distribution,
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
const base_transition_likelihood = [0.5, 0.5]
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
	
	if not relationship.status in [UpdateData.BROKEN_UP, UpdateData.MARRIED]:
		return get_update(p1, p2, relationship, outcome, transition)
	
	assert(false)

	return UpdateData.new("DEBUG UPDATE %s" % str(rng.randi_range(0, 100)), UpdateData.MARRIED, 0, 1)


## TALKING

const talking_profile_conversation_roots = [
	'%s talked with %s about %s',
	'%s texted %s about %s',
]

const talking_profile_good = "It well. They both really %s %s."
const talking_profile_good_alt = "It went well. %s really %ss %s and %s respected that."
const talking_profile_neutral = "It was awkward. %s really %ss %s but %s doesn't care."
const talking_profile_bad = "It went bad. %s %ss %s, but %s %ss it."
const talking_profile_bad_alt = "It went poorly. %s really %ss %s and it was scary."

	
const preferences = ['hate', 'love']

func get_talking_text(p1, p2, outcome):
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
	match outcome:
		Event.BAD:
			var text_continued = ''
			if use_neutral:
				text_continued = talking_profile_bad_alt % [p1.first_name, p1_preference, discussion_topic]
			else:
				var p2_preference = 'hate' if p1_preference == 'love' else 'love'
				text_continued = talking_profile_bad % [p1.first_name, p1_preference, discussion_topic, p2.first_name, p2_preference]
			text = '%s, %s' % [text, text_continued]
		Event.NEUTRAL:
			text = '%s, %s' % [text, talking_profile_neutral  % [p1.first_name, p1_preference, discussion_topic, p2.first_name]]
		Event.GOOD:
			var text_continued = ''
			if use_neutral:
				text_continued = talking_profile_good_alt % [p1.first_name, p1_preference, discussion_topic, p2.first_name]
			else:
				text_continued = talking_profile_good % [p1.first_name, p2.first_name, p1_preference, discussion_topic]
			text = '%s, %s' % [text, text_continued]
	return text

enum Activities {
	INITIATE,
	TEXT
	TALK,
	SHOW,
	FOOD,
	HIKE,
	TRAVEL,
	NIGHT_IN,
	SOCIAL,
	ERRAND,
}

const generic_activities = [
	Activities.TALK,
	Activities.SHOW,
	Activities.FOOD,
	Activities.HIKE,
	Activities.SOCIAL,
	Activities.TRAVEL,
	Activities.NIGHT_IN,
	Activities.ERRAND,
]

const activity_map = {
	UpdateData.MATCHED: [Activities.INITIATE],
	UpdateData.TALKING: [Activities.TEXT],
	UpdateData.DATING_CASUAL: [Activities.SHOW, Activities.FOOD],
	UpdateData.DATING_OFFICIAL: [Activities.TALK, Activities.SHOW, Activities.FOOD, Activities.HIKE, Activities.SOCIAL],
	UpdateData.MOVED_IN_TOGETHER: generic_activities,
	UpdateData.ENGAGED: generic_activities,
	UpdateData.MARRIED: [],
	UpdateData.BROKEN_UP: [],
}

const good_transition_text = {
	UpdateData.TALKING: [
		'%s asked %s out. %s said yes!',
	],
	UpdateData.DATING_CASUAL: [
		'%s let %s know they would like their relationship to be official. %s agreed!',
		'%s asked %s if they were down to make their relationship official. %s said yes!',
	],
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
	UpdateData.MATCHED: UpdateData.TALKING,
	UpdateData.TALKING: UpdateData.DATING_CASUAL,
	UpdateData.DATING_CASUAL: UpdateData.DATING_OFFICIAL,
	UpdateData.DATING_OFFICIAL: UpdateData.MOVED_IN_TOGETHER,
	UpdateData.MOVED_IN_TOGETHER: UpdateData.ENGAGED,
	UpdateData.ENGAGED: UpdateData.MARRIED,
}

const bad_transition_text = {
	UpdateData.MATCHED: [
		[
			"%s decided %s was %s and %s.",
			[
				'ugly',
				'boring',
				'annoying',
				'irritating',
				'weird',
				'creepy',
			],
			[
				"left them on read",
				"blocked them",
				"ghosted",
				"unmatched",
				"end the conversation"
			],
		]
	],
	UpdateData.TALKING: [
		[
			"%s decided %s was %s and %s.",
			[
				'ugly',
				'boring',
				'annoying',
				'irritating',
				'weird',
				'creepy',
			],
			[
				"left then on read",
				"blocked them",
				"ghosted",
				"unmatched",
				"end the conversation"
			],
		]
	],
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

# we skip the matched transition state for flow

func get_update(p1, p2, relationship, outcome, transition):
	if transition and relationship.count >= 1 and relationship.status != UpdateData.MATCHED:
		if outcome == Event.GOOD:
			if relationship.status != UpdateData.MATCHED:
				var text_template = choose(good_transition_text[relationship.status])
				var text = text_template % [p1.first_name, p2.first_name, p2.first_name]
				return UpdateData.new(text, good_transition_next[relationship.status], 0, outcome)
		elif outcome == Event.BAD:
			var meta_template = choose(bad_transition_text[relationship.status])
			var template = meta_template[0]
			var template_parameters = [p1.first_name, p2.first_name]
			for i in range(1, len(meta_template)):
				var next_word = choose(meta_template[i])
				template_parameters.append(next_word)
			var text = template % template_parameters
			return UpdateData.new(text, UpdateData.BROKEN_UP, 0, outcome)
	var activity = choose(activity_map[relationship.status])
	if activity == Activities.TEXT:
		var text = get_talking_text(p1, p2, outcome)
		return UpdateData.new(text, UpdateData.TALKING, relationship.count + 1, outcome)
	else:
		var meta_template = choose(activity_templates[activity])
		var template = meta_template[0]
		var good_bad = meta_template[len(meta_template) - 1][outcome]
		var template_parameters = [p1.first_name, p2.first_name]
		for i in range(1, len(meta_template) - 1):
			var next_word = choose(meta_template[i])
			template_parameters.append(next_word)
		var text = template % template_parameters
		text = "%s %s" % [text, choose(good_bad)]
		var next_status = relationship.status
		var next_count = relationship.count + 1
		if relationship.status == UpdateData.MATCHED and outcome == Event.GOOD:
			next_status = UpdateData.TALKING
			next_count = 0
		return UpdateData.new(text, next_status, next_count, outcome)


# TODO: make the endings templates themselves

const activity_templates = {
	Activities.INITIATE: [
		[
			"%s messaged %s about %s.",
			[
				"their day",
				"their photos",
				"the weather",
				"the state of the world",
			],
			{
				Event.GOOD: ['They had a nice conversation.'],
				Event.NEUTRAL: ["They responded politely."],
				Event.BAD: ["It gave them a weird vibe."]
			}
		],
		[
			"%s complimented %s on %s.",
			[
				"their hair",
				"their educational background",
				"their eyes",
				"their face",
				"their sense of humor",
				"their posture",
				"their skin",
			],
			{
				Event.GOOD: ['They talked for a while.'],
				Event.NEUTRAL: ["They responded politely."],
				Event.BAD: ["It was weird.", "It didn't land."]
			}
		], 
		[
			"%s sent %s a photo of %s.",
			[
				"a cute pig",
				"a dog",
				"(inappropriate)",
				"a cool rock",
				"their lunch",
			],
			{
				Event.GOOD: ['They talked for a while.'],
				Event.NEUTRAL: ["They responded politely."],
				Event.BAD: ["It was weird.", "It didn't land."]
			}
		],
		[
			"%s messaged %s a joke about %s.",
			[
				"politics",
				"batman",
				"the internet",
				"weddings",
				"advertising",
				"tables",
				"couches",
				"parents",
				"teenagers"
			],
			{
				Event.GOOD: ['It made them laugh.'],
				Event.NEUTRAL: ["They responded politely."],
				Event.BAD: ["It was weird.",  "It didn't land.", "It gave them a bad vibe."]
			}
		],
	],
	Activities.TALK: [
		[
			"%s had a long talk with %s about %s.",
			[
				"supply chains",
				"philosophy",
				"video games",
				"hairdryers",
				"woodwinds",
				"recycling",
				"the eurozone",
				"the weather",
				"snow",
				"dogs",
				"magnets",
				"canada",
				'santa claus',
				"mcdonald's",
				"how to pronounce 'gif'",
				"good vs. evil",
				"star wars",
			],
			{
				Event.GOOD: ['', 'It went well!'],
				Event.NEUTRAL: [''],
				Event.BAD: ['They started fighting.', 'It got heated.']
			}
		]
	],
	Activities.SHOW: [
		[
			"%s went with %s to see a %s about %s.",
			[
				"movie",
				"film",
				"ballet recietal",
				"play",
				"comedy routine",
			],
			[	
				"abraham lincoln",
				"italy",
				"robots",
				"racecars",
				"chess",
				"warfare",
				"the legal system",
				"entropy"
			],
			{
				Event.GOOD: ['They loved it.', 'They kissed at the end'],
				Event.NEUTRAL: ['It was fine.', ''],
				Event.BAD: ["It sucked.", "They hated it", "It was a miserable time."]
			}
		]
	],
	Activities.FOOD: [
		[
			"%s and %s %s at %s.",
			[
				"went to happy hour",
				"got lunch",
				"grabbed a bite",
				"got dinner",
				"had a romantic dinner",
			],
			[
				"McDonald's",
				"a mexican restaurant",
				"a french restaurant",
				"an ethiopian restaurant",
				"a thai place",
				"a chinese restaurant",
				"a burger joint",
				"a salad place",
				"a bbq joint",
				"a diner",
				"the Newark airport Chili's Too",
				"the cheesecake factory",
			],
			{
				Event.GOOD: ['They loved it.', 'They held hands.', 'They kissed.', "It was amazing."],
				Event.NEUTRAL: ["It was fine.", ""],
				Event.BAD: ["It sucked.", "They hated it", "It was miserable.", "They fought.", "They got sick."]
			}
			
		]
	],
	Activities.HIKE: [
		[
			"%s and %s went for %s %s.",
			[
				"a stroll",
				"a walk",
				"a hike",
				"a bike",
			],
			[
				"in the park",
				"on a trail",
				"outside",
			],
			{
				Event.GOOD: ['It was exhilirating.', 'They held hands.', 'They kissed.'],
				Event.NEUTRAL: ["The weather was nice.", ""],
				Event.BAD: ["They hated it", "The weather was awful.", "They fought." ]
			}
			
		]
	],
	Activities.TRAVEL: [
		[
			"%s and %s traveled to %s and %s.",
			[
				"new york",
				"antarctica",
				"miami",
				"switzerland",
				"the countryside"
			],
			[
				"saw the sights",
				"got arrested",
				"went to a museum",
				"stayed in a cool hotel",
				"got room service",
				"stayed in the hotel room",
				"did tourist stuff"
			],
			{
				Event.GOOD: ['They loved it.', 'They held hands.', 'They kissed.',],
				Event.NEUTRAL: ["It was fine.", ""],
				Event.BAD: ["It sucked.", "They hated it", "It was miserable.", "They fought.",]
			}
			
		]
	],
	Activities.NIGHT_IN: [
		[
			"%s and %s stayed in and %s",
			[
				"watched a movie",
				"played board games",
				"played video games",
				"bingewatched tv",
				"slept a bunch",
				"made dinner together",
				"read books in silence",
				"ordered delivery",
				"watched a documentary",
				"re-enacted Hamlet",
				"played with the microwave",
				"stared at the wall",
				"played with toys",
			],
			{
				Event.GOOD: ['They loved it.', 'They held hands.', 'They kissed.',],
				Event.NEUTRAL: ["It was fine.", ""],
				Event.BAD: ["It sucked.", "They hated it", "It was miserable.", "They fought.",]
			}
			
		]
	],
	Activities.SOCIAL: [
		[
			"%s and %s went to %s for %s",
			[
				"a party",
				"a birthday party",
				"a baby shower",
				"a trial",
				"a surprise party",
				"a graduation party"
			],
			[
				"a sibling",
				"a friend",
				"their boss",
				"a cousin",
				"a random guy",
			],
			{
				Event.GOOD: ['They loved it.', 'They held hands.', 'They kissed.',],
				Event.NEUTRAL: ["It was fine.", ""],
				Event.BAD: ["It sucked.", "They hated it", "It was miserable.", "They fought.",]
			}
			
		]
	],
	Activities.ERRAND: [
		[
			"%s and %s %s.",
			[
				"cleaned their kitchen",
				"did the laundry",
				"took out the recycling",
				"painted the living room",
				"paid their taxes",
				"went grocery shopping",
			],
			{
				Event.GOOD: ['They loved it.', 'They held hands.', 'They kissed.',],
				Event.NEUTRAL: ["It was fine.", ""],
				Event.BAD: ["It sucked.", "They hated it", "It was miserable.", "They fought.",]
			}
		]
	],
}
