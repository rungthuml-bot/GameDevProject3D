extends Node3D

## ThroneChamberManager — Central mission & progression coordinator for Level 8 (Forgotten Throne).
## 1. Tracks 3 Ritual Altars across the throne hall & archives.
## 2. Tracks the Sovereign Seal puzzle solution.
## 3. Disables the golden protective barrier over the Sovereign Relic chest upon completion.
## 4. Persists all progression through GameManager and disk save.

signal altar_activated(altar_index: int, altar_name: String)
signal seal_puzzle_completed

@export var required_altars: int = 3

var activated_altars: Array[int] = []
var seal_puzzle_solved: bool = false

@onready var relic_interactable: Area3D = get_parent().get_node_or_null("Inspect_RoyalRelic")
@onready var chest_node: Node3D = get_parent().get_node_or_null("KayKitDungeon/Props/GoldenRelicChest")
@onready var seal_barrier_light: OmniLight3D = get_node_or_null("SealBarrierLight")

func _ready() -> void:
	add_to_group("throne_chamber_manager")
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path

	if gm != null:
		var saved_altars = gm.get_level_mechanism_state(cur_lvl, "activated_altars", [])
		if saved_altars is Array:
			activated_altars.clear()
			for a in saved_altars:
				activated_altars.append(int(a))
		seal_puzzle_solved = gm.is_puzzle_solved_saved(cur_lvl, "sovereign_seal_puzzle")

	_apply_seal_state_to_relic()

func activate_ritual_altar(altar_index: int, altar_name: String) -> bool:
	if activated_altars.has(altar_index):
		return false
	
	activated_altars.append(altar_index)
	altar_activated.emit(altar_index, altar_name)
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null:
		gm.record_pillar_attuned(cur_lvl, altar_index)
		gm.set_level_mechanism_state(cur_lvl, "activated_altars", activated_altars)
	
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr:
		audio_mgr.play_button_sfx()
		audio_mgr.play_lock_unlock_sfx()
	
	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr:
		ui_mgr.notify_success("Awakened %s! (%d/%d Ritual Altars Activated)" % [altar_name, activated_altars.size(), required_altars])
	
	return true

func are_altars_completed() -> bool:
	return activated_altars.size() >= required_altars

func get_active_altar_count() -> int:
	return activated_altars.size()

func solve_seal_puzzle() -> void:
	if seal_puzzle_solved:
		return
	seal_puzzle_solved = true
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null:
		gm.record_puzzle_solved(cur_lvl, "sovereign_seal_puzzle")
	
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr:
		audio_mgr.play_puzzle_solved_sfx()
	
	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr:
		ui_mgr.notify_success("THE SOVEREIGN SEAL HAS DISSOLVED! The Sacred Relic is free!")
	
	_apply_seal_state_to_relic()
	seal_puzzle_completed.emit()

func _apply_seal_state_to_relic() -> void:
	if seal_barrier_light:
		seal_barrier_light.light_energy = 0.5 if seal_puzzle_solved else 3.5
		seal_barrier_light.light_color = Color(0.4, 0.9, 1.0, 1.0) if seal_puzzle_solved else Color(1.0, 0.25, 0.2, 1.0)
