extends Control

## Title / Splash Screen — Dark Fantasy Dungeon Mystery atmosphere
## Displays the official title "DUNGEON MYSTERY MAZE" with cinematic staggered reveal.
## When any key or mouse button is pressed, fades out smoothly into Main Menu.

@onready var title_box: VBoxContainer = %TitleBox
@onready var subtitle_label: Label = %SubtitleLabel
@onready var divider: ColorRect = %Divider
@onready var prompt_label: Label = %PromptLabel
@onready var fade_rect: ColorRect = $FadeRect

var can_continue: bool = false
var _transitioning: bool = false
var _intro_tween: Tween = null
var _pulse_tween: Tween = null


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# 0.0s: Screen pitch black
	fade_rect.modulate.a = 1.0
	title_box.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	divider.modulate.a = 0.0
	prompt_label.modulate.a = 0.0

	_play_cinematic_intro()


# =========================================================
# CINEMATIC INTRO TIMELINE
# 0.0s: Screen black
# 0.5s: Background slowly reveals
# 1.0s: "DUNGEON MYSTERY MAZE" fades in (0 -> 100%)
# 1.5s: Subtitle "A JOURNEY INTO THE UNKNOWN" fades in
# 2.0s: Divider & "PRESS ANY KEY TO ENTER" fade in
# After intro: Prompt pulses gently (1.8s cycle)
# =========================================================

func _play_cinematic_intro() -> void:
	_intro_tween = create_tween().set_parallel(true)

	# 0.5s: Background slowly reveals
	_intro_tween.tween_property(fade_rect, "modulate:a", 0.0, 1.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_delay(0.5)

	# 1.0s: Title "DUNGEON MYSTERY MAZE" fades in
	_intro_tween.tween_property(title_box, "modulate:a", 1.0, 1.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_delay(1.0)

	# 1.5s: Subtitle fades in
	_intro_tween.tween_property(subtitle_label, "modulate:a", 1.0, 1.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_delay(1.5)

	# 2.0s: Divider and Prompt fade in
	_intro_tween.tween_property(divider, "modulate:a", 1.0, 0.6) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_delay(2.0)
	_intro_tween.tween_property(prompt_label, "modulate:a", 1.0, 0.6) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_delay(2.0)

	_intro_tween.chain().tween_callback(_on_intro_completed)


func _on_intro_completed() -> void:
	can_continue = true
	_start_prompt_pulse()


func _start_prompt_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()

	# Subtle blinking / pulsing: ~1.8 seconds per complete cycle
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(prompt_label, "modulate:a", 0.32, 0.9) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(prompt_label, "modulate:a", 1.0, 0.9) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


# =========================================================
# INPUT & TRANSITION
# =========================================================

func _gui_input(event: InputEvent) -> void:
	if _transitioning:
		return
	if event is InputEventMouseButton and event.is_pressed():
		_go_to_main_menu()
		accept_event()


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning:
		return

	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.is_pressed() and not event.is_echo():
			_go_to_main_menu()
			get_viewport().set_input_as_handled()


func _go_to_main_menu() -> void:
	if _transitioning:
		return

	_transitioning = true
	can_continue = false

	if _intro_tween and _intro_tween.is_valid():
		_intro_tween.kill()
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()

	# Cinematic 0.6s smooth fade out
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.6) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
	)
