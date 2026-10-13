extends Node3D

## AncientSealManager — Gameplay system for Level 4 (Sanctum of the Maze).
## 1. Tracks 3 Ancient Glyphs hidden in the maze (Sun, Moon, Star).
## 2. Tracks 4 Sanctuary Pillar pedestals around the central Great Sanctum Altar.
## 3. Players must discover all 3 Glyphs before the Sanctuary Altar can be energized.
## 4. Once solved, it activates the Great Sanctum Altar and unlocks Door_To_Level5.

signal glyph_discovered(glyph_id: String, glyph_name: String)
signal pillar_attuned(pillar_index: int)
signal seal_completed

@export_category("Configuration")
@export var required_glyph_count: int = 3
@export var total_pillars: int = 4

var discovered_glyphs: Dictionary = {}
var attuned_pillars: Array[int] = []
var seal_unlocked: bool = false

@onready var exit_door: Area3D = get_parent().get_node_or_null("Door_To_Level5")
@onready var altar_node: Area3D = get_parent().get_node_or_null("Inspect_SanctumHeart")

func _ready() -> void:
	add_to_group("ancient_seal_manager")
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path

	# Restore glyphs, pillars, and seal state from GameManager
	if gm != null:
		var saved_glyphs = gm.get_level_mechanism_state(cur_lvl, "discovered_glyphs", {})
		if saved_glyphs is Dictionary:
			discovered_glyphs = saved_glyphs.duplicate()
		var saved_pillars = gm.get_level_mechanism_state(cur_lvl, "attuned_pillars", [])
		if saved_pillars is Array:
			attuned_pillars.clear()
			for p in saved_pillars:
				attuned_pillars.append(int(p))
		seal_unlocked = gm.is_puzzle_solved_saved(cur_lvl, "ancient_seal")

	# Ensure Door_To_Level5 is puzzle-locked initially, unless already solved
	if exit_door != null:
		exit_door.require_puzzle = true
		if seal_unlocked:
			exit_door.door_unlocked = true
		else:
			exit_door.door_unlocked = false
		if exit_door.has_method("_update_prompt_text"):
			exit_door._update_prompt_text()
	
	# Update Sanctuary Altar description and prompt
	_update_altar_state()

func discover_glyph(glyph_id: String, glyph_name: String) -> void:
	if discovered_glyphs.has(glyph_id):
		return
	
	discovered_glyphs[glyph_id] = glyph_name
	var current_count = discovered_glyphs.size()
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null:
		gm.record_item_collected(cur_lvl, glyph_id)
		gm.set_level_mechanism_state(cur_lvl, "discovered_glyphs", discovered_glyphs)
	
	var am = get_node_or_null("/root/AudioManager")
	if am:
		am.play_button_sfx()
		am.play_puzzle_solved_sfx()
	
	var ui = get_node_or_null("/root/UIManager")
	if ui:
		ui.notify_success("Discovered %s! (%d/%d Ancient Glyphs Found)" % [glyph_name, current_count, required_glyph_count])
	
	glyph_discovered.emit(glyph_id, glyph_name)
	_update_altar_state()

func is_glyph_discovered(glyph_id: String) -> bool:
	return discovered_glyphs.has(glyph_id)

func get_discovered_count() -> int:
	return discovered_glyphs.size()

func attune_pillar(pillar_index: int) -> bool:
	if seal_unlocked:
		return false
	
	if discovered_glyphs.size() < required_glyph_count:
		var ui = get_node_or_null("/root/UIManager")
		if ui:
			ui.notify_warning("The pillar stands inert. Find all 3 Ancient Glyphs in the maze first (%d/%d found)." % [discovered_glyphs.size(), required_glyph_count])
		var am = get_node_or_null("/root/AudioManager")
		if am:
			am.play_interact_sfx()
		return false
	
	if attuned_pillars.has(pillar_index):
		var ui = get_node_or_null("/root/UIManager")
		if ui:
			ui.notify_info("This pillar is already humming with radiant power.")
		return false
	
	attuned_pillars.append(pillar_index)
	pillar_attuned.emit(pillar_index)
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null:
		gm.record_pillar_attuned(cur_lvl, pillar_index)
		gm.set_level_mechanism_state(cur_lvl, "attuned_pillars", attuned_pillars)
	
	var am = get_node_or_null("/root/AudioManager")
	if am:
		am.play_lock_unlock_sfx()
	
	var ui = get_node_or_null("/root/UIManager")
	if ui:
		ui.notify_success("Sanctuary Pillar #%d attuned! (%d/%d activated)" % [pillar_index + 1, attuned_pillars.size(), total_pillars])
	
	if attuned_pillars.size() >= total_pillars:
		complete_seal()
	else:
		_update_altar_state()
	
	return true

func is_pillar_attuned(pillar_index: int) -> bool:
	return attuned_pillars.has(pillar_index)

func complete_seal() -> void:
	if seal_unlocked:
		return
	seal_unlocked = true
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null:
		gm.record_puzzle_solved(cur_lvl, "ancient_seal")
	
	var am = get_node_or_null("/root/AudioManager")
	if am:
		am.play_puzzle_solved_sfx()
	
	var ui = get_node_or_null("/root/UIManager")
	if ui:
		ui.notify_success("THE ANCIENT SEAL HAS BEEN AWAKENED! The passage to Level 5 is unlocked!")
	
	# Unlock the doorway
	if exit_door != null:
		exit_door.unlock_door()
	
	_update_altar_state()
	seal_completed.emit()

func _update_altar_state() -> void:
	if altar_node == null:
		return
	
	if seal_unlocked:
		altar_node.interaction_text = "Sanctum Altar (Active)"
		altar_node.description = "The Ancient Seal blazes with golden radiance. The dimensional ward on the northern gateway to Level 5 has dissolved!"
	elif discovered_glyphs.size() < required_glyph_count:
		altar_node.interaction_text = "Inspect Dais"
		altar_node.description = "An ancient dais protected by a tripartite ward. Search the maze to uncover all 3 Ancient Glyphs (%d/%d discovered)." % [discovered_glyphs.size(), required_glyph_count]
	elif attuned_pillars.size() < total_pillars:
		altar_node.interaction_text = "Inspect Dais"
		altar_node.description = "All 3 Glyphs have been deciphered! Attune the four sanctuary pillars circling this chamber to channel energy into the altar (%d/%d attuned)." % [attuned_pillars.size(), total_pillars]
	else:
		altar_node.interaction_text = "Sanctum Altar"
		altar_node.description = "The seal is complete!"
	
	var label = altar_node.get_node_or_null("InteractionLabel")
	if label != null and label is Label3D:
		label.text = "[E] " + altar_node.interaction_text
