extends Control

## Settings Menu — Cinematic Dark Fantasy Dungeon style
## Full Configuration Suite:
## 1. Audio: Master, Music, SFX, Ambient volume sliders with real-time bus attenuation
## 2. Graphics: Display Mode (Fullscreen/Windowed/Borderless), VSync, Shadow Quality
## 3. Controls: Mouse Sensitivity, Invert Y-Axis, Key Binding Display (WASD, Jump, Interact, Inventory, Hold)
## 4. Gameplay & Accessibility: Subtitles, Dialogue Text Size
## Actions: Apply, Reset to Defaults, Back. Fully persists to user://settings.cfg.

const MARKER_COLOR := Color(0.78, 0.62, 0.36, 1.0)
const MARKER_WIDTH := 18.0
const TEXT_INDENT_REST := 28.0
const TEXT_INDENT_SELECTED := 38.0
const SELECT_TIME := 0.18

# Audio Controls
@onready var master_slider: HSlider = %MasterVolumeSlider
@onready var master_val: Label = %MasterVolumeValue
@onready var music_slider: HSlider = %MusicVolumeSlider
@onready var music_val: Label = %MusicVolumeValue
@onready var sfx_slider: HSlider = %SfxVolumeSlider
@onready var sfx_val: Label = %SfxVolumeValue
@onready var ambient_slider: HSlider = %AmbientVolumeSlider
@onready var ambient_val: Label = %AmbientVolumeValue

# Graphics Controls
@onready var window_mode_btn: OptionButton = %WindowModeOption
@onready var vsync_toggle: Button = %VsyncToggle
@onready var shadow_opt_btn: OptionButton = %ShadowOption

# Controls Tab
@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var sensitivity_val: Label = %SensitivityValue
@onready var invert_y_toggle: Button = %InvertYToggle

# Gameplay & Accessibility
@onready var subtitles_toggle: Button = %SubtitlesToggle
@onready var text_size_opt: OptionButton = %TextSizeOption
@onready var language_opt: OptionButton = %LanguageOption

# Action Buttons
@onready var apply_btn: Button = %ApplyButton
@onready var reset_btn: Button = %ResetButton
@onready var back_btn: Button = %BackButton
@onready var fade_rect: ColorRect = $FadeRect

var return_scene: String = "res://Scenes/UI/MainMenu.tscn"
var _buttons: Array[Button] = []
var _markers: Dictionary = {}
var _styles: Dictionary = {}
var _tweens: Dictionary = {}
var _transitioning: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_buttons = [apply_btn, reset_btn, back_btn]
	for btn in _buttons:
		_setup_menu_button(btn)

	apply_btn.pressed.connect(_on_apply)
	reset_btn.pressed.connect(_on_reset_defaults)
	back_btn.pressed.connect(_on_back)

	# Audio Sliders
	master_slider.value_changed.connect(_on_master_slider_changed)
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	ambient_slider.value_changed.connect(_on_ambient_slider_changed)

	# Controls Sliders
	sensitivity_slider.value_changed.connect(_on_sensitivity_slider_changed)

	# Populate OptionButtons
	_setup_options()

	# Load state from UIManager
	_load_ui_from_manager()

	# Cinematic fade-in
	fade_rect.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.4) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)


func _setup_options() -> void:
	window_mode_btn.clear()
	window_mode_btn.add_item("Fullscreen (เต็มจอ)", 0)
	window_mode_btn.add_item("Windowed (หน้าต่าง)", 1)
	window_mode_btn.add_item("Borderless Window (ไร้ขอบ)", 2)

	shadow_opt_btn.clear()
	shadow_opt_btn.add_item("Low Shadows (ต่ำ)", 0)
	shadow_opt_btn.add_item("Medium Shadows (ปานกลาง)", 1)
	shadow_opt_btn.add_item("High Shadows (สูง)", 2)

	text_size_opt.clear()
	text_size_opt.add_item("Normal (ปกติ - 16px)", 0)
	text_size_opt.add_item("Large (ขนาดใหญ่ - 20px)", 1)

	if is_instance_valid(language_opt):
		language_opt.clear()
		language_opt.add_item("🇹🇭 ภาษาไทย (Thai)", 0)
		language_opt.add_item("🇺🇸 English", 1)


func _load_ui_from_manager() -> void:
	if not UIManager:
		return

	# Audio
	master_slider.value = UIManager.master_volume
	music_slider.value = UIManager.music_volume
	sfx_slider.value = UIManager.sfx_volume
	ambient_slider.value = UIManager.ambient_volume
	_update_audio_readouts()

	# Graphics
	window_mode_btn.select(UIManager.window_mode_index)
	_set_toggle_button(vsync_toggle, UIManager.vsync_enabled)
	shadow_opt_btn.select(UIManager.shadow_quality_index)

	# Controls
	sensitivity_slider.value = UIManager.get_sensitivity_percent()
	_update_sensitivity_readout()
	_set_toggle_button(invert_y_toggle, UIManager.invert_y)

	# Gameplay
	_set_toggle_button(subtitles_toggle, UIManager.subtitles_enabled)
	text_size_opt.select(UIManager.text_size_index)
	if is_instance_valid(language_opt):
		language_opt.select(0 if UIManager.current_language == "th" else 1)


func _set_toggle_button(btn: Button, is_on: bool) -> void:
	if btn.has_method("set_toggle_state"):
		btn.set_toggle_state(is_on)
	else:
		btn.button_pressed = is_on


func _is_toggle_on(btn: Button) -> bool:
	return btn.button_pressed


func _on_master_slider_changed(val: float) -> void:
	master_val.text = "%d%%" % int(val)
	if UIManager:
		UIManager._apply_bus_volume("Master", val)


func _on_music_slider_changed(val: float) -> void:
	music_val.text = "%d%%" % int(val)
	if UIManager:
		UIManager._apply_bus_volume("Music", val)


func _on_sfx_slider_changed(val: float) -> void:
	sfx_val.text = "%d%%" % int(val)
	if UIManager:
		UIManager._apply_bus_volume("SFX", val)


func _on_ambient_slider_changed(val: float) -> void:
	ambient_val.text = "%d%%" % int(val)
	if UIManager:
		UIManager._apply_bus_volume("Ambient", val)


func _on_sensitivity_slider_changed(val: float) -> void:
	sensitivity_val.text = "%d%%" % int(val)


func _update_audio_readouts() -> void:
	master_val.text = "%d%%" % int(master_slider.value)
	music_val.text = "%d%%" % int(music_slider.value)
	sfx_val.text = "%d%%" % int(sfx_slider.value)
	ambient_val.text = "%d%%" % int(ambient_slider.value)


func _update_sensitivity_readout() -> void:
	sensitivity_val.text = "%d%%" % int(sensitivity_slider.value)


func _setup_menu_button(btn: Button) -> void:
	var style := StyleBoxEmpty.new()
	style.content_margin_left = TEXT_INDENT_REST
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	for state in ["normal", "hover", "pressed", "focus", "hover_pressed", "disabled"]:
		btn.add_theme_stylebox_override(state, style)
	_styles[btn] = style

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

	btn.mouse_entered.connect(func() -> void:
		if has_node("/root/AudioManager"):
			AudioManager.play_ui_hover()
		if not _transitioning:
			btn.grab_focus()
	)
	btn.mouse_exited.connect(func() -> void:
		if not _transitioning:
			btn.release_focus()
	)
	btn.focus_entered.connect(func() -> void:
		if has_node("/root/AudioManager"):
			AudioManager.play_ui_hover()
		_set_selected(btn, true)
	)
	btn.focus_exited.connect(_set_selected.bind(btn, false))
	btn.pressed.connect(func() -> void:
		if has_node("/root/AudioManager"):
			AudioManager.play_ui_click()
	)


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


func _on_apply() -> void:
	if _transitioning or not UIManager:
		return

	# Write values to UIManager
	UIManager.master_volume = master_slider.value
	UIManager.music_volume = music_slider.value
	UIManager.sfx_volume = sfx_slider.value
	UIManager.ambient_volume = ambient_slider.value

	UIManager.window_mode_index = window_mode_btn.selected
	UIManager.is_fullscreen = (UIManager.window_mode_index == 0 or UIManager.window_mode_index == 2)
	UIManager.vsync_enabled = _is_toggle_on(vsync_toggle)
	UIManager.shadow_quality_index = shadow_opt_btn.selected

	UIManager.mouse_sensitivity = remap(sensitivity_slider.value, 0.0, 100.0, 0.0005, 0.006)
	UIManager.invert_y = _is_toggle_on(invert_y_toggle)

	UIManager.subtitles_enabled = _is_toggle_on(subtitles_toggle)
	UIManager.text_size_index = text_size_opt.selected
	if is_instance_valid(language_opt):
		var lang := "th" if language_opt.selected == 0 else "en"
		UIManager.set_language(lang)

	# Apply across all systems and persist
	UIManager.apply_all_settings()
	UIManager.save_settings_to_config()

	# Visual Feedback
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


func _on_reset_defaults() -> void:
	if not UIManager:
		return
	UIManager.reset_settings_to_defaults()
	_load_ui_from_manager()

	# Feedback
	reset_btn.text = "RESETTED"
	var prev_mod: Color = reset_btn.modulate
	reset_btn.modulate = Color(1.3, 1.15, 0.85, 1.0)
	var tween := create_tween()
	tween.tween_property(reset_btn, "modulate", prev_mod, 0.7) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		if is_instance_valid(reset_btn):
			reset_btn.text = "DEFAULTS"
	)


func _on_back() -> void:
	if _transitioning:
		return
	_transitioning = true

	# Auto-save changes on back
	_on_apply()

	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.3) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		if return_scene == "res://Scenes/UI/MainMenu.tscn":
			UIManager.go_to_main_menu()
		else:
			get_tree().change_scene_to_file(return_scene)
	)
