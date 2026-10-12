extends Area3D

## RelicItem — Interaction handler for the Sovereign Relic in Level 8.
## Integrates with existing interactable system. Sets GameManager.has_relic = true.

@export_category("Interaction")
@export var interaction_text: String = "Take Relic"
@export var interaction_title: String = "The Sovereign Relic"
@export_multiline var description_pickup: String = "You lift the Sovereign Scepter from its velvet dais! An ancient warmth pulses through your hands. Bring it back to the surface sanctuary in Level 1!"
@export_multiline var description_taken: String = "The dais is empty. You already possess the Sovereign Relic."

@export_category("Visual Target")
@export var target_prop_path: NodePath = ^"../KayKitDungeon/Props/GoldenRelicChest"
@export var target_shield_path: NodePath = ^"../KayKitDungeon/Props/RelicGoldShield"

@onready var interaction_label: Label3D = $InteractionLabel

var player: Node3D = null
var _relic_mesh: Node3D = null
var _shield_mesh: Node3D = null


func _ready() -> void:
	add_to_group("interactable")
	interaction_label.visible = false
	player = get_tree().get_first_node_in_group("player")

	_resolve_target_prop()
	_update_state()


func _resolve_target_prop() -> void:
	if has_node(target_prop_path):
		_relic_mesh = get_node(target_prop_path)
	elif get_parent():
		_relic_mesh = get_parent().get_node_or_null("KayKitDungeon/Props/GoldenRelicChest")

	if has_node(target_shield_path):
		_shield_mesh = get_node(target_shield_path)
	elif get_parent():
		_shield_mesh = get_parent().get_node_or_null("KayKitDungeon/Props/RelicGoldShield")


func _process(_delta: float) -> void:
	if player == null:
		return

	var direction := player.global_position - interaction_label.global_position
	direction.y = 0.0

	if direction.length() < 0.01:
		return

	direction = direction.normalized()
	interaction_label.global_rotation.y = atan2(direction.x, direction.z)


func _update_state() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_relic:
		if is_instance_valid(_relic_mesh):
			_relic_mesh.visible = false
		if is_instance_valid(_shield_mesh):
			_shield_mesh.visible = false
		interaction_label.text = "[E] Inspect Dais"
	else:
		if is_instance_valid(_relic_mesh):
			_relic_mesh.visible = true
		if is_instance_valid(_shield_mesh):
			_shield_mesh.visible = true
		interaction_label.text = "[E] " + interaction_text


func show_interaction_prompt() -> void:
	_update_state()
	interaction_label.visible = true


func hide_interaction_prompt() -> void:
	interaction_label.visible = false


func interact() -> void:
	var gm = get_node_or_null("/root/GameManager")
	var am = get_node_or_null("/root/AudioManager")
	var ui = get_node_or_null("/root/UIManager")

	if gm and gm.has_relic:
		if am:
			am.play_interact_sfx()
		_show_message(interaction_title, description_taken)
		return

	# Puzzle Guard: Must solve the Sovereign Seal puzzle first!
	var mgr = get_tree().get_first_node_in_group("throne_chamber_manager")
	if mgr != null and not mgr.seal_puzzle_solved:
		if am:
			am.play_interact_sfx()
		if ui:
			ui.notify_warning("The Golden Chest is sealed by the Sovereign Ward. Solve the Sovereign Seal first!")
		_show_message(interaction_title, "The Golden Chest is locked tight by an ancient glowing seal. Commune with the Sovereign Seal in front of the throne to solve its cipher.")
		return

	# First time pickup
	if gm:
		gm.set_relic_acquired(true)

	if is_instance_valid(_relic_mesh):
		_relic_mesh.visible = false

	_update_state()

	if am:
		am.play_lock_unlock_sfx()

	if ui:
		ui.notify_success("Obtained the Sovereign Relic!")

	_show_message(interaction_title, description_pickup)


func _show_message(msg_title: String, msg_desc: String) -> void:
	if not is_inside_tree() or get_tree() == null:
		return
	var interaction_ui = get_tree().get_first_node_in_group("interaction_ui")
	if interaction_ui != null:
		interaction_ui.show_message(msg_title, msg_desc, self)


func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
