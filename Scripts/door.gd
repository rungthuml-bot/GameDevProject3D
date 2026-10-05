extends Area3D

@export_category("Interaction")
@export var interaction_text: String = "Enter"
@export var interaction_title: String = "Ancient Door"
@export_multiline var description: String = "Enter the next area."

@export_category("Level Transition")
@export_file("*.tscn") var target_scene: String
@export var target_spawn_id: String = ""

@export_category("Puzzle Requirement")
@export var require_puzzle: bool = false

@onready var interaction_label: Label3D = $InteractionLabel

var player: Node3D = null
var door_unlocked: bool = false


func _ready() -> void:
	add_to_group("interactable")

	interaction_label.text = "[E] " + interaction_text
	interaction_label.visible = false

	player = get_tree().get_first_node_in_group("player")

	if not require_puzzle:
		door_unlocked = true


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
	if not door_unlocked:
		return

	interaction_label.visible = true


func hide_interaction_prompt() -> void:
	interaction_label.visible = false


func unlock_door() -> void:
	door_unlocked = true
	print("Door unlocked!")

	if player != null:
		interaction_label.visible = true


func interact() -> void:
	if not door_unlocked:
		print("Door is locked!")
		return

	if target_scene.is_empty():
		print("ERROR: Target scene is not assigned!")
		return

	if target_spawn_id.is_empty():
		print("ERROR: Target spawn ID is not assigned!")
		return

	GameManager.set_spawn_point(target_spawn_id)

	# Sync level index with UIManager if target is known
	for i in range(UIManager.levels.size()):
		var lvl_path = UIManager.levels[i]
		if lvl_path == target_scene or (target_scene.begins_with("uid://") and ResourceUID.id_to_text(ResourceLoader.get_resource_uid(lvl_path)) == target_scene):
			UIManager.current_level_index = i + 1
			UIManager.current_level_path = lvl_path
			break

	get_tree().change_scene_to_file(target_scene)


func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false

