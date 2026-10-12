extends Area3D

## Door — Interactive portal and transition gateway system.
## Supports:
## 1. Visual hinged doors (rotating open smoothly via Tween around proper hinge pivot, disabling solid collision).
## 2. Gateway / Archway portals (smooth pulse transition with audio-visual feedback before warp).
## 3. Clear "[E] Open Door" prompt when in range.
## 4. Debounced anti-spam input handling to prevent duplicate triggers and double scene loading.
## 5. Full preservation of Puzzle locks, keys, relics, and spawn point specifications.

@export_category("Interaction")
@export var interaction_text: String = "Open Door"
@export var interaction_title: String = "Ancient Door"
@export_multiline var description: String = "Enter the next area."

@export_category("Level Transition")
@export_file("*.tscn") var target_scene: String
@export var target_spawn_id: String = ""

@export_category("Puzzle Requirement")
@export var require_puzzle: bool = false

@export_category("Door Animation")
@export var open_angle_degrees: float = 90.0
@export var open_duration: float = 0.85

@onready var interaction_label: Label3D = $InteractionLabel

var player: Node3D = null
var door_unlocked: bool = false
var is_open: bool = false
var _is_transitioning: bool = false

# Internal references to physical door leaf and obstacles
var _door_leaf: Node3D = null
var _solid_body: StaticBody3D = null
var _portal_light: OmniLight3D = null


func _ready() -> void:
	add_to_group("interactable")
	add_to_group("doors")

	_find_door_components()

	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path

	if not require_puzzle or (gm != null and gm.is_door_unlocked_saved(cur_lvl, name)):
		door_unlocked = true

	_update_prompt_text()
	if is_instance_valid(interaction_label):
		interaction_label.visible = false

	player = get_tree().get_first_node_in_group("player")


func _find_door_components() -> void:
	# Check if an explicit Hinge node exists first
	var hinge_found = find_child("Hinge", true, false)
	if hinge_found != null and hinge_found is Node3D:
		_door_leaf = hinge_found
	else:
		# Detect visual door mesh or model
		var candidates = ["Door", "door_dungeon_leaf", "door_cell_leaf", "Door_Root", "Model"]
		for candidate in candidates:
			var found = find_child(candidate, true, false)
			if found != null and found is Node3D and found != self:
				_door_leaf = found
				break

	# Detect solid obstacle collision
	var solid = find_child("StaticBody3D", true, false)
	if solid != null and solid is StaticBody3D:
		_solid_body = solid

	# Detect portal light for archways/gateways
	var p_light = find_child("PortalLight", true, false)
	if p_light == null:
		p_light = find_child("Door2Glow", true, false)
	if p_light != null and p_light is OmniLight3D:
		_portal_light = p_light


func _update_prompt_text() -> void:
	if not is_instance_valid(interaction_label):
		return

	if not door_unlocked:
		interaction_label.text = "[E] Locked"
		interaction_label.modulate = Color(0.85, 0.45, 0.45, 1.0)
	elif is_open or _is_transitioning:
		interaction_label.text = "[Entering...]"
		interaction_label.modulate = Color(0.65, 0.65, 0.65, 0.8)
	else:
		interaction_label.text = "[E] " + interaction_text
		interaction_label.modulate = Color(1.0, 0.92, 0.65, 1.0)


func _process(_delta: float) -> void:
	if not is_instance_valid(interaction_label) or not interaction_label.visible:
		return

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return

	var direction := player.global_position - interaction_label.global_position
	direction.y = 0.0

	if direction.length() < 0.01:
		return

	direction = direction.normalized()
	interaction_label.global_rotation.y = atan2(direction.x, direction.z)


func show_interaction_prompt() -> void:
	if _is_transitioning:
		return

	_update_prompt_text()
	if is_instance_valid(interaction_label):
		interaction_label.visible = true


func hide_interaction_prompt() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false


func unlock_door() -> void:
	door_unlocked = true
	print("Door unlocked: ", name)
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null:
		gm.record_door_unlocked(cur_lvl, name)

	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr != null:
		audio_mgr.play_lock_unlock_sfx()

	_update_prompt_text()
	if is_instance_valid(player) and is_instance_valid(interaction_label):
		interaction_label.visible = true


func interact() -> void:
	# Guard: Prevent repeat triggers, double activation, or opening while locked
	if _is_transitioning:
		return

	if not door_unlocked:
		print("Door is locked: ", name)
		var audio_mgr = get_node_or_null("/root/AudioManager")
		if audio_mgr != null:
			audio_mgr.play_interact_sfx()
		var ui_mgr = get_node_or_null("/root/UIManager")
		if ui_mgr != null:
			ui_mgr.notify_warning("The way is locked. Solve the chamber puzzle first.")
		return

	if target_scene.is_empty():
		print("ERROR: Target scene is not assigned on door: ", name)
		return

	if target_spawn_id.is_empty():
		print("ERROR: Target spawn ID is not assigned on door: ", name)
		return

	_is_transitioning = true
	hide_interaction_prompt()

	# Audio feedback
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr != null:
		audio_mgr.play_door_sfx()

	# Handle visual door open animation if physical door leaf exists
	if is_instance_valid(_door_leaf) and not is_open:
		is_open = true

		# Disable solid collision so player can pass through smoothly
		if is_instance_valid(_solid_body):
			for child in _solid_body.get_children():
				if child is CollisionShape3D:
					child.set_deferred("disabled", true)

		# Procedural swing animation around the hinge
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(_door_leaf, "rotation_degrees:y", open_angle_degrees, open_duration)
		await tween.finished
		# Pause briefly after door swing completes so player clearly witnesses the open door
		await get_tree().create_timer(0.25).timeout
		_execute_scene_transition()
	else:
		# For archways or portal gateways without physical swing doors:
		# Play a portal pulse animation on PortalLight and delay so the player experiences the portal opening
		if is_instance_valid(_portal_light):
			var orig_energy: float = _portal_light.light_energy
			var tween := create_tween()
			tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(_portal_light, "light_energy", orig_energy * 2.2, 0.4)
			tween.tween_property(_portal_light, "light_energy", orig_energy, 0.25)
			await tween.finished
		else:
			await get_tree().create_timer(0.6).timeout

		_execute_scene_transition()


func _execute_scene_transition() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.set_spawn_point(target_spawn_id)

	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr != null:
		# Sync level index with UIManager if target is known
		for i in range(ui_mgr.levels.size()):
			var lvl_path = ui_mgr.levels[i]
			if lvl_path == target_scene or (target_scene.begins_with("uid://") and ResourceUID.id_to_text(ResourceLoader.get_resource_uid(lvl_path)) == target_scene):
				ui_mgr.current_level_index = i + 1
				ui_mgr.current_level_path = lvl_path
				break

	get_tree().change_scene_to_file(target_scene)


func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
