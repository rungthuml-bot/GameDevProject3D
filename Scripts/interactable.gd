extends Area3D


@export_category("Interaction")

@export var interaction_text: String = "Check"

@export var interaction_title: String = "Wooden Crate"

@export_multiline var description: String = "It is a Wooden Crate Don't you see that?"


@onready var interaction_label: Label3D = $InteractionLabel


func _ready() -> void:

	add_to_group("interactable")

	interaction_label.text = "[E] " + interaction_text

	interaction_label.visible = false


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
