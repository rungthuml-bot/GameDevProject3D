extends Control

## Splash Screen — Cinematic staggered reveal
## Title fades in slowly, then subtitle, then prompt

@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $CenterContainer/VBoxContainer/SubtitleLabel
@onready var prompt_label: Label = $CenterContainer/VBoxContainer/PromptLabel
@onready var fade_rect: ColorRect = $FadeRect

var can_continue: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Start with all labels invisible (background is already dark)
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	prompt_label.modulate.a = 0.0
	fade_rect.modulate.a = 0.0

	# Cinematic staggered reveal
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(title_label, "modulate:a", 1.0, 2.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.6)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 1.5) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(1.0)
	tween.tween_property(prompt_label, "modulate:a", 0.5, 1.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(_enable_input)
	tween.tween_callback(_start_prompt_blink)


func _enable_input() -> void:
	can_continue = true


func _start_prompt_blink() -> void:
	var blink = create_tween().set_loops()
	blink.tween_property(prompt_label, "modulate:a", 0.15, 2.0) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	blink.tween_property(prompt_label, "modulate:a", 0.5, 2.0) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func _unhandled_input(event: InputEvent) -> void:
	if not can_continue:
		return

	if event is InputEventKey or event is InputEventMouseButton:
		if event.pressed:
			_go_to_main_menu()


func _go_to_main_menu() -> void:
	can_continue = false
	var tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 0.0, 0.8) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(subtitle_label, "modulate:a", 0.0, 0.8) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(prompt_label, "modulate:a", 0.0, 0.6) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.3)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
	)
