extends Area3D

## SanctuaryPillarPedestal — Attunable pillar around the Great Sanctum Altar in Level 4.
## Activates when interacted with, provided all 3 Glyphs have been discovered.

@export var pillar_index: int = 0
@export var pillar_name: String = "Sanctuary Pillar"

@onready var interaction_label: Label3D = $InteractionLabel
@onready var pillar_light: OmniLight3D = get_node_or_null("PillarLight")

var player: Node3D = null
var _attuned: bool = false

func _ready() -> void:
	add_to_group("interactable")
	if interaction_label:
		interaction_label.text = "[E] Attune " + pillar_name
		interaction_label.visible = false
	player = get_tree().get_first_node_in_group("player")
	if pillar_light:
		pillar_light.light_energy = 0.4
		pillar_light.light_color = Color(0.7, 0.6, 0.3, 1.0)
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null and gm.is_pillar_attuned_saved(cur_lvl, pillar_index):
		_attuned = true
		if pillar_light:
			pillar_light.light_energy = 3.5
			pillar_light.light_color = Color(1.0, 0.88, 0.35, 1.0)

func _process(_delta: float) -> void:
	if player == null or interaction_label == null:
		return
	var direction := player.global_position - interaction_label.global_position
	direction.y = 0.0
	if direction.length() > 0.01:
		interaction_label.global_rotation.y = atan2(direction.x, direction.z)

func show_interaction_prompt() -> void:
	if not _attuned and interaction_label:
		interaction_label.visible = true

func hide_interaction_prompt() -> void:
	if interaction_label:
		interaction_label.visible = false

func interact() -> void:
	var seal_mgr = get_tree().get_first_node_in_group("ancient_seal_manager")
	if seal_mgr == null:
		return
	
	if _attuned:
		if has_node("/root/UIManager"):
			UIManager.notify_info("%s is already glowing with celestial power." % pillar_name)
		return
	
	var success = seal_mgr.attune_pillar(pillar_index)
	if success:
		_attuned = true
		if interaction_label:
			interaction_label.visible = false
		if pillar_light and is_inside_tree():
			var tw = create_tween()
			if tw:
				tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				tw.tween_property(pillar_light, "light_energy", 3.5, 0.6)
				tw.parallel().tween_property(pillar_light, "light_color", Color(1.0, 0.88, 0.35, 1.0), 0.6)

func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
