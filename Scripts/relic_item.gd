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

@onready var interaction_label: Label3D = $InteractionLabel

var player: Node3D = null
var _relic_mesh: Node3D = null


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
	if GameManager and GameManager.has_relic:
		if is_instance_valid(_relic_mesh):
			_relic_mesh.visible = false
		interaction_label.text = "[E] Inspect Dais"
	else:
		if is_instance_valid(_relic_mesh):
			_relic_mesh.visible = true
		interaction_label.text = "[E] " + interaction_text


func show_interaction_prompt() -> void:
	_update_state()
	interaction_label.visible = true


func hide_interaction_prompt() -> void:
	interaction_label.visible = false


func interact() -> void:
	if GameManager and GameManager.has_relic:
		if is_inside_tree() and has_node("/root/AudioManager"):
			AudioManager.play_interact_sfx()
		_show_message(interaction_title, description_taken)
		return

	# First time pickup
	if GameManager:
		GameManager.set_relic_acquired(true)

	if is_instance_valid(_relic_mesh):
		_relic_mesh.visible = false

	_update_state()

	if is_inside_tree() and has_node("/root/AudioManager"):
		AudioManager.play_lock_unlock_sfx()

	if is_inside_tree() and has_node("/root/UIManager"):
		UIManager.notify_success("Obtained the Sovereign Relic!")

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
