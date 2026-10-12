extends Area3D

@export_category("Interaction")
@export var interaction_text: String = "Inspect"
@export var interaction_title: String = "Ancient Object"
@export_multiline var description: String = "There is nothing unusual about this object."

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

	# Calculate horizontal direction to player
	var direction := player.global_position - interaction_label.global_position
	direction.y = 0.0

	if direction.length() < 0.01:
		return

	direction = direction.normalized()

	# Rotate Label3D to face the player
	interaction_label.global_rotation.y = atan2(
		direction.x,
		direction.z
	)


func show_interaction_prompt() -> void:
	interaction_label.visible = true


func hide_interaction_prompt() -> void:
	interaction_label.visible = false


func interact() -> void:
	var interaction_ui = get_tree().get_first_node_in_group("interaction_ui")

	if interaction_ui == null:
		print("ERROR: InteractionUI not found!")
		return

	interaction_ui.show_message(
		interaction_title,
		description,
		self
	)


func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
