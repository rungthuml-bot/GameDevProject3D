extends Control

## Main Menu — Cinematic 3D Adventure layout
## The 3D game world (MenuBackdrop) is the background; menu sits on the left.
## Text-based navigation: hover / keyboard focus share one "selected" state.

const MARKER_COLOR := Color(0.78, 0.62, 0.36, 1.0)   # muted gold
const MARKER_WIDTH := 18.0
const TEXT_INDENT_REST := 28.0
const TEXT_INDENT_SELECTED := 38.0
const SELECT_TIME := 0.18

@onready var play_btn: Button = %PlayButton
@onready var settings_btn: Button = %SettingsButton
@onready var credits_btn: Button = %CreditsButton
@onready var quit_btn: Button = %QuitButton
@onready var menu_content: VBoxContainer = %MenuContent
@onready var title_block: VBoxContainer = %TitleBlock
@onready var buttons_container: VBoxContainer = %ButtonsContainer
@onready var fade_rect: ColorRect = $FadeRect

var _buttons: Array[Button] = []
var _markers: Dictionary = {}      # Button -> ColorRect
var _styles: Dictionary = {}       # Button -> StyleBoxEmpty (per-button copy)
var _tweens: Dictionary = {}       # Button -> Tween
var _transitioning: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	play_btn.pressed.connect(_on_play)
	settings_btn.pressed.connect(_on_settings)
	credits_btn.pressed.connect(_on_credits)
	quit_btn.pressed.connect(_on_quit)

	_buttons = [play_btn, settings_btn, credits_btn, quit_btn]
	for btn in _buttons:
		_setup_menu_button(btn)

	_play_intro()
	play_btn.grab_focus()


# =========================================================
# MENU BUTTON VISUALS
# =========================================================

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


# =========================================================
# INTRO (Cinematic fade in: world first, then title, then menu)
# =========================================================

func _play_intro() -> void:
	fade_rect.modulate.a = 1.0
	title_block.modulate.a = 0.0
	buttons_container.modulate.a = 0.0

	var tween := create_tween().set_parallel(true)
	# 1) Reveal the 3D world
	tween.tween_property(fade_rect, "modulate:a", 0.0, 1.6) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	# 2) Title fades in
	tween.tween_property(title_block, "modulate:a", 1.0, 0.9) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_delay(0.9)
	# 3) Menu items fade in
	tween.tween_property(buttons_container, "modulate:a", 1.0, 0.7) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_delay(1.4)


# =========================================================
# ACTIONS
# =========================================================

func _fade_out(duration: float, callback: Callable) -> void:
	if _transitioning:
		return
	_transitioning = true
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(callback)


func _on_play() -> void:
	_fade_out(0.6, func():
		UIManager.start_game()
	)


func _on_settings() -> void:
	_fade_out(0.3, func():
		get_tree().change_scene_to_file("res://Scenes/UI/SettingsMenu.tscn")
	)


func _on_credits() -> void:
	_fade_out(0.3, func():
		get_tree().change_scene_to_file("res://Scenes/UI/Credits.tscn")
	)


func _on_quit() -> void:
	_fade_out(0.4, func():
		UIManager.quit_game()
	)
