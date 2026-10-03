@tool
class_name SettingsToggle
extends Button

## SettingsToggle — Custom elegant toggle switch for dark fantasy dungeon UI
## OFF: dark charcoal track + muted handle
## ON: dark warm gold track + light ivory handle
## Fully accessible via Mouse, Keyboard (Space/Enter), and Controller

@export var track_width: float = 46.0
@export var track_height: float = 22.0
@export var handle_radius: float = 7.5

var _handle_pos: float = 0.0 # 0.0 = OFF, 1.0 = ON
var _tween: Tween = null


func _ready() -> void:
	toggle_mode = true
	flat = true
	focus_mode = FOCUS_ALL
	custom_minimum_size = Vector2(track_width, track_height)
	_handle_pos = 1.0 if button_pressed else 0.0
	toggled.connect(_on_toggled)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)


func _on_toggled(is_on: bool) -> void:
	if not is_inside_tree():
		_handle_pos = 1.0 if is_on else 0.0
		queue_redraw()
		return

	if _tween and _tween.is_valid():
		_tween.kill()

	var target := 1.0 if is_on else 0.0
	_tween = create_tween()
	_tween.tween_property(self, "_handle_pos", target, 0.15) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween.tween_callback(queue_redraw)


func _process(_delta: float) -> void:
	if _tween and _tween.is_valid():
		queue_redraw()


func set_toggle_state(is_on: bool) -> void:
	button_pressed = is_on
	_handle_pos = 1.0 if is_on else 0.0
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAW:
		_draw_toggle()


func _draw_toggle() -> void:
	var radius := track_height * 0.5
	var r := Rect2(Vector2.ZERO, Vector2(track_width, track_height))

	# Track Background:
	# OFF: dark charcoal (#131116)
	# ON: dark warm amber (#291E13)
	var bg_off := Color(0.09, 0.08, 0.10, 1.0)
	var bg_on := Color(0.24, 0.17, 0.10, 1.0)
	var bg_color := bg_off.lerp(bg_on, _handle_pos)

	# Border:
	# OFF: muted dark gold (#4A3E2E)
	# ON: antique gold (#C79E5C)
	var border_off := Color(0.42, 0.35, 0.26, 0.75)
	var border_on := Color(0.82, 0.65, 0.38, 0.95)
	var border_color := border_off.lerp(border_on, _handle_pos)

	# Hover / Focus highlight
	if has_focus() or is_hovered():
		border_color = border_color.lightened(0.25)
		bg_color = bg_color.lightened(0.08)

	# Draw track pill
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = border_color
	style.corner_radius_top_left = int(radius)
	style.corner_radius_top_right = int(radius)
	style.corner_radius_bottom_right = int(radius)
	style.corner_radius_bottom_left = int(radius)
	draw_style_box(style, r)

	# Handle circle
	var x_min := radius
	var x_max := track_width - radius
	var h_x := lerpf(x_min, x_max, _handle_pos)
	var h_center := Vector2(h_x, radius)

	# Handle color:
	# OFF: muted warm gray (#635C52)
	# ON: bright warm ivory/cream (#FAF5EA)
	var h_off := Color(0.48, 0.44, 0.38, 1.0)
	var h_on := Color(0.96, 0.93, 0.86, 1.0)
	var h_color := h_off.lerp(h_on, _handle_pos)

	if is_hovered():
		h_color = h_color.lightened(0.12)

	# Draw handle circle
	draw_circle(h_center, handle_radius, h_color)
	draw_arc(h_center, handle_radius, 0, TAU, 24, border_color.lerp(Color(0.2, 0.16, 0.12), 0.3), 1.0)
