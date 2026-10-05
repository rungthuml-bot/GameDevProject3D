extends Control

## Settings Menu — Cinematic Dark Fantasy Dungeon style
## Matches visual identity and interaction mechanics of Credits and MainMenu.

const MARKER_COLOR := Color(0.78, 0.62, 0.36, 1.0)   # muted gold
const MARKER_WIDTH := 18.0
const TEXT_INDENT_REST := 28.0
const TEXT_INDENT_SELECTED := 38.0
const SELECT_TIME := 0.18

@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var sensitivity_value: Label = %SensitivityValue
@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var volume_value: Label = %VolumeValue
@onready var fullscreen_toggle: Button = %FullscreenToggle
@onready var apply_btn: Button = %ApplyButton
@onready var back_btn: Button = %BackButton
@onready var fade_rect: ColorRect = $FadeRect

var return_scene: String = "res://Scenes/UI/MainMenu.tscn"
var _buttons: Array[Button] = []
var _markers: Dictionary = {}      # Button -> ColorRect
var _styles: Dictionary = {}       # Button -> StyleBoxEmpty
var _tweens: Dictionary = {}       # Button -> Tween
var _transitioning: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_buttons = [apply_btn, back_btn]
	for btn in _buttons:
		_setup_menu_button(btn)

	apply_btn.pressed.connect(_on_apply)
	back_btn.pressed.connect(_on_back)

	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	master_volume_slider.value_changed.connect(_on_volume_changed)

	# Load current settings from UIManager and DisplayServer
	var mode := DisplayServer.window_get_mode()
	var is_fs := (mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if fullscreen_toggle.has_method("set_toggle_state"):
		fullscreen_toggle.set_toggle_state(is_fs)
	else:
		fullscreen_toggle.button_pressed = is_fs

	master_volume_slider.value = UIManager.master_volume
	sensitivity_slider.value = UIManager.get_sensitivity_percent()

	_update_readouts()

	# Cinematic fade-in from black
	fade_rect.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.4) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)


func _setup_menu_button(btn: Button) -> void:
	# Per-button style copy so the text indent can slide independently
	var style := StyleBoxEmpty.new()
	style.content_margin_left = TEXT_INDENT_REST
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	for state in ["normal", "hover", "pressed", "focus", "hover_pressed", "disabled"]:
		btn.add_theme_stylebox_override(state, style)
	_styles[btn] = style

	# Small gold marker line on the left side
	var marker := ColorRect.new()
	marker.name = "Marker"
	marker.color = MARKER_COLOR
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.anchor_top = 0.5
	marker.anchor_bottom = 0.5
	marker.offset_left = 2.0
	marker.offset_right = 2.0
	marker.offset_top = -1.0
	marker.offset_bottom = 1.0
	marker.modulate.a = 0.0
	btn.add_child(marker)
	_markers[btn] = marker

	# Mouse hover selects (same state as keyboard focus)
	btn.mouse_entered.connect(func() -> void:
		if not _transitioning:
			btn.grab_focus()
	)
	btn.mouse_exited.connect(func() -> void:
		if not _transitioning:
			btn.release_focus()
	)
	btn.focus_entered.connect(_set_selected.bind(btn, true))
	btn.focus_exited.connect(_set_selected.bind(btn, false))


func _set_selected(btn: Button, selected: bool) -> void:
	if _tweens.has(btn) and _tweens[btn].is_valid():
		_tweens[btn].kill()

	var marker: ColorRect = _markers[btn]
	var style: StyleBoxEmpty = _styles[btn]
	var tween := create_tween().set_parallel(true) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	if selected:
		tween.tween_property(marker, "offset_right", 2.0 + MARKER_WIDTH, SELECT_TIME)
		tween.tween_property(marker, "modulate:a", 1.0, SELECT_TIME)
		tween.tween_property(style, "content_margin_left", TEXT_INDENT_SELECTED, SELECT_TIME)
	else:
		tween.tween_property(marker, "offset_right", 2.0, SELECT_TIME)
		tween.tween_property(marker, "modulate:a", 0.0, SELECT_TIME)
		tween.tween_property(style, "content_margin_left", TEXT_INDENT_REST, SELECT_TIME)

	_tweens[btn] = tween


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning:
		return

	if event.is_action_pressed("ui_cancel"):
		_on_back()
		get_viewport().set_input_as_handled()


func _on_sensitivity_changed(val: float) -> void:
	sensitivity_value.text = "%d%%" % int(val)


func _on_volume_changed(val: float) -> void:
	volume_value.text = "%d%%" % int(val)


func _update_readouts() -> void:
	sensitivity_value.text = "%d%%" % int(sensitivity_slider.value)
	volume_value.text = "%d%%" % int(master_volume_slider.value)


func _on_apply() -> void:
	if _transitioning:
		return

	# Update persistent settings via UIManager
	UIManager.update_settings(
		master_volume_slider.value,
		sensitivity_slider.value,
		fullscreen_toggle.button_pressed
	)

	# Elegant visual feedback on Apply button
	apply_btn.text = "APPLIED"
	var prev_mod: Color = apply_btn.modulate
	apply_btn.modulate = Color(1.3, 1.15, 0.85, 1.0)

	var tween := create_tween()
	tween.tween_property(apply_btn, "modulate", prev_mod, 0.7) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		if is_instance_valid(apply_btn):
			apply_btn.text = "APPLY"
	)


func _on_back() -> void:
	if _transitioning:
		return
	_transitioning = true

	# Save any pending settings changes
	UIManager.update_settings(
		master_volume_slider.value,
		sensitivity_slider.value,
		fullscreen_toggle.button_pressed
	)

	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.3) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		if return_scene == "res://Scenes/UI/MainMenu.tscn":
			UIManager.go_to_main_menu()
		else:
			get_tree().change_scene_to_file(return_scene)
	)
