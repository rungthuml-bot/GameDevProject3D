extends Area3D

## FinalDoor — A door that triggers the Ending Cutscene instead of a level transition.
## Requires the player to possess and return the Sovereign Relic before opening.

@export_category("Interaction")
@export var interaction_text: String = "Escape"
@export var interaction_title: String = "Sanctuary Gate"
@export_multiline var description_sealed_no_relic: String = "The Sanctuary Gate is sealed by ancient wards. You must delve into the depths and retrieve the Sovereign Relic to break the seal."
@export_multiline var description_sealed_has_relic: String = "You carry the Sovereign Relic, but the ancient enchantment remains active. Place the relic upon the Altar of the Sovereign to unlock the gate."
@export_multiline var description_unlocked: String = "The Sanctuary Gate stands open, bathed in the warmth of the surface world. Step through to complete your journey."

@onready var interaction_label: Label3D = $InteractionLabel

var player: Node3D = null
var _ending_triggered: bool = false


func _ready() -> void:
	add_to_group("interactable")
	interaction_label.visible = false
	player = get_tree().get_first_node_in_group("player")
	_update_label()


func _process(_delta: float) -> void:
	if player == null:
		return

	var direction := player.global_position - interaction_label.global_position
	direction.y = 0.0

	if direction.length() < 0.01:
		return

	direction = direction.normalized()
	interaction_label.global_rotation.y = atan2(direction.x, direction.z)


func _update_label() -> void:
	if GameManager:
		if GameManager.relic_returned:
			interaction_label.text = "[E] " + interaction_text
		elif GameManager.has_relic:
			interaction_label.text = "[E] Sealed (Return Relic)"
		else:
			interaction_label.text = "[E] Sealed Gate"
	else:
		interaction_label.text = "[E] " + interaction_text


func show_interaction_prompt() -> void:
	_update_label()
	interaction_label.visible = true


func hide_interaction_prompt() -> void:
	interaction_label.visible = false


func interact() -> void:
	# Check completion conditions
	if GameManager:
		if not GameManager.has_relic:
			if is_inside_tree() and has_node("/root/AudioManager"):
				AudioManager.play_interact_sfx()
			if is_inside_tree() and has_node("/root/UIManager"):
				UIManager.notify_warning("The Sanctuary Gate is sealed! Retrieve the Sovereign Relic first.")
			_show_message(interaction_title, description_sealed_no_relic)
			return

		if not GameManager.relic_returned:
			if is_inside_tree() and has_node("/root/AudioManager"):
				AudioManager.play_interact_sfx()
			if is_inside_tree() and has_node("/root/UIManager"):
				UIManager.notify_info("Place the Sovereign Relic upon the Altar to unseal the gate.")
			_show_message(interaction_title, description_sealed_has_relic)
			return

	# Conditions met: Relic is collected and returned!
	if _ending_triggered:
		return
	_ending_triggered = true

	if is_inside_tree() and has_node("/root/AudioManager"):
		AudioManager.play_door_sfx()

	# Trigger ending cutscene via UIManager
	if UIManager:
		UIManager.trigger_ending_cutscene()


func _show_message(msg_title: String, msg_desc: String) -> void:
	if not is_inside_tree() or get_tree() == null:
		return
	var interaction_ui = get_tree().get_first_node_in_group("interaction_ui")
	if interaction_ui != null:
		interaction_ui.show_message(msg_title, msg_desc, self)


func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
