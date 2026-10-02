extends Control

## Credits Screen — Cinematic Adventure style with fade transitions

@onready var back_btn: Button = $CenterContainer/VBoxContainer/BackButton
@onready var fade_rect: ColorRect = $FadeRect


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	back_btn.pressed.connect(_on_back)

	# Cinematic fade in
	fade_rect.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.8) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	back_btn.grab_focus()


func _on_back() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
	)
