extends Area3D

## FinalDoor — A door that triggers the Ending Cutscene instead of a level transition.
##
## USAGE:
##   1. Place this scene in level_2.tscn (or whichever is the FINAL level).
##   2. Set interaction_text / interaction_title as you like.
##   3. When the player interacts, UIManager.trigger_ending_cutscene() is called.
##
## NOTE: Do NOT set a target_scene on this door. It routes to the ending cutscene.

@export_category("Interaction")
@export var interaction_text: String = "Escape"
@export var interaction_title: String = "Exit"
@export_multiline var description: String = "Leave the dungeon behind."

@onready var interaction_label: Label3D = $InteractionLabel

var player: Node3D = null


func _ready() -> void:
	add_to_group("interactable")
	interaction_label.text = "[E] " + interaction_text
	interaction_label.visible = false
	player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	if player == null:
		return

	var direction := player.global_position - interaction_label.global_position
	direction.y = 0.0

	if direction.length() < 0.01:
		return

	direction = direction.normalized()
	interaction_label.global_rotation.y = atan2(direction.x, direction.z)


func show_interaction_prompt() -> void:
	interaction_label.visible = true


func hide_interaction_prompt() -> void:
	interaction_label.visible = false


func interact() -> void:
	# Trigger the ending cutscene via UIManager
	UIManager.trigger_ending_cutscene()


func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
