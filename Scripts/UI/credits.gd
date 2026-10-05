extends Control

## Credits screen — Cinematic Adventure style
## Displays team member credits with clean typography and smooth transitions.

const MARKER_COLOR := Color(0.78, 0.62, 0.36, 1.0)   # muted gold
const MARKER_WIDTH := 18.0
const TEXT_INDENT_REST := 28.0
const TEXT_INDENT_SELECTED := 38.0
const SELECT_TIME := 0.18

@onready var back_btn: Button = %BackButton
@onready var fade_rect: ColorRect = $FadeRect

var _marker: ColorRect
var _style: StyleBoxEmpty
var _tween: Tween
var _transitioning: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	back_btn.pressed.connect(_on_back)
	_setup_back_button()

	# Cinematic fade in
	fade_rect.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.6) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)


func _setup_back_button() -> void:
	_style = StyleBoxEmpty.new()
	_style.content_margin_left = TEXT_INDENT_REST
	_style.content_margin_top = 8.0
	_style.content_margin_bottom = 8.0
	for state in ["normal", "hover", "pressed", "focus", "hover_pressed", "disabled"]:
		back_btn.add_theme_stylebox_override(state, _style)

	_marker = ColorRect.new()
	_marker.name = "Marker"
	_marker.color = MARKER_COLOR
	_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_marker.anchor_top = 0.5
	_marker.anchor_bottom = 0.5
	_marker.offset_left = 2.0
	_marker.offset_right = 2.0
	_marker.offset_top = -1.0
	_marker.offset_bottom = 1.0
	_marker.modulate.a = 0.0
	back_btn.add_child(_marker)

	back_btn.mouse_entered.connect(func() -> void:
		if not _transitioning:
			back_btn.grab_focus()
	)
	back_btn.mouse_exited.connect(func() -> void:
		if not _transitioning:
			back_btn.release_focus()
	)
	back_btn.focus_entered.connect(_set_selected.bind(true))
	back_btn.focus_exited.connect(_set_selected.bind(false))


func _set_selected(selected: bool) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween().set_parallel(true) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	if selected:
		tween_selected()
	else:
		tween_unselected()


func tween_selected() -> void:
	_tween.tween_property(_marker, "offset_right", 2.0 + MARKER_WIDTH, SELECT_TIME)
	_tween.tween_property(_marker, "modulate:a", 1.0, SELECT_TIME)
	_tween.tween_property(_style, "content_margin_left", TEXT_INDENT_SELECTED, SELECT_TIME)


func tween_unselected() -> void:
	_tween.tween_property(_marker, "offset_right", 2.0, SELECT_TIME)
	_tween.tween_property(_marker, "modulate:a", 0.0, SELECT_TIME)
	_tween.tween_property(_style, "content_margin_left", TEXT_INDENT_REST, SELECT_TIME)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back()
		get_viewport().set_input_as_handled()


func _on_back() -> void:
	if _transitioning:
		return
	_transitioning = true

	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.3) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		UIManager.go_to_main_menu()
	)
