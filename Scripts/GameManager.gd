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
		get_node("/root/AudioManager").play_puzzle_warning_sfx()

	if has_node("/root/UIManager"):
		get_node("/root/UIManager").notify_danger("%s triggered! Restarting current level..." % trap_name)

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
		"title_th": "คทาและตราประจำองค์ราชันย์",
		"category": "Sacred Artifact",
		"icon_symbol": "♚",
		"model_scene": "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/sword_shield_gold.gltf",
		"description": "An ancient golden scepter imbued with the eldritch authority of Eldoria. Required to dissolve the seal on the Sanctuary Gate in Level 1.",
		"lore": "Forged in the labyrinth's deepest sanctuary (Level 8) to command the labyrinth. Returning it to the surface altar breaks the final gate seal."
	},
	"crystal_azure": {
		"id": "crystal_azure",
		"name": "Azure Energy Crystal",
		"title_th": "ผลึกคริสตัลพลังงานสีฟ้า",
		"category": "Elemental Core",
		"icon_symbol": "🔷",
		"model_scene": "",
		"description": "A radiant azure crystal resonant with high-frequency atmospheric pulse. Harvested from Level 7 fissures.",
		"lore": "One of the three harmonic keystones required to revitalize the Pinnacle of the Core."
	},
	"crystal_amethyst": {
		"id": "crystal_amethyst",
		"name": "Amethyst Energy Crystal",
		"title_th": "ผลึกคริสตัลพลังงานสีม่วง",
		"category": "Elemental Core",
		"icon_symbol": "🔮",
		"model_scene": "",
		"description": "A luminous violet crystal harvested from deep geode fissures in Level 7.",
		"lore": "Resonates with subterranean geomagnetic currents, attuning the reflecting crystal pillars."
	},
	"crystal_emerald": {
		"id": "crystal_emerald",
		"name": "Emerald Energy Crystal",
		"title_th": "ผลึกคริสตัลพลังงานสีเขียว",
		"category": "Elemental Core",
		"icon_symbol": "🟢",
		"model_scene": "",
		"description": "A rare emerald-green crystal nestled near the sanctum archway in Level 7.",
		"lore": "Channeling pure life force through the grand cavern core to breach the final descent."
	}
}

func get_item_definition(item_id: String) -> Dictionary:
	return ITEM_DEFINITIONS.get(item_id, {})


func has_item(item_id: String) -> bool:
	match item_id:
		"sovereign_relic":
			return has_relic
		"crystal_azure", "crystal_amethyst", "crystal_emerald":
			if not progress_data.has("levels"):
				return false
			for lvl_dict in progress_data["levels"].values():
				if lvl_dict is Dictionary and lvl_dict.has("collected_items"):
					var items = lvl_dict["collected_items"]
					if items is Array and items.has(item_id):
						return true
			return false
		_:
			return false


func is_item_discovered(item_id: String) -> bool:
	match item_id:
		"sovereign_relic":
			return has_relic or relic_returned
		"crystal_azure", "crystal_amethyst", "crystal_emerald":
			return has_item(item_id)
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
		"crystal_azure", "crystal_amethyst", "crystal_emerald":
			if has_item(item_id):
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
		save_game_to_disk()


func set_relic_returned(returned: bool) -> void:
	if relic_returned != returned:
		relic_returned = returned
		# If the player is currently holding the relic and returns it, unequip it
		if returned and held_item_id == "sovereign_relic":
			set_held_item("")
		inventory_updated.emit()
		save_game_to_disk()


func can_hold_item(item_id: String) -> bool:
	match item_id:
		"sovereign_relic":
			# Only allow holding if the player currently possesses it and hasn't returned it
			return has_relic and not relic_returned
		"crystal_azure", "crystal_amethyst", "crystal_emerald":
			return has_item(item_id)
		_:
			return false


func set_held_item(item_id: String) -> void:
	if item_id == held_item_id:
		return
	if item_id != "" and not can_hold_item(item_id):
		return
	held_item_id = item_id
	held_item_changed.emit(held_item_id)
	save_game_to_disk()


func toggle_held_item(item_id: String) -> void:
	if held_item_id == item_id:
		set_held_item("")
	else:
		set_held_item(item_id)


func get_held_item() -> String:
	return held_item_id


# =========================================================
# PERSISTENT PROGRESSION & SAVE / LOAD SYSTEM
# =========================================================

const SAVE_FILE_PATH: String = "user://dungeon_savegame.json"

## In-memory progression data preserved during scene changes and transitions.
## Structure:
## {
##   "sovereign_relic": { "has_relic": bool, "relic_returned": bool, "held_item_id": String },
##   "levels": {
##      level_path_or_id: {
##         "puzzles_solved": [puzzle_id, ...],
##         "unlocked_doors": [door_name, ...],
##         "collected_items": [item_id, ...],
##         "chests_opened": [chest_identifier, ...],
##         "pillars_attuned": [pillar_index, ...],
##         "mechanisms": { "core_activated": bool, "pedestals": { ... }, ... }
##      }
##   }
## }
var progress_data: Dictionary = {
	"sovereign_relic": {
		"has_relic": false,
		"relic_returned": false,
		"held_item_id": ""
	},
	"levels": {}
}

func _ready() -> void:
	load_game_from_disk()


## Get level data dictionary for a specific level path or name.
func _get_level_entry(level_key: String) -> Dictionary:
	if not progress_data.has("levels"):
		progress_data["levels"] = {}
	if not progress_data["levels"].has(level_key):
		progress_data["levels"][level_key] = {
			"puzzles_solved": [],
			"unlocked_doors": [],
			"collected_items": [],
			"chests_opened": [],
			"pillars_attuned": [],
			"mechanisms": {}
		}
	return progress_data["levels"][level_key]


func get_current_level_key() -> String:
	var cur_scene = get_tree().current_scene
	if cur_scene and not cur_scene.scene_file_path.is_empty():
		return cur_scene.scene_file_path
	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr and not ui_mgr.current_level_path.is_empty():
		return ui_mgr.current_level_path
	return "res://Scenes/Level/level_0.tscn"


# --- Door Locking & Unlocking ---

func record_door_unlocked(level_key: String, door_name: String) -> void:
	if level_key.is_empty():
		level_key = get_current_level_key()
	var lvl = _get_level_entry(level_key)
	if not lvl["unlocked_doors"].has(door_name):
		lvl["unlocked_doors"].append(door_name)
		save_game_to_disk()


func is_door_unlocked_saved(level_key: String, door_name: String) -> bool:
	if level_key.is_empty():
		level_key = get_current_level_key()
	if not progress_data.has("levels") or not progress_data["levels"].has(level_key):
		return false
	return progress_data["levels"][level_key]["unlocked_doors"].has(door_name)


# --- Puzzle Solved ---

func record_puzzle_solved(level_key: String, puzzle_id: String) -> void:
	if level_key.is_empty():
		level_key = get_current_level_key()
	var lvl = _get_level_entry(level_key)
	if not lvl["puzzles_solved"].has(puzzle_id):
		lvl["puzzles_solved"].append(puzzle_id)
		save_game_to_disk()


func is_puzzle_solved_saved(level_key: String, puzzle_id: String) -> bool:
	if level_key.is_empty():
		level_key = get_current_level_key()
	if not progress_data.has("levels") or not progress_data["levels"].has(level_key):
		return false
	return progress_data["levels"][level_key]["puzzles_solved"].has(puzzle_id)


# --- Collected Items & Glyphs & Crystals ---

func record_item_collected(level_key: String, item_id: String) -> void:
	if level_key.is_empty():
		level_key = get_current_level_key()
	var lvl = _get_level_entry(level_key)
	if not lvl["collected_items"].has(item_id):
		lvl["collected_items"].append(item_id)
		save_game_to_disk()


func is_item_collected_saved(level_key: String, item_id: String) -> bool:
	if level_key.is_empty():
		level_key = get_current_level_key()
	if not progress_data.has("levels") or not progress_data["levels"].has(level_key):
		return false
	return progress_data["levels"][level_key]["collected_items"].has(item_id)


# --- Chests Opened ---

func record_chest_opened(level_key: String, chest_id: String) -> void:
	if level_key.is_empty():
		level_key = get_current_level_key()
	var lvl = _get_level_entry(level_key)
	if not lvl["chests_opened"].has(chest_id):
		lvl["chests_opened"].append(chest_id)
		save_game_to_disk()


func is_chest_opened_saved(level_key: String, chest_id: String) -> bool:
	if level_key.is_empty():
		level_key = get_current_level_key()
	if not progress_data.has("levels") or not progress_data["levels"].has(level_key):
		return false
	return progress_data["levels"][level_key]["chests_opened"].has(chest_id)


# --- Pillars Attuned ---

func record_pillar_attuned(level_key: String, pillar_index: int) -> void:
	if level_key.is_empty():
		level_key = get_current_level_key()
	var lvl = _get_level_entry(level_key)
	if not lvl["pillars_attuned"].has(pillar_index):
		lvl["pillars_attuned"].append(pillar_index)
		save_game_to_disk()


func is_pillar_attuned_saved(level_key: String, pillar_index: int) -> bool:
	if level_key.is_empty():
		level_key = get_current_level_key()
	if not progress_data.has("levels") or not progress_data["levels"].has(level_key):
		return false
	return progress_data["levels"][level_key]["pillars_attuned"].has(pillar_index)


# --- Generic Mechanisms / State Dictionary per Level ---

func set_level_mechanism_state(level_key: String, key: String, value: Variant) -> void:
	if level_key.is_empty():
		level_key = get_current_level_key()
	var lvl = _get_level_entry(level_key)
	lvl["mechanisms"][key] = value
	save_game_to_disk()


func get_level_mechanism_state(level_key: String, key: String, default_val: Variant = null) -> Variant:
	if level_key.is_empty():
		level_key = get_current_level_key()
	if not progress_data.has("levels") or not progress_data["levels"].has(level_key):
		return default_val
	return progress_data["levels"][level_key]["mechanisms"].get(key, default_val)


# --- Save / Load to Disk ---

func save_game_to_disk() -> void:
	# Keep relic state synchronized in progress_data
	if not progress_data.has("sovereign_relic"):
		progress_data["sovereign_relic"] = {}
	progress_data["sovereign_relic"]["has_relic"] = has_relic
	progress_data["sovereign_relic"]["relic_returned"] = relic_returned
	progress_data["sovereign_relic"]["held_item_id"] = held_item_id

	var json_str := JSON.stringify(progress_data, "\t")
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(json_str)
		file.close()


func load_game_from_disk() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return false
	
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		return false
	
	var content := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_err := json.parse(content)
	if parse_err != OK:
		print("Warning: Corrupted save file encountered at ", SAVE_FILE_PATH, ". Using safe memory defaults.")
		return false
	
	var parsed_val = json.data
	if typeof(parsed_val) != TYPE_DICTIONARY:
		return false
	
	progress_data = parsed_val
	
	# Restore Sovereign Relic
	if progress_data.has("sovereign_relic"):
		var r_data: Dictionary = progress_data["sovereign_relic"]
		has_relic = r_data.get("has_relic", false)
		relic_returned = r_data.get("relic_returned", false)
		held_item_id = r_data.get("held_item_id", "")
	
	inventory_updated.emit()
	held_item_changed.emit(held_item_id)
	return true


func reset_game_state(clear_disk_save: bool = false) -> void:
	next_spawn_id = ""
	has_relic = false
	relic_returned = false
	held_item_id = ""
	progress_data = {
		"sovereign_relic": {
			"has_relic": false,
			"relic_returned": false,
			"held_item_id": ""
		},
		"levels": {}
	}
	if clear_disk_save and FileAccess.file_exists(SAVE_FILE_PATH):
		var dir := DirAccess.open("user://")
		if dir:
			dir.remove("dungeon_savegame.json")
	
	held_item_changed.emit("")
	inventory_updated.emit()

