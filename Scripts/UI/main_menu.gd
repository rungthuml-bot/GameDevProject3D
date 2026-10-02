extends Control

## Main Menu — Left-aligned Cinematic Adventure layout
## Paths updated for left-aligned menu structure

@onready var play_btn: Button = $ContentMargin/HBoxContainer/MenuContent/ButtonsContainer/PlayButton
@onready var settings_btn: Button = $ContentMargin/HBoxContainer/MenuContent/ButtonsContainer/SettingsButton
@onready var credits_btn: Button = $ContentMargin/HBoxContainer/MenuContent/ButtonsContainer/CreditsButton
@onready var quit_btn: Button = $ContentMargin/HBoxContainer/MenuContent/ButtonsContainer/QuitButton
@onready var fade_rect: ColorRect = $FadeRect


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	play_btn.pressed.connect(_on_play)
	settings_btn.pressed.connect(_on_settings)
	credits_btn.pressed.connect(_on_credits)
	quit_btn.pressed.connect(_on_quit)

	# Cinematic fade in
	fade_rect.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 1.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	play_btn.grab_focus()


func _on_play() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		UIManager.start_game()
	)


func _on_settings() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.3) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://Scenes/UI/SettingsMenu.tscn")
	)


func _on_credits() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.3) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://Scenes/UI/Credits.tscn")
	)


func _on_quit() -> void:
	UIManager.quit_game()
