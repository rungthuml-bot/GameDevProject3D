class_name DialogueDatabase
extends RefCounted

## DialogueDatabase — Central repository for narrative dialogue data.
## Pure data layer — decoupled from UI and gameplay logic.
## Add, modify, or translate dialogues here without modifying UI scripts.

const DIALOGUES: Dictionary = {
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
