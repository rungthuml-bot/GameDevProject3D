extends Area3D

## RelicAltar — Sanctuary Altar in Level 1 where the player returns the Sovereign Relic.
## Once returned, GameManager.relic_returned is set to true, unlocking the FinalDoor.

@export_category("Interaction")
@export var interaction_text: String = "Place Relic"
@export var interaction_title: String = "Altar of the Sovereign"
@export_multiline var description_empty: String = "An ancient stone altar standing before the Sanctuary Gate. A carved hollow in the centre awaits the return of the Sovereign Relic."
@export_multiline var description_returned: String = "The Sovereign Relic rests serenely upon the altar, radiating sacred light. The Sanctuary Gate seal has been broken!"

@onready var interaction_label: Label3D = $InteractionLabel

var player: Node3D = null
var relic_visual: Node3D = null


func _ready() -> void:
	add_to_group("interactable")
	interaction_label.visible = false
	player = get_tree().get_first_node_in_group("player")
	relic_visual = get_node_or_null("RelicVisual")
	_update_state()


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
	if GameManager and GameManager.relic_returned:
		if is_instance_valid(relic_visual):
			relic_visual.visible = true
		interaction_label.text = "[E] Inspect Altar"
	else:
		if is_instance_valid(relic_visual):
			relic_visual.visible = false
		if GameManager and GameManager.has_relic:
			interaction_label.text = "[E] Place Relic"
		else:
			interaction_label.text = "[E] Inspect Altar"


func show_interaction_prompt() -> void:
	_update_state()
	interaction_label.visible = true


func hide_interaction_prompt() -> void:
	interaction_label.visible = false


func interact() -> void:
	if not GameManager:
		return

	if not GameManager.has_relic:
		# Player doesn't have relic yet
		if is_inside_tree() and has_node("/root/AudioManager"):
			AudioManager.play_interact_sfx()
		if is_inside_tree() and has_node("/root/UIManager"):
			UIManager.notify_warning("You do not possess the Sovereign Relic yet.")
		_show_message(interaction_title, description_empty)
		return

	if GameManager.relic_returned:
		# Already returned
		if is_inside_tree() and has_node("/root/AudioManager"):
			AudioManager.play_interact_sfx()
		_show_message(interaction_title, description_returned)
		return

	# Player has relic and returns it now!
	GameManager.relic_returned = true
	_update_state()

	if is_inside_tree() and has_node("/root/AudioManager"):
		AudioManager.play_lock_unlock_sfx()

	if is_inside_tree() and has_node("/root/UIManager"):
		UIManager.notify_success("Sovereign Relic returned! Sanctuary Gate is unsealed.")

	_show_message(interaction_title, "You gently rest the Sovereign Relic upon the stone dais. Radiant golden light bursts across the sanctuary, dissolving the ancient seal on the Sanctuary Gate!")


func _show_message(msg_title: String, msg_desc: String) -> void:
	if not is_inside_tree() or get_tree() == null:
		return
	var interaction_ui = get_tree().get_first_node_in_group("interaction_ui")
	if interaction_ui != null:
		interaction_ui.show_message(msg_title, msg_desc, self)


func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
