extends Control

## Settings Menu — Cinematic Adventure style with fade transitions

@onready var master_volume_slider: HSlider = $CenterContainer/VBoxContainer/SettingsPanel/MarginContainer/VBoxContainer/AudioSection/MasterVolumeSlider
@onready var fullscreen_check: CheckButton = $CenterContainer/VBoxContainer/SettingsPanel/MarginContainer/VBoxContainer/DisplaySection/FullscreenCheck
@onready var sensitivity_slider: HSlider = $CenterContainer/VBoxContainer/SettingsPanel/MarginContainer/VBoxContainer/GameplaySection/SensitivitySlider
@onready var back_btn: Button = $CenterContainer/VBoxContainer/ButtonsContainer/BackButton
@onready var apply_btn: Button = $CenterContainer/VBoxContainer/ButtonsContainer/ApplyButton
@onready var fade_rect: ColorRect = $FadeRect

var return_scene: String = "res://Scenes/UI/MainMenu.tscn"


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	back_btn.pressed.connect(_on_back)
	apply_btn.pressed.connect(_on_apply)

	# Load current settings from UIManager
	fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	master_volume_slider.value = UIManager.master_volume
	sensitivity_slider.value = UIManager.get_sensitivity_percent()

	# Cinematic fade in
	fade_rect.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.5) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	back_btn.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back()
		get_viewport().set_input_as_handled()


func _on_apply() -> void:
	UIManager.update_settings(
		master_volume_slider.value,
		sensitivity_slider.value,
		fullscreen_check.button_pressed
	)


func _on_back() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.3) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(return_scene)
	)
