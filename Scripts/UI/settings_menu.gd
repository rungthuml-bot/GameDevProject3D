extends Control

## Settings Menu — Cinematic Dark Fantasy Dungeon style with responsive scaling

@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var sensitivity_value: Label = %SensitivityValue
@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var volume_value: Label = %VolumeValue
@onready var fullscreen_toggle: Button = %FullscreenToggle
@onready var back_btn: Button = %BackButton
@onready var apply_btn: Button = %ApplyButton
@onready var fade_rect: ColorRect = $FadeRect

var return_scene: String = "res://Scenes/UI/MainMenu.tscn"
var _transitioning: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	back_btn.pressed.connect(_on_back)
	apply_btn.pressed.connect(_on_apply)

	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	master_volume_slider.value_changed.connect(_on_volume_changed)

	# Load current values from UIManager and DisplayServer
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

	back_btn.grab_focus()


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

	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.28) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(return_scene)
	)
