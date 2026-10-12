extends Node3D

## EndingCutscene — Cinematic ending sequence for DUNGEON MYSTERY MAZE
## Self-contained scene that plays a 15-20 second cinematic then shows
## the Game Complete screen. Designed as a standalone system.
##
## INTEGRATION POINT:
##   Call UIManager.trigger_ending_cutscene() from wherever the win condition
##   is detected (e.g. door.gd, gameplay system, etc.), OR
##   directly change scene to res://Scenes/UI/EndingCutscene.tscn
##
## Layout of nodes expected in the parent scene (injected at runtime):
##   - Player node with AnimationPlayer and CharacterBody3D
##   - An exit door position (uses ExitMarker3D in this scene if no real door)

# =========================================================
# CONSTANTS
# =========================================================

const MARKER_COLOR := Color(0.78, 0.62, 0.36, 1.0)
const MARKER_WIDTH := 18.0
const TEXT_INDENT_REST := 28.0
const TEXT_INDENT_SELECTED := 38.0
const SELECT_TIME := 0.18

# Cutscene timing (seconds)
const TIME_CAMERA_PAN       := 3.0   # Camera pans toward exit
const TIME_PLAYER_WALK      := 5.0   # Player walks to door
const TIME_DOOR_OPEN_DELAY  := 1.0   # Brief pause before door "opens"
const TIME_PLAYER_EXIT      := 3.5   # Player walks through door
const TIME_CAMERA_FOLLOW    := 2.0   # Camera tilts/follows player out
const TIME_FADE_TO_BLACK    := 1.5   # Fade to black
const TIME_TEXT_ESCAPED     := 2.5   # "You escaped..." shown
const TIME_TEXT_COMPLETE     := 2.0   # "GAME COMPLETE" shown

# =========================================================
# NODE REFERENCES (3D Scene)
# =========================================================

@onready var cinematic_camera: Camera3D = $CinematicCamera
@onready var exit_marker: Marker3D = $ExitMarker3D
@onready var camera_start_marker: Marker3D = $CameraPath/CameraStart
@onready var camera_mid_marker: Marker3D = $CameraPath/CameraMid
@onready var camera_end_marker: Marker3D = $CameraPath/CameraEnd

# =========================================================
# NODE REFERENCES (UI Layer)
# =========================================================

@onready var ui_layer: CanvasLayer = $UILayer
@onready var fade_rect: ColorRect = $UILayer/FadeRect
@onready var skip_hint: Label = $UILayer/SkipHint
@onready var game_complete_screen: Control = $UILayer/GameCompleteScreen
@onready var escaped_label: Label = $UILayer/GameCompleteScreen/CenterContainer/VBoxContainer/EscapedLabel
@onready var complete_label: Label = $UILayer/GameCompleteScreen/CenterContainer/VBoxContainer/CompleteLabel
@onready var divider_rect: ColorRect = $UILayer/GameCompleteScreen/CenterContainer/VBoxContainer/DividerRect
@onready var menu_btn: Button = $UILayer/GameCompleteScreen/CenterContainer/VBoxContainer/ButtonsContainer/MainMenuButton

# =========================================================
# STATE
# =========================================================

var _player_node: Node3D = null
var _player_anim: AnimationPlayer = null
var _is_skipped: bool = false
var _cutscene_done: bool = false
var _btn_style: StyleBoxEmpty = null
var _btn_marker: ColorRect = null
var _btn_tween: Tween = null


# =========================================================
# READY
# =========================================================

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Hide UI elements initially
	fade_rect.modulate.a = 1.0
	game_complete_screen.visible = false
	skip_hint.modulate.a = 0.0
	escaped_label.modulate.a = 0.0
	complete_label.modulate.a = 0.0
	divider_rect.modulate.a = 0.0

	# Setup main menu button with gold marker style
	_setup_menu_button(menu_btn)
	menu_btn.pressed.connect(_on_main_menu)

	# Find the player in the current scene tree (injected from level)
	_find_player()

	# Activate cinematic camera
	cinematic_camera.current = true

	# Start the cutscene sequence
	call_deferred("_start_cutscene")


func _find_player() -> void:
	# Try to find the player from the parent scene
	_player_node = get_tree().get_first_node_in_group("player")
	if _player_node:
		_player_anim = _player_node.get_node_or_null("Eric/AnimationPlayer")
		if _player_anim == null:
			# Fallback search
			for child in _player_node.get_children():
				_player_anim = child.get_node_or_null("AnimationPlayer")
				if _player_anim:
					break


# =========================================================
# INPUT — SKIP
# =========================================================

func _unhandled_input(event: InputEvent) -> void:
	if _cutscene_done:
		return
	if event.is_action_pressed("ui_cancel"):
		_skip_cutscene()
		get_viewport().set_input_as_handled()


func _skip_cutscene() -> void:
	if _is_skipped:
		return
	_is_skipped = true

	# Kill all running tweens, jump to end state
	get_tree().get_root().propagate_notification(Node.NOTIFICATION_PAUSED)

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.3) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		get_tree().get_root().propagate_notification(Node.NOTIFICATION_UNPAUSED)
		_show_game_complete_screen()
	)


# =========================================================
# CUTSCENE SEQUENCE
# =========================================================

func _start_cutscene() -> void:
	# Position cinematic camera at start
	cinematic_camera.global_transform = camera_start_marker.global_transform

	# Disable player control during cutscene
	if _player_node:
		_player_node.set_process(false)
		_player_node.set_physics_process(false)
		_player_node.set_process_unhandled_input(false)

	# Show skip hint + fade in world
	var intro_tween := create_tween()
	intro_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	intro_tween.tween_property(fade_rect, "modulate:a", 0.0, 1.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	intro_tween.tween_property(skip_hint, "modulate:a", 0.6, 0.5)
	intro_tween.tween_callback(_phase_camera_pan)


func _phase_camera_pan() -> void:
	if _is_skipped:
		return
	# Pan camera from start → mid position, looking toward exit
	var pan_tween := create_tween()
	pan_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	pan_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	pan_tween.tween_method(_lerp_camera_start_to_mid, 0.0, 1.0, TIME_CAMERA_PAN)
	pan_tween.tween_callback(_phase_player_walk)


func _lerp_camera_start_to_mid(t: float) -> void:
	cinematic_camera.global_position = camera_start_marker.global_position.lerp(
		camera_mid_marker.global_position, t
	)
	# Look toward exit marker
	var look_target := exit_marker.global_position + Vector3(0, 1.0, 0)
	cinematic_camera.look_at(look_target, Vector3.UP)


func _phase_player_walk() -> void:
	if _is_skipped:
		return

	# Play walk animation if available
	if _player_anim:
		if _player_anim.has_animation("CharacterArmature|Walk"):
			_player_anim.play("CharacterArmature|Walk")

	# Move player toward exit using tween (simple position lerp — avoids touching player.gd)
	if _player_node:
		var start_pos := _player_node.global_position
		var target_pos := exit_marker.global_position

		# Face player toward exit
		var dir := (target_pos - start_pos)
		dir.y = 0.0
		if dir.length() > 0.01:
			_player_node.global_rotation.y = atan2(-dir.x, -dir.z)

		var walk_tween := create_tween()
		walk_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		walk_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		walk_tween.tween_method(
			func(t: float): _player_node.global_position = start_pos.lerp(target_pos, t),
			0.0, 1.0, TIME_PLAYER_WALK
		)
		walk_tween.tween_callback(_phase_player_exit)
	else:
		# No player found — skip walk phase
		await get_tree().create_timer(TIME_PLAYER_WALK).timeout
		_phase_player_exit()


func _phase_player_exit() -> void:
	if _is_skipped:
		return

	await get_tree().create_timer(TIME_DOOR_OPEN_DELAY).timeout
	if _is_skipped:
		return

	# Camera follows toward end marker
	var follow_tween := create_tween()
	follow_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	follow_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	follow_tween.tween_method(_lerp_camera_mid_to_end, 0.0, 1.0, TIME_CAMERA_FOLLOW)

	# Move player further through the door
	if _player_node:
		var exit_through := exit_marker.global_position + \
			(-cinematic_camera.global_transform.basis.z.normalized() * 4.0)
		exit_through.y = _player_node.global_position.y
		var start_pos := _player_node.global_position

		var exit_tween := create_tween()
		exit_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		exit_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		exit_tween.tween_method(
			func(t: float): _player_node.global_position = start_pos.lerp(exit_through, t),
			0.0, 1.0, TIME_PLAYER_EXIT
		)

	await follow_tween.finished
	if _is_skipped:
		return

	# Fade to idle
	if _player_anim:
		if _player_anim.has_animation("CharacterArmature|Idle"):
			_player_anim.play("CharacterArmature|Idle")

	await get_tree().create_timer(0.4).timeout
	if _is_skipped:
		return

	_phase_fade_to_black()


func _lerp_camera_mid_to_end(t: float) -> void:
	cinematic_camera.global_position = camera_mid_marker.global_position.lerp(
		camera_end_marker.global_position, t
	)
	if _player_node:
		var look_target := _player_node.global_position + Vector3(0, 1.0, 0)
		cinematic_camera.look_at(look_target, Vector3.UP)
	else:
		cinematic_camera.look_at(exit_marker.global_position + Vector3(0, 1.0, 0), Vector3.UP)


func _phase_fade_to_black() -> void:
	if _is_skipped:
		return
	# Hide skip hint
	var hint_tween := create_tween()
	hint_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	hint_tween.tween_property(skip_hint, "modulate:a", 0.0, 0.4)

	# Fade to black
	var fade_tween := create_tween()
	fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_tween.tween_property(fade_rect, "modulate:a", 1.0, TIME_FADE_TO_BLACK) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	fade_tween.tween_callback(_show_game_complete_screen)


# =========================================================
# GAME COMPLETE SCREEN
# =========================================================

func _show_game_complete_screen() -> void:
	_cutscene_done = true
	UIManager.current_state = UIManager.GameState.WIN

	game_complete_screen.visible = true

	# "You escaped..." fades in
	var seq := create_tween()
	seq.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	seq.tween_interval(0.8)
	seq.tween_property(escaped_label, "modulate:a", 1.0, TIME_TEXT_ESCAPED) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	seq.tween_interval(0.4)
	seq.tween_property(divider_rect, "modulate:a", 1.0, 0.6) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	seq.tween_interval(0.3)
	seq.tween_property(complete_label, "modulate:a", 1.0, TIME_TEXT_COMPLETE) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	# Fade in button
	seq.tween_interval(0.5)
	seq.tween_property(menu_btn, "modulate:a", 1.0, 0.6) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	seq.tween_callback(func(): menu_btn.grab_focus())


func _on_main_menu() -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.4) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		UIManager.go_to_main_menu()
	)


# =========================================================
# MENU BUTTON — GOLD MARKER STYLE (matches Credits/MainMenu)
# =========================================================

func _setup_menu_button(btn: Button) -> void:
	btn.modulate.a = 0.0  # hidden until fade-in sequence
	_btn_style = StyleBoxEmpty.new()
	_btn_style.content_margin_left = TEXT_INDENT_REST
	_btn_style.content_margin_top = 10.0
	_btn_style.content_margin_bottom = 10.0
	for state in ["normal", "hover", "pressed", "focus", "hover_pressed", "disabled"]:
		btn.add_theme_stylebox_override(state, _btn_style)

	_btn_marker = ColorRect.new()
	_btn_marker.name = "Marker"
	_btn_marker.color = MARKER_COLOR
	_btn_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_btn_marker.anchor_top = 0.5
	_btn_marker.anchor_bottom = 0.5
	_btn_marker.offset_left = 2.0
	_btn_marker.offset_right = 2.0
	_btn_marker.offset_top = -1.0
	_btn_marker.offset_bottom = 1.0
	_btn_marker.modulate.a = 0.0
	btn.add_child(_btn_marker)

	btn.mouse_entered.connect(func() -> void: btn.grab_focus())
	btn.mouse_exited.connect(func() -> void: btn.release_focus())
	btn.focus_entered.connect(_set_btn_selected.bind(true))
	btn.focus_exited.connect(_set_btn_selected.bind(false))


func _set_btn_selected(selected: bool) -> void:
	if _btn_tween and _btn_tween.is_valid():
		_btn_tween.kill()

	_btn_tween = create_tween().set_parallel(true) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_btn_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	if selected:
		_btn_tween.tween_property(_btn_marker, "offset_right", 2.0 + MARKER_WIDTH, SELECT_TIME)
		_btn_tween.tween_property(_btn_marker, "modulate:a", 1.0, SELECT_TIME)
		_btn_tween.tween_property(_btn_style, "content_margin_left", TEXT_INDENT_SELECTED, SELECT_TIME)
	else:
		_btn_tween.tween_property(_btn_marker, "offset_right", 2.0, SELECT_TIME)
		_btn_tween.tween_property(_btn_marker, "modulate:a", 0.0, SELECT_TIME)
		_btn_tween.tween_property(_btn_style, "content_margin_left", TEXT_INDENT_REST, SELECT_TIME)
