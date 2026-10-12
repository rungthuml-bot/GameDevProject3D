extends Node3D

## CrystalCavernManager — Core gameplay system for Level 7 (Crystal Cavern).
## 1. Tracks 3 Shard Crystals hidden in the cavern (Azure, Amethyst, Emerald).
## 2. Tracks Crystal Core activation at Pinnacle of the Core (0, 0, -3.2).
## 3. Manages the 2 Reflecting Crystal Pedestals for the Crystal Beam Puzzle.
## 4. Once the beams are aligned towards the core, unlocks Door_To_Level8.

signal crystal_collected(crystal_id: String, crystal_name: String)
signal core_activated
signal puzzle_solved

@export var required_crystal_count: int = 3

var collected_crystals: Dictionary = {}
var core_is_activated: bool = false
var beam_puzzle_completed: bool = false

# Target orientations: West pedestal target = 1 (angle 90 deg -> points towards X=0), East pedestal target = 3 (angle 270 deg -> points towards X=0)
var pedestal_west_state: int = 0
var pedestal_east_state: int = 0

@onready var exit_door: Area3D = get_parent().get_node_or_null("Door_To_Level8")
@onready var core_altar: Area3D = get_parent().get_node_or_null("Inspect_GrandCrystalPinnacle")
@onready var core_glow: OmniLight3D = get_node_or_null("CoreGlowLight")
@onready var beam_west: MeshInstance3D = get_node_or_null("BeamWest")
@onready var beam_east: MeshInstance3D = get_node_or_null("BeamEast")

func _ready() -> void:
	add_to_group("crystal_cavern_manager")
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path

	if gm != null:
		var saved_crystals = gm.get_level_mechanism_state(cur_lvl, "collected_crystals", {})
		if saved_crystals is Dictionary:
			collected_crystals = saved_crystals.duplicate()
		core_is_activated = gm.get_level_mechanism_state(cur_lvl, "core_is_activated", false)
		pedestal_west_state = gm.get_level_mechanism_state(cur_lvl, "pedestal_west_state", 0)
		pedestal_east_state = gm.get_level_mechanism_state(cur_lvl, "pedestal_east_state", 0)
		beam_puzzle_completed = gm.is_puzzle_solved_saved(cur_lvl, "crystal_beam_puzzle")

	# Lock or unlock Door_To_Level8 based on puzzle state
	if exit_door != null:
		exit_door.require_puzzle = true
		if beam_puzzle_completed:
			exit_door.door_unlocked = true
		else:
			exit_door.door_unlocked = false
		if exit_door.has_method("_update_prompt_text"):
			exit_door._update_prompt_text()
	
	if beam_west:
		beam_west.visible = (core_is_activated and pedestal_west_state == 1)
	if beam_east:
		beam_east.visible = (core_is_activated and pedestal_east_state == 3)
	if core_glow:
		core_glow.light_energy = 3.8 if core_is_activated else 0.5
	
	_update_core_altar_description()

func collect_crystal(crystal_id: String, crystal_name: String) -> void:
	if collected_crystals.has(crystal_id):
		return
	
	collected_crystals[crystal_id] = crystal_name
	var count = collected_crystals.size()
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null:
		gm.record_item_collected(cur_lvl, crystal_id)
		gm.set_level_mechanism_state(cur_lvl, "collected_crystals", collected_crystals)
	
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr:
		audio_mgr.play_button_sfx()
		audio_mgr.play_lock_unlock_sfx()
	
	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr:
		ui_mgr.notify_success("Found %s! (%d/%d Power Crystals Collected)" % [crystal_name, count, required_crystal_count])
	
	crystal_collected.emit(crystal_id, crystal_name)
	_update_core_altar_description()

func is_crystal_collected(crystal_id: String) -> bool:
	return collected_crystals.has(crystal_id)

func get_crystal_count() -> int:
	return collected_crystals.size()

func can_activate_core() -> bool:
	return collected_crystals.size() >= required_crystal_count

func activate_core() -> bool:
	if core_is_activated:
		return false
	
	var audio_mgr = get_node_or_null("/root/AudioManager")
	var ui_mgr = get_node_or_null("/root/UIManager")
	
	if collected_crystals.size() < required_crystal_count:
		if ui_mgr:
			ui_mgr.notify_warning("The Pinnacle is dormant. Collect all 3 Power Crystals from the cavern fissures first (%d/%d found)." % [collected_crystals.size(), required_crystal_count])
		if audio_mgr:
			audio_mgr.play_interact_sfx()
		return false
	
	core_is_activated = true
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null:
		gm.set_level_mechanism_state(cur_lvl, "core_is_activated", true)

	if audio_mgr:
		audio_mgr.play_puzzle_solved_sfx()
	
	if ui_mgr:
		ui_mgr.notify_success("THE CRYSTAL CORE HAS BEEN ENERGIZED! Rotate the pedestals to focus the refraction beams!")
	
	if core_glow and is_inside_tree():
		var tw = create_tween()
		if tw:
			tw.tween_property(core_glow, "light_energy", 3.8, 0.6)
	
	_update_core_altar_description()
	core_activated.emit()
	_check_beam_alignment()
	return true

func update_pedestal_orientation(is_west: bool, state: int) -> void:
	if is_west:
		pedestal_west_state = state
	else:
		pedestal_east_state = state
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null:
		if is_west:
			gm.set_level_mechanism_state(cur_lvl, "pedestal_west_state", pedestal_west_state)
		else:
			gm.set_level_mechanism_state(cur_lvl, "pedestal_east_state", pedestal_east_state)

	_check_beam_alignment()

func _check_beam_alignment() -> void:
	if not core_is_activated:
		if beam_west: beam_west.visible = false
		if beam_east: beam_east.visible = false
		return
	
	# West pedestal aligned when state == 1 (pointing East toward center)
	var west_aligned = (pedestal_west_state == 1)
	if beam_west:
		beam_west.visible = west_aligned
	
	# East pedestal aligned when state == 3 (pointing West toward center)
	var east_aligned = (pedestal_east_state == 3)
	if beam_east:
		beam_east.visible = east_aligned
	
	if west_aligned and east_aligned and not beam_puzzle_completed:
		complete_beam_puzzle()

func complete_beam_puzzle() -> void:
	beam_puzzle_completed = true
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null:
		gm.record_puzzle_solved(cur_lvl, "crystal_beam_puzzle")

	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr:
		audio_mgr.play_puzzle_solved_sfx()
	
	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr:
		ui_mgr.notify_success("RESONANCE ACHIEVED! The Gateway to Level 8 is unlocked!")
	
	if exit_door != null:
		exit_door.unlock_door()
	
	_update_core_altar_description()
	puzzle_solved.emit()

func _update_core_altar_description() -> void:
	if core_altar == null:
		return
	
	if beam_puzzle_completed:
		core_altar.interaction_text = "Master Pinnacle (Harmonized)"
		core_altar.description = "The Crystal Core blazes with celestial cyan brilliance. Prismatic beams focus into the gateway threshold to Level 8!"
	elif core_is_activated:
		core_altar.interaction_text = "Master Pinnacle (Active)"
		core_altar.description = "The Core is pulsing with raw light! Rotate the reflecting crystal pedestals to the west and east to channel the beam straight into the core."
	else:
		core_altar.interaction_text = "Commune with Core"
		core_altar.description = "The Master Crystal Pinnacle rests dormant in the ceremonial chamber. Collect 3 Power Crystals from the cavern fissures to awaken it (%d/%d collected)." % [collected_crystals.size(), required_crystal_count]
	
	var label = core_altar.get_node_or_null("InteractionLabel")
	if label != null and label is Label3D:
		label.text = "[E] " + core_altar.interaction_text
