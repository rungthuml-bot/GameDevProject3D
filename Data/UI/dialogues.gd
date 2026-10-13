class_name DialogueDatabase
extends RefCounted

## DialogueDatabase — Central repository for narrative dialogue data.
## Pure data layer — decoupled from UI and gameplay logic.
## Add, modify, or translate dialogues here without modifying UI scripts.

const DIALOGUES: Dictionary = {
	"level_0_intro": {
		"id": "level_0_intro",
		"level_id": "level_0",
		"title": "The Forgotten Entrance",
		"lines": [
			{
				"speaker": "Player",
				"text": "The wind howls through the ancient pine woods..."
			},
			{
				"speaker": "Player",
				"text": "Ahead lies the forgotten entrance to the subterranean maze."
			},
			{
				"speaker": "Player",
				"text": "I must proceed cautiously into the depths."
			}
		]
	},
	"level_1_intro": {
		"id": "level_1_intro",
		"level_id": "level_1",
		"title": "Dungeon Entrance",
		"lines": [
			{
				"speaker": "Player",
				"text": "Where is this place... Why is it so quiet?"
			},
			{
				"speaker": "Player",
				"text": "Looks like I need to find a way out of here."
			},
			{
				"speaker": "Player",
				"text": "Alright... There's no other choice but to press forward."
			}
		]
	},
	"level_2_intro": {
		"id": "level_2_intro",
		"level_id": "level_2",
		"title": "Deeper Halls",
		"lines": [
			{
				"speaker": "Player",
				"text": "The path ahead is eerily quiet... The air is growing colder."
			},
			{
				"speaker": "Player",
				"text": "I hope nothing is lurking in the shadows."
			},
			{
				"speaker": "Player",
				"text": "I need to stay on high alert."
			}
		]
	},
	"level_3_intro": {
		"id": "level_3_intro",
		"level_id": "level_3",
		"title": "Crypt of Shadows",
		"lines": [
			{
				"speaker": "Player",
				"text": "The deeper I go, the stranger it gets... These walls bear traces of ancient magic."
			},
			{
				"speaker": "Player",
				"text": "Something doesn't want me to proceed..."
			},
			{
				"speaker": "Player",
				"text": "Yet I must uncover the truth behind this place."
			}
		]
	},
	"level_4_intro": {
		"id": "level_4_intro",
		"level_id": "level_4",
		"title": "Sanctum of the Maze",
		"lines": [
			{
				"speaker": "Player",
				"text": "Finally made it here... The final gate of the dungeon."
			},
			{
				"speaker": "Player",
				"text": "If the answers lie ahead,"
			},
			{
				"speaker": "Player",
				"text": "I won't stop until the truth is revealed."
			}
		]
	},
	"level_5_intro": {
		"id": "level_5_intro",
		"level_id": "level_5",
		"title": "The Haunted Archive",
		"lines": [
			{
				"speaker": "Player",
				"text": "Beyond the sanctum... I find myself in a vast subterranean archive."
			},
			{
				"speaker": "Player",
				"text": "Rows of ancient shelves... and something else — dust disturbed recently."
			},
			{
				"speaker": "Player",
				"text": "Someone was here before me. I must search every corner."
			}
		]
	},
	"level_6_intro": {
		"id": "level_6_intro",
		"level_id": "level_6",
		"title": "The Sunken Crypt",
		"lines": [
			{
				"speaker": "Player",
				"text": "The ground slopes downward into a sunken crypt...\nThe air is thick with decay."
			},
			{
				"speaker": "Player",
				"text": "Ancient sarcophagi line the walls... each sealed with a dark curse."
			},
			{
				"speaker": "Player",
				"text": "I'll have to tread carefully — this place does not welcome the living."
			}
		]
	},
	"level_7_intro": {
		"id": "level_7_intro",
		"level_id": "level_7",
		"title": "Crystal Cavern",
		"lines": [
			{
				"speaker": "Player",
				"text": "Incredible... The walls here pulse with living crystal formations."
			},
			{
				"speaker": "Player",
				"text": "Three energy crystals — azure, amethyst, emerald — must be gathered\nto power the Crystal Core."
			},
			{
				"speaker": "Player",
				"text": "The beams of light shift as I move. I must solve what the cavern is telling me."
			}
		]
	},
	"level_8_intro": {
		"id": "level_8_intro",
		"level_id": "level_8",
		"title": "Forgotten Throne",
		"lines": [
			{
				"speaker": "Player",
				"text": "The Forgotten Throne... This is the heart of the labyrinth."
			},
			{
				"speaker": "Player",
				"text": "Three ritual altars surround the throne — each must be activated\nto reveal the Sovereign Relic."
			},
			{
				"speaker": "Player",
				"text": "After all this... the truth finally lies within reach."
			}
		]
	}
}


static func has_dialogue(id: String) -> bool:
	return DIALOGUES.has(id)


static func get_dialogue(id: String) -> Dictionary:
	if DIALOGUES.has(id):
		return DIALOGUES[id].duplicate(true)
	return {}


static func get_all_ids() -> Array[String]:
	var ids: Array[String] = []
	for key in DIALOGUES.keys():
		ids.append(str(key))
	return ids


static func get_dialogue_for_level(level_id: String) -> Dictionary:
	var expected_id := level_id.to_lower() + "_intro"
	if has_dialogue(expected_id):
		return get_dialogue(expected_id)

	# Search by level_id field fallback
	for key in DIALOGUES.keys():
		var data: Dictionary = DIALOGUES[key]
		if data.get("level_id", "").to_lower() == level_id.to_lower():
			return data.duplicate(true)

	return {}
