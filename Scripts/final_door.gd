extends Area3D

## FinalDoor — A door that triggers the Ending Cutscene instead of a level transition.
## Requires the player to possess and return the Sovereign Relic before opening.
## Plays a smooth opening swing animation from the door hinge before cutting to the Ending Cutscene.

@export_category("Interaction")
@export var interaction_text: String = "Escape"
@export_multiline var description_sealed_no_relic: String = "The Sanctuary Gate is sealed by ancient wards. You must delve into the depths and retrieve the Sovereign Relic to break the seal."
@export_multiline var description_sealed_has_relic: String = "You carry the Sovereign Relic, but the ancient enchantment remains active. Place the relic upon the Altar of the Sovereign to unlock the gate."
@export_multiline var description_unlocked: String = "The Sanctuary Gate stands open, bathed in the warmth of the surface world. Step through to complete your journey."

@export_category("Door Animation")
@export var open_angle_degrees: float = 90.0
@export var open_duration: float = 0.9

@onready var interaction_label: Label3D = $InteractionLabel

var player: Node3D = null
var _ending_triggered: bool = false
var _door_leaf: Node3D = null
var _solid_body: StaticBody3D = null
var _hinge_node: Node3D = null


func _ready() -> void:
	add_to_group("interactable")
	add_to_group("doors")

	_setup_door_components()

	if is_instance_valid(interaction_label):
		interaction_label.visible = false

	player = get_tree().get_first_node_in_group("player")
	_update_label()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _setup_door_components() -> void:
	var existing_hinge: Node3D = find_child("Hinge", true, false)
	if existing_hinge != null:
		_hinge_node = existing_hinge
		_door_leaf = existing_hinge
	else:
		# Detect visual door mesh and handle
		var door_mesh: Node3D = find_child("Door", true, false)
		var handle_mesh: Node3D = find_child("DoorHandle", true, false)

		if door_mesh != null:
			var parent_node: Node = door_mesh.get_parent()
			if parent_node != null and is_inside_tree():
				var hinge := Node3D.new()
				hinge.name = "Hinge"
				# In Door by Quaternius, hinge pivot is on the positive X edge at (0.658, 0, 0.008)
				hinge.position = Vector3(0.658, 0.0, 0.008)
				parent_node.add_child(hinge)

				door_mesh.reparent(hinge)
				if handle_mesh != null:
					handle_mesh.reparent(hinge)

				_hinge_node = hinge
				_door_leaf = hinge
		else:
			# Fallback candidates
			var candidates = ["door_dungeon_leaf", "door_cell_leaf", "Door_Root", "Model"]
			for candidate in candidates:
				var found = find_child(candidate, true, false)
				if found != null and found is Node3D and found != self:
					_door_leaf = found
					break

	var solid = find_child("StaticBody3D", true, false)
	if solid != null and solid is StaticBody3D:
		_solid_body = solid


func _on_body_entered(body: Node) -> void:
	if _ending_triggered:
		return
	if body.is_in_group("player") or body.name == "Player":
		var gm = get_node_or_null("/root/GameManager")
		if gm != null and gm.relic_returned:
			# Stepping through the unsealed gate triggers the escape!
			interact()
		else:
			show_interaction_prompt()


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") or body.name == "Player":
		hide_interaction_prompt()


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


func _update_label() -> void:
	if not is_instance_valid(interaction_label):
		return

	if _ending_triggered:
		interaction_label.text = "[Escaping...]"
		interaction_label.modulate = Color(0.65, 0.65, 0.65, 0.8)
		return

	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		if gm.relic_returned:
			interaction_label.text = "[E] Escape (Exit Sanctuary)"
			interaction_label.modulate = Color(0.5, 1.0, 0.7, 1.0)
		elif gm.has_relic:
			interaction_label.text = "[E] Sealed (Place Relic on Altar)"
			interaction_label.modulate = Color(1.0, 0.75, 0.35, 1.0)
		else:
			interaction_label.text = "[E] Sealed Sanctuary Gate"
			interaction_label.modulate = Color(0.85, 0.45, 0.45, 1.0)
	else:
		interaction_label.text = "[E] Open Gate (" + interaction_text + ")"


func show_interaction_prompt() -> void:
	if _ending_triggered:
		return
	_update_label()
	if is_instance_valid(interaction_label):
		interaction_label.visible = true


func hide_interaction_prompt() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false


func interact() -> void:
	# Anti-spam guard: prevent any duplicate trigger during sequence
	if _ending_triggered:
		return

	var audio_mgr = get_node_or_null("/root/AudioManager")
	var ui_mgr = get_node_or_null("/root/UIManager")

	# Check completion conditions
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		if not gm.has_relic:
			if audio_mgr != null:
				audio_mgr.play_interact_sfx()
			if ui_mgr != null:
				ui_mgr.notify_warning("The Sanctuary Gate is sealed! Retrieve the Sovereign Relic first.")
			_show_message("Sanctuary Gate", description_sealed_no_relic)
			return

		if not gm.relic_returned:
			if audio_mgr != null:
				audio_mgr.play_interact_sfx()
			if ui_mgr != null:
				ui_mgr.notify_info("Place the Sovereign Relic upon the Altar to unseal the gate.")
			_show_message("Sanctuary Gate", description_sealed_has_relic)
			return

	# Conditions met: Relic is collected and returned!
	_ending_triggered = true
	hide_interaction_prompt()

	if audio_mgr != null:
		audio_mgr.play_door_sfx()

	# Handle visual door open swing animation
	if is_instance_valid(_door_leaf):
		if is_instance_valid(_solid_body):
			for child in _solid_body.get_children():
				if child is CollisionShape3D:
					child.set_deferred("disabled", true)

		var tween := create_tween()
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(_door_leaf, "rotation_degrees:y", open_angle_degrees, open_duration)
		await tween.finished
		# Pause briefly so the player sees the gateway wide open before cutscene starts
		await get_tree().create_timer(0.3).timeout
		_trigger_cutscene()
	else:
		if is_instance_valid(_solid_body):
			for child in _solid_body.get_children():
				if child is CollisionShape3D:
					child.set_deferred("disabled", true)
		await get_tree().create_timer(0.6).timeout
		_trigger_cutscene()


func _trigger_cutscene() -> void:
	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr != null:
		ui_mgr.trigger_ending_cutscene()
	else:
		get_tree().change_scene_to_file("res://Scenes/UI/EndingCutscene.tscn")


func _show_message(msg_title: String, msg_desc: String) -> void:
	if not is_inside_tree() or get_tree() == null:
		return
	var interaction_ui = get_tree().get_first_node_in_group("interaction_ui")
	if interaction_ui != null:
		interaction_ui.show_message(msg_title, msg_desc, self)


func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
