extends Area3D

## ThroneRitualAltar — One of three ceremonial altars in Level 8: Forgotten Throne.
## When attuned, channels energy into the Sovereign Seal.

@export var altar_index: int = 0
@export var altar_name: String = "Altar of the First King"
@export_multiline var altar_lore: String = "An ancient ceremonial altar pulsing with dormant sovereign warding."

@onready var interaction_label: Label3D = $InteractionLabel
@onready var altar_light: OmniLight3D = get_node_or_null("AltarLight")
@onready var gem_mesh: Node3D = get_node_or_null("GemMesh")

var player: Node3D = null
var _activated: bool = false

func _ready() -> void:
	add_to_group("interactable")
	if interaction_label:
		interaction_label.text = "[E] Awaken " + altar_name
		interaction_label.visible = false
	player = get_tree().get_first_node_in_group("player")
	
	if altar_light:
		altar_light.light_energy = 0.4
		altar_light.light_color = Color(1.0, 0.7, 0.2, 1.0)
	
	# Restore saved state from GameManager
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null and gm.is_pillar_attuned_saved(cur_lvl, altar_index):
		_set_activated_visuals()

func _process(_delta: float) -> void:
	if player == null or interaction_label == null:
		return
	var direction := player.global_position - interaction_label.global_position
	direction.y = 0.0
	if direction.length() > 0.01:
		interaction_label.global_rotation.y = atan2(direction.x, direction.z)

func show_interaction_prompt() -> void:
	if not _activated and interaction_label:
		interaction_label.visible = true

func hide_interaction_prompt() -> void:
	if interaction_label:
		interaction_label.visible = false

func interact() -> void:
	var mgr = get_tree().get_first_node_in_group("throne_chamber_manager")
	if mgr == null:
		return
	
	if _activated:
		var ui_mgr = get_node_or_null("/root/UIManager")
		if ui_mgr:
			ui_mgr.notify_info("%s is already blazing with eternal authority." % altar_name)
		return
	
	var success = mgr.activate_ritual_altar(altar_index, altar_name)
	if success:
		_set_activated_visuals()
		var ui = get_tree().get_first_node_in_group("interaction_ui")
		if ui != null:
			ui.show_message("Ritual Altar Awakened", altar_lore, self)

func _set_activated_visuals() -> void:
	_activated = true
	if interaction_label:
		interaction_label.visible = false
	if altar_light:
		altar_light.light_energy = 3.5
		altar_light.light_color = Color(1.0, 0.85, 0.35, 1.0)
	if gem_mesh and is_inside_tree():
		var tw = create_tween()
		if tw:
			tw.tween_property(gem_mesh, "position:y", gem_mesh.position.y + 0.35, 0.5)

func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
