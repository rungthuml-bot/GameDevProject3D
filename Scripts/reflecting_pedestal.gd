extends Area3D

## ReflectingPedestal — Rotatable crystal reflector pedestal in Level 7.
## Pressing [E] rotates the pedestal by 90 degrees with audio-visual feedback.

@export var is_west_pedestal: bool = true
@export var pedestal_name: String = "West Reflecting Pedestal"

@onready var interaction_label: Label3D = $InteractionLabel
@onready var pivot_node: Node3D = get_node_or_null("Pivot")
@onready var pedestal_light: OmniLight3D = get_node_or_null("PedestalLight")

var player: Node3D = null
var current_state: int = 0  # 0: North, 1: East (target for West), 2: South, 3: West (target for East)
var _is_rotating: bool = false

func _ready() -> void:
	add_to_group("interactable")
	if interaction_label:
		interaction_label.text = "[E] Rotate " + pedestal_name
		interaction_label.visible = false
	player = get_tree().get_first_node_in_group("player")
	
	var gm = get_node_or_null("/root/GameManager")
	var cur_lvl = ""
	if get_tree().current_scene:
		cur_lvl = get_tree().current_scene.scene_file_path
	if gm != null:
		var key = "pedestal_west_state" if is_west_pedestal else "pedestal_east_state"
		current_state = gm.get_level_mechanism_state(cur_lvl, key, 0)

	# Initial orientation sync
	if pivot_node:
		pivot_node.rotation_degrees.y = current_state * 90.0

func _process(_delta: float) -> void:
	if player == null or interaction_label == null:
		return
	var direction := player.global_position - interaction_label.global_position
	direction.y = 0.0
	if direction.length() > 0.01:
		interaction_label.global_rotation.y = atan2(direction.x, direction.z)

func show_interaction_prompt() -> void:
	if not _is_rotating and interaction_label:
		interaction_label.visible = true

func hide_interaction_prompt() -> void:
	if interaction_label:
		interaction_label.visible = false

func interact() -> void:
	var mgr = get_tree().get_first_node_in_group("crystal_cavern_manager")
	if mgr == null:
		return
	
	var audio_mgr = get_node_or_null("/root/AudioManager")
	var ui_mgr = get_node_or_null("/root/UIManager")
	
	if not mgr.core_is_activated:
		if ui_mgr:
			ui_mgr.notify_warning("The crystal mirror is unpowered. Awaken the Pinnacle Crystal Core first.")
		if audio_mgr:
			audio_mgr.play_interact_sfx()
		return
	
	if mgr.beam_puzzle_completed:
		if ui_mgr:
			ui_mgr.notify_info("%s is locked in harmonic resonance." % pedestal_name)
		return
	
	if _is_rotating:
		return
	_is_rotating = true
	
	current_state = (current_state + 1) % 4
	var target_deg = current_state * 90.0
	
	if audio_mgr:
		audio_mgr.play_button_sfx()
	
	if pivot_node and is_inside_tree():
		var tw = create_tween()
		tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(pivot_node, "rotation_degrees:y", target_deg, 0.45)
		await tw.finished
	
	_is_rotating = false
	mgr.update_pedestal_orientation(is_west_pedestal, current_state)
	
	# Direction names
	var dirs = ["North", "East (Towards Core)", "South", "West (Towards Core)"]
	var ui = get_node_or_null("/root/UIManager")
	if ui:
		ui.notify_info("%s turned facing %s." % [pedestal_name, dirs[current_state]])

func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
