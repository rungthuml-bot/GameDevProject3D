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
				"text": "นี่มันที่ไหนกัน... ทำไมถึงเงียบขนาดนี้"
			},
			{
				"speaker": "Player",
				"text": "ดูเหมือนว่าฉันจะต้องหาทางออกจากที่นี่ให้ได้"
			},
			{
				"speaker": "Player",
				"text": "เอาล่ะ... คงไม่มีทางอื่นนอกจากเดินหน้าต่อ"
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
				"text": "ทางข้างหน้าเงียบเกินไป... บรรยากาศเริ่มเย็นลงเรื่อยๆ"
			},
			{
				"speaker": "Player",
				"text": "หวังว่าจะไม่มีอะไรซ่อนอยู่ในความมืด"
			},
			{
				"speaker": "Player",
				"text": "ต้องระวังตัวให้มากกว่าเดิม"
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
				"text": "ยิ่งเดินลึกเข้ามา ทุกอย่างยิ่งแปลกขึ้น... กำแพงนี้มีร่องรอยเวทมนตร์"
			},
			{
				"speaker": "Player",
				"text": "มีบางอย่างไม่อยากให้ฉันไปต่อ..."
			},
			{
				"speaker": "Player",
				"text": "แต่ฉันต้องรู้ความจริงของที่แห่งนี้"
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
				"text": "ในที่สุดก็มาถึงที่นี่... ประตูบานสุดท้ายของดันเจี้ยน"
			},
			{
				"speaker": "Player",
				"text": "ถ้าคำตอบอยู่ข้างหน้า"
			},
			{
				"speaker": "Player",
				"text": "ฉันก็จะไม่หยุดจนกว่าจะรู้ความจริง"
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
