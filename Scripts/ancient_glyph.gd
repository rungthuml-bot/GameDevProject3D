extends Area3D

## AncientGlyph — Collectible/Interactable secret symbol hidden in Level 4 maze.
## Discovers a rune required for the Ancient Seal.

@export var glyph_id: String = "glyph_sun"
@export var glyph_name: String = "Sun Glyph"
@export_multiline var glyph_lore: String = "An ancient solar crest carved into the stone, pulsing with warm energy."

@onready var interaction_label: Label3D = $InteractionLabel
@onready var glow_light: OmniLight3D = get_node_or_null("GlowLight")

var player: Node3D = null
var _discovered: bool = false

func _ready() -> void:
	add_to_group("interactable")
	if interaction_label:
		interaction_label.text = "[E] Decipher " + glyph_name
		interaction_label.visible = false
	player = get_tree().get_first_node_in_group("player")

	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null and gm.is_item_collected_saved(cur_lvl, glyph_id):
		_discovered = true
		if glow_light:
			glow_light.light_energy = 2.2

func _process(_delta: float) -> void:
	if player == null or interaction_label == null:
		return
	var direction := player.global_position - interaction_label.global_position
	direction.y = 0.0
	if direction.length() > 0.01:
		interaction_label.global_rotation.y = atan2(direction.x, direction.z)

func show_interaction_prompt() -> void:
	if not _discovered and interaction_label:
		interaction_label.visible = true

func hide_interaction_prompt() -> void:
	if interaction_label:
		interaction_label.visible = false

func interact() -> void:
	var seal_mgr = get_tree().get_first_node_in_group("ancient_seal_manager")
	if _discovered:
		if has_node("/root/UIManager"):
			UIManager.notify_info("%s has already been deciphered." % glyph_name)
		return
	
	_discovered = true
	if interaction_label:
		interaction_label.visible = false
	
	if glow_light and is_inside_tree():
		var tw = create_tween()
		if tw:
			tw.tween_property(glow_light, "light_energy", 4.0, 0.3)
			tw.tween_property(glow_light, "light_energy", 2.2, 0.4)
	
	if seal_mgr != null:
		seal_mgr.discover_glyph(glyph_id, glyph_name)
	
	var ui = get_tree().get_first_node_in_group("interaction_ui")
	if ui != null:
		ui.show_message("Ancient Seal — " + glyph_name, glyph_lore, self)

func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
