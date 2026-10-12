extends Area3D

@export_category("Interaction")
@export var interaction_text: String = "Press"
@export var interaction_title: String = "Blue Button"
@export_multiline var description: String = "Press the blue button."

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

	interaction_label.global_rotation.y = atan2(
		direction.x,
		direction.z
	)


func show_interaction_prompt() -> void:
	interaction_label.visible = true


func hide_interaction_prompt() -> void:
	interaction_label.visible = false


func interact() -> void:
	print("Blue Button Pressed!")

	var puzzle_manager = get_parent().get_node_or_null("PuzzleManager")

	if puzzle_manager == null:
		print("ERROR: PuzzleManager not found!")
		return

	puzzle_manager.press_blue()


func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
