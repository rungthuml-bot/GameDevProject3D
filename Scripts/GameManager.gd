extends Node

## GameManager — Autoload singleton for global game state, spawn points, and camera persistence.

var next_spawn_id: String = ""
var is_first_person: bool = true
var is_restarting_level: bool = false
var has_relic: bool = false
var relic_returned: bool = false

## Default spawn node names per level scene
const LEVEL_DEFAULT_SPAWNS: Dictionary = {
	"res://Scenes/Level/level_0.tscn": "PlayerSpawn",
	"res://Scenes/Level/level_1.tscn": "Spawn_From_Map0",
	"res://Scenes/Level/level_2.tscn": "Spawn_From_Level2",
	"res://Scenes/Level/level_3.tscn": "PlayerSpawn",
	"res://Scenes/Level/level_4.tscn": "PlayerSpawn",
	"res://Scenes/Level/level_5.tscn": "PlayerSpawn",
	"res://Scenes/Level/level_6.tscn": "PlayerSpawn",
	"res://Scenes/Level/level_7.tscn": "PlayerSpawn",
	"res://Scenes/Level/level_8.tscn": "Default_Spawn"
}


func get_default_spawn_for_level(level_path: String) -> String:
	return LEVEL_DEFAULT_SPAWNS.get(level_path, "PlayerSpawn")


func trigger_trap_restart(trap_name: String = "Lethal Trap") -> void:
	if is_restarting_level:
		return
	is_restarting_level = true

	# Disable player controls
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("disable_controls"):
		player.disable_controls()

	if has_node("/root/AudioManager"):
		AudioManager.play_puzzle_warning_sfx()

	if has_node("/root/UIManager"):
		UIManager.notify_danger("%s triggered! Restarting current level..." % trap_name)

	# Set the correct default spawn point for the current scene
	var cur_scene_path: String = ""
	if get_tree().current_scene:
		cur_scene_path = get_tree().current_scene.scene_file_path

	if cur_scene_path.is_empty() and has_node("/root/UIManager"):
		cur_scene_path = UIManager.current_level_path

	var default_spawn = get_default_spawn_for_level(cur_scene_path)
	set_spawn_point(default_spawn)

	# Wait briefly for notification, then reload current level scene
	await get_tree().create_timer(0.45).timeout

	if not cur_scene_path.is_empty():
		get_tree().change_scene_to_file(cur_scene_path)
	else:
		get_tree().reload_current_scene()

	# Re-enable controls flag after scene finishes loading
	await get_tree().process_frame
	await get_tree().process_frame
	is_restarting_level = false


func set_spawn_point(spawn_id: String) -> void:
	next_spawn_id = spawn_id


func get_spawn_point() -> String:
	return next_spawn_id


func clear_spawn_point() -> void:
	next_spawn_id = ""


func set_first_person(enabled: bool) -> void:
	is_first_person = enabled


func is_first_person_enabled() -> bool:
	return is_first_person


signal inventory_updated
signal held_item_changed(item_id: String)

var held_item_id: String = ""

## Registry of canonical game items.
## Designed to support additional items cleanly without phantom items or gameplay rewrites.
const ITEM_DEFINITIONS: Dictionary = {
	"sovereign_relic": {
		"id": "sovereign_relic",
		"name": "The Sovereign Relic",
		"title_th": "คทาราชันโบราณ",
		"category": "Sacred Artifact",
		"icon_symbol": "♚",
		"model_scene": "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/chest_gold.gltf",
		"description": "An ancient golden scepter imbued with the eldritch authority of Eldoria. Required to dissolve the seal on the Sanctuary Gate in Level 1.",
		"lore": "Forged in the labyrinth's deepest sanctuary (Level 8) to command the labyrinth. Returning it to the surface altar breaks the final gate seal."
	}
}

func get_item_definition(item_id: String) -> Dictionary:
	return ITEM_DEFINITIONS.get(item_id, {})


func has_item(item_id: String) -> bool:
	match item_id:
		"sovereign_relic":
			return has_relic
		_:
			return false


func is_item_discovered(item_id: String) -> bool:
	match item_id:
		"sovereign_relic":
			return has_relic or relic_returned
		_:
			return false


func get_item_status(item_id: String) -> String:
	match item_id:
		"sovereign_relic":
			if relic_returned:
				return "RETURNED"
			elif has_relic:
				return "IN_POSSESSION"
			else:
				return "UNFOUND"
		_:
			return "UNKNOWN"


func get_item_status_display(item_id: String) -> Dictionary:
	var status := get_item_status(item_id)
	match status:
		"IN_POSSESSION":
			return {
				"text": "Possessed / ครอบครองแล้ว",
				"color": Color(0.95, 0.82, 0.45, 1.0),
				"is_possessed": true
			}
		"RETURNED":
			return {
				"text": "Restored at Altar / ประดิษฐานแล้ว",
				"color": Color(0.45, 0.85, 0.55, 1.0),
				"is_possessed": false
			}
		_:
			return {
				"text": "Undiscovered / ยังไม่พบ",
				"color": Color(0.65, 0.62, 0.58, 0.7),
				"is_possessed": false
			}


func set_relic_acquired(acquired: bool) -> void:
	if has_relic != acquired:
		has_relic = acquired
		inventory_updated.emit()


func set_relic_returned(returned: bool) -> void:
	if relic_returned != returned:
		relic_returned = returned
		# If the player is currently holding the relic and returns it, unequip it
		if returned and held_item_id == "sovereign_relic":
			set_held_item("")
		inventory_updated.emit()


func can_hold_item(item_id: String) -> bool:
	match item_id:
		"sovereign_relic":
			# Only allow holding if the player currently possesses it and hasn't returned it
			return has_relic and not relic_returned
		_:
			return false


func set_held_item(item_id: String) -> void:
	if item_id == held_item_id:
		return
	if item_id != "" and not can_hold_item(item_id):
		return
	held_item_id = item_id
	held_item_changed.emit(held_item_id)


func toggle_held_item(item_id: String) -> void:
	if held_item_id == item_id:
		set_held_item("")
	else:
		set_held_item(item_id)


func get_held_item() -> String:
	return held_item_id


func reset_game_state() -> void:
	next_spawn_id = ""
	has_relic = false
	relic_returned = false
	held_item_id = ""
	held_item_changed.emit("")
	inventory_updated.emit()

