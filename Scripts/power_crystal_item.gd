extends Area3D

## PowerCrystalItem — Collectible energy crystal item in Level 7.
## Integrates cleanly with the existing interaction system.

@export var crystal_id: String = "crystal_azure"
@export var crystal_name: String = "Azure Power Crystal"
@export_multiline var crystal_lore: String = "A pure prismatic crystal shard humming with harmonic energy."

@onready var interaction_label: Label3D = $InteractionLabel
@onready var crystal_mesh: Node3D = get_node_or_null("MeshInstance3D")
@onready var glow_light: OmniLight3D = get_node_or_null("GlowLight")

var player: Node3D = null
var _collected: bool = false

func _ready() -> void:
	add_to_group("interactable")
	if interaction_label:
		interaction_label.text = "[E] Collect " + crystal_name
		interaction_label.visible = false
	player = get_tree().get_first_node_in_group("player")

	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null and gm.is_item_collected_saved(cur_lvl, crystal_id):
		_collected = true
		if crystal_mesh:
			crystal_mesh.visible = false
		if glow_light:
			glow_light.visible = false

func _process(_delta: float) -> void:
	if player == null or interaction_label == null:
		return
	var direction := player.global_position - interaction_label.global_position
	direction.y = 0.0
	if direction.length() > 0.01:
		interaction_label.global_rotation.y = atan2(direction.x, direction.z)

func show_interaction_prompt() -> void:
	if not _collected and interaction_label:
		interaction_label.visible = true

func hide_interaction_prompt() -> void:
	if interaction_label:
		interaction_label.visible = false

func interact() -> void:
	if _collected:
		var ui_mgr = get_node_or_null("/root/UIManager")
		if ui_mgr:
			ui_mgr.notify_info("%s has already been collected." % crystal_name)
		return
	
	_collected = true
	if interaction_label:
		interaction_label.visible = false
	if crystal_mesh:
		crystal_mesh.visible = false
	if glow_light:
		glow_light.visible = false
	
	var mgr = get_tree().get_first_node_in_group("crystal_cavern_manager")
	if mgr != null:
		mgr.collect_crystal(crystal_id, crystal_name)
	
	var ui = get_tree().get_first_node_in_group("interaction_ui")
	if ui != null:
		ui.show_message("Power Crystal — " + crystal_name, crystal_lore, self)

func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
