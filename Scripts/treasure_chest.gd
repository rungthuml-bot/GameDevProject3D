class_name TreasureChest
extends Area3D

## TreasureChest — Reusable, stateful interactive treasure chest system.
## Supports:
## 1. KayKit chests ('chest.gltf', 'chest_gold.gltf') via procedural lid rotation (X-axis).
## 2. PSX Dungeon Kit chests ('chest_wood_model.glb', 'chest_wood.tscn') via embedded AnimationPlayer ("open").
## 3. Persistent state (remains open once opened, no repeat triggers, spam-safe).
## 4. Audio-visual feedback: sfx, ambient glow/particles, floating prompt, and UI toast notification.

signal chest_opened(chest_node: TreasureChest)

enum ChestModelType {
	AUTO_DETECT,
	KAYKIT_CHEST,
	KAYKIT_GOLD_CHEST,
	PSX_CHEST
}

@export_category("Chest Settings")
@export var chest_title: String = "Treasure Chest"
@export var chest_contents_desc: String = "You unlocked the chest! Inside lies ancient dungeon treasure."
@export var is_golden: bool = false
@export var model_type: ChestModelType = ChestModelType.AUTO_DETECT
@export var open_rotation_degrees: float = -75.0
@export var open_duration: float = 0.65

@export_category("Audio & Effects")
@export var play_open_sound: bool = true
@export var show_treasure_glow: bool = true
@export var reward_notification: String = "Opened Treasure Chest!"

var is_open: bool = false
var _is_animating: bool = false

# Internal node references
var _lid_node: Node3D = null
var _anim_player: AnimationPlayer = null
var _glow_light: OmniLight3D = null
var _interaction_label: Label3D = null
var _player: Node3D = null

var lid_node: Node3D:
	get: return _lid_node

var anim_player: AnimationPlayer:
	get: return _anim_player


func _ready() -> void:
	add_to_group("interactable")
	add_to_group("treasure_chests")

	_setup_interaction_label()
	_setup_glow_light()
	_detect_and_configure_model()

	_player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	if not is_instance_valid(_interaction_label) or not _interaction_label.visible:
		return

	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
		if not is_instance_valid(_player):
			return

	# Billboarding: Rotate interaction label horizontally to face player
	var dir := _player.global_position - _interaction_label.global_position
	dir.y = 0.0
	if dir.length() >= 0.01:
		dir = dir.normalized()
		_interaction_label.global_rotation.y = atan2(dir.x, dir.z)


func _setup_interaction_label() -> void:
	# Reuse existing or create clean Label3D
	_interaction_label = get_node_or_null("InteractionLabel")
	if _interaction_label == null:
		_interaction_label = Label3D.new()
		_interaction_label.name = "InteractionLabel"
		_interaction_label.position = Vector3(0, 1.15, 0)
		_interaction_label.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		_interaction_label.font_size = 20
		_interaction_label.modulate = Color(0.95, 0.85, 0.55, 1.0)
		_interaction_label.outline_modulate = Color(0.08, 0.06, 0.04, 0.9)
		_interaction_label.outline_size = 4
		add_child(_interaction_label)

	_update_prompt_text()
	_interaction_label.visible = false


func _setup_glow_light() -> void:
	_glow_light = get_node_or_null("TreasureGlow")
	if _glow_light == null:
		_glow_light = OmniLight3D.new()
		_glow_light.name = "TreasureGlow"
		_glow_light.position = Vector3(0, 0.5, 0)
		_glow_light.light_energy = 0.0
		_glow_light.omni_range = 3.5
		_glow_light.light_color = Color(1.0, 0.85, 0.35, 1.0) if is_golden else Color(0.5, 0.85, 1.0, 1.0)
		add_child(_glow_light)


func _detect_and_configure_model() -> void:
	# 1. Search for embedded AnimationPlayer (PSX Chests)
	_anim_player = _find_child_by_type(self, "AnimationPlayer")

	# 2. Search for KayKit lid nodes
	var lid_candidates = ["chest_gold_lid", "chest_lid", "chest_wood_lid"]
	for candidate in lid_candidates:
		var found = _find_child_by_name(self, candidate)
		if found != null and found is Node3D:
			_lid_node = found
			if candidate == "chest_gold_lid":
				is_golden = true
			break


func _update_prompt_text() -> void:
	if not is_instance_valid(_interaction_label):
		return
	if is_open:
		_interaction_label.text = "[Opened]"
		_interaction_label.modulate = Color(0.65, 0.65, 0.65, 0.7)
	else:
		_interaction_label.text = "[E] Open %s" % chest_title
		_interaction_label.modulate = Color(1.0, 0.88, 0.45, 1.0) if is_golden else Color(0.92, 0.9, 0.85, 1.0)


# =========================================================
# INTERACTION SYSTEM INTEGRATION
# =========================================================

func show_interaction_prompt() -> void:
	if is_open:
		return
	if is_instance_valid(_interaction_label):
		_interaction_label.visible = true


func hide_interaction_prompt() -> void:
	if is_instance_valid(_interaction_label):
		_interaction_label.visible = false


func interact() -> void:
	# Debounce / Guard: If already open or currently animating, ignore spam completely!
	if is_open or _is_animating:
		return

	open_chest()


func open_chest() -> void:
	if is_open or _is_animating:
		return

	is_open = true
	_is_animating = true

	# Hide prompt immediately to prevent user confusion
	hide_interaction_prompt()

	# 1. Audio Feedback
	if play_open_sound:
		if has_node("/root/AudioManager"):
			AudioManager.play_chest_open_sfx()

	# 2. UI Notification Feedback (Spam-safe via centralized UIManager debounce)
	if has_node("/root/UIManager"):
		if not reward_notification.is_empty():
			if is_golden:
				UIManager.notify_success(reward_notification, 3.5)
			else:
				UIManager.notify_info(reward_notification, 3.0)

	# 3. Animation Execution
	if _anim_player != null and _anim_player.has_animation("open"):
		# PSX AnimationPlayer path
		_anim_player.play("open")
		_anim_player.animation_finished.connect(func(_anim_name):
			_is_animating = false
			chest_opened.emit(self)
		, CONNECT_ONE_SHOT)
	elif is_instance_valid(_lid_node):
		# KayKit procedural rotation path (Rotate around X axis at the hinge)
		print("[TreasureChest] Starting tween on lid_node: ", _lid_node.name, " target: ", open_rotation_degrees)
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(
			_lid_node,
			"rotation_degrees:x",
			open_rotation_degrees,
			open_duration
		)
		tween.tween_callback(func():
			_is_animating = false
			print("[TreasureChest] Tween completed! New rot x: ", _lid_node.rotation_degrees.x)
			chest_opened.emit(self)
		)
	else:
		_is_animating = false
		chest_opened.emit(self)

	# 4. Visual Glow Feedback
	if show_treasure_glow and is_instance_valid(_glow_light):
		var glow_tween := create_tween()
		glow_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		var target_energy := 2.2 if is_golden else 1.4
		glow_tween.tween_property(_glow_light, "light_energy", target_energy, 0.45)


# =========================================================
# HELPER RECURSIVE SEARCHES
# =========================================================

func _find_child_by_name(parent: Node, target_name: String) -> Node:
	for child in parent.get_children():
		if child.name.to_lower() == target_name.to_lower():
			return child
		var res = _find_child_by_name(child, target_name)
		if res != null:
			return res
	return null


func _find_child_by_type(parent: Node, type_str: String) -> Node:
	for child in parent.get_children():
		if child.is_class(type_str):
			return child
		var res = _find_child_by_type(child, type_str)
		if res != null:
			return res
	return null


func _exit_tree() -> void:
	if is_instance_valid(_interaction_label):
		_interaction_label.visible = false
