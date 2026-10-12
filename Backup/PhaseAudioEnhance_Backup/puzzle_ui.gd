extends CanvasLayer

## Puzzle UI — Temple Mechanism / Dual Pedestal Sequence
## Displays countdown timer, pedestal activation states, and dynamic status matching the game theme.

# =========================================================
# NODE REFERENCES
# =========================================================
@onready var card_panel: PanelContainer = $RootControl/CardPanel
@onready var title_label: Label = $RootControl/CardPanel/Margin/VBox/HeaderRow/TitleLabel
@onready var timer_badge: Label = $RootControl/CardPanel/Margin/VBox/HeaderRow/TimerBadge
@onready var progress_bar: ProgressBar = $RootControl/CardPanel/Margin/VBox/TimeProgressBar
@onready var red_badge: PanelContainer = $RootControl/CardPanel/Margin/VBox/StatusRow/RedBadge
@onready var red_icon: Label = $RootControl/CardPanel/Margin/VBox/StatusRow/RedBadge/Margin/HBox/RedIcon
@onready var red_label: Label = $RootControl/CardPanel/Margin/VBox/StatusRow/RedBadge/Margin/HBox/RedLabel
@onready var blue_badge: PanelContainer = $RootControl/CardPanel/Margin/VBox/StatusRow/BlueBadge
@onready var blue_icon: Label = $RootControl/CardPanel/Margin/VBox/StatusRow/BlueBadge/Margin/HBox/BlueIcon
@onready var blue_label: Label = $RootControl/CardPanel/Margin/VBox/StatusRow/BlueBadge/Margin/HBox/BlueLabel
@onready var message_label: Label = $RootControl/CardPanel/Margin/VBox/MessageLabel

# Backward-compatibility aliases for legacy scripts
var red_status: Label:
	get: return red_label
var blue_status: Label:
	get: return blue_label
var timer_label: Label:
	get: return timer_badge

# =========================================================
# STATE & STYLES
# =========================================================
var _total_time: float = 10.0
var _is_visible: bool = false
var _is_completed: bool = false
var _fade_tween: Tween = null

var _red_waiting_style: StyleBoxFlat
var _red_active_style: StyleBoxFlat
var _blue_waiting_style: StyleBoxFlat
var _blue_active_style: StyleBoxFlat
var _bar_fill_normal: StyleBoxFlat
var _bar_fill_critical: StyleBoxFlat
var _bar_fill_complete: StyleBoxFlat


func _ready() -> void:
	_init_styles()

	# Start completely hidden as requested
	card_panel.visible = false
	card_panel.modulate.a = 0.0
	_is_visible = false
	_is_completed = false

	# Setup initial values
	progress_bar.max_value = _total_time
	progress_bar.value = _total_time
	reset_display()


func _init_styles() -> void:
	# Red Waiting Style
	_red_waiting_style = StyleBoxFlat.new()
	_red_waiting_style.bg_color = Color(0.14, 0.06, 0.08, 0.65)
	_red_waiting_style.border_color = Color(0.65, 0.25, 0.25, 0.35)
	_red_waiting_style.border_width_left = 1
	_red_waiting_style.border_width_top = 1
	_red_waiting_style.border_width_right = 1
	_red_waiting_style.border_width_bottom = 1
	_red_waiting_style.corner_radius_top_left = 4
	_red_waiting_style.corner_radius_top_right = 4
	_red_waiting_style.corner_radius_bottom_right = 4
	_red_waiting_style.corner_radius_bottom_left = 4
	_red_waiting_style.content_margin_left = 10.0
	_red_waiting_style.content_margin_top = 5.0
	_red_waiting_style.content_margin_right = 10.0
	_red_waiting_style.content_margin_bottom = 5.0

	# Red Active Style
	_red_active_style = StyleBoxFlat.new()
	_red_active_style.bg_color = Color(0.38, 0.08, 0.1, 0.92)
	_red_active_style.border_color = Color(1.0, 0.42, 0.42, 0.95)
	_red_active_style.border_width_left = 1
	_red_active_style.border_width_top = 1
	_red_active_style.border_width_right = 1
	_red_active_style.border_width_bottom = 1
	_red_active_style.corner_radius_top_left = 4
	_red_active_style.corner_radius_top_right = 4
	_red_active_style.corner_radius_bottom_right = 4
	_red_active_style.corner_radius_bottom_left = 4
	_red_active_style.shadow_color = Color(0.9, 0.1, 0.1, 0.35)
	_red_active_style.shadow_size = 6
	_red_active_style.content_margin_left = 10.0
	_red_active_style.content_margin_top = 5.0
	_red_active_style.content_margin_right = 10.0
	_red_active_style.content_margin_bottom = 5.0

	# Blue Waiting Style
	_blue_waiting_style = StyleBoxFlat.new()
	_blue_waiting_style.bg_color = Color(0.05, 0.1, 0.16, 0.65)
	_blue_waiting_style.border_color = Color(0.25, 0.45, 0.75, 0.35)
	_blue_waiting_style.border_width_left = 1
	_blue_waiting_style.border_width_top = 1
	_blue_waiting_style.border_width_right = 1
	_blue_waiting_style.border_width_bottom = 1
	_blue_waiting_style.corner_radius_top_left = 4
	_blue_waiting_style.corner_radius_top_right = 4
	_blue_waiting_style.corner_radius_bottom_right = 4
	_blue_waiting_style.corner_radius_bottom_left = 4
	_blue_waiting_style.content_margin_left = 10.0
	_blue_waiting_style.content_margin_top = 5.0
	_blue_waiting_style.content_margin_right = 10.0
	_blue_waiting_style.content_margin_bottom = 5.0

	# Blue Active Style
	_blue_active_style = StyleBoxFlat.new()
	_blue_active_style.bg_color = Color(0.08, 0.22, 0.48, 0.92)
	_blue_active_style.border_color = Color(0.4, 0.8, 1.0, 0.95)
	_blue_active_style.border_width_left = 1
	_blue_active_style.border_width_top = 1
	_blue_active_style.border_width_right = 1
	_blue_active_style.border_width_bottom = 1
	_blue_active_style.corner_radius_top_left = 4
	_blue_active_style.corner_radius_top_right = 4
	_blue_active_style.corner_radius_bottom_right = 4
	_blue_active_style.corner_radius_bottom_left = 4
	_blue_active_style.shadow_color = Color(0.1, 0.45, 0.9, 0.35)
	_blue_active_style.shadow_size = 6
	_blue_active_style.content_margin_left = 10.0
	_blue_active_style.content_margin_top = 5.0
	_blue_active_style.content_margin_right = 10.0
	_blue_active_style.content_margin_bottom = 5.0

	# Progress Bar Fill: Normal (Warm Gold)
	_bar_fill_normal = StyleBoxFlat.new()
	_bar_fill_normal.bg_color = Color(0.85, 0.68, 0.35, 0.95)
	_bar_fill_normal.corner_radius_top_left = 2
	_bar_fill_normal.corner_radius_top_right = 2
	_bar_fill_normal.corner_radius_bottom_right = 2
	_bar_fill_normal.corner_radius_bottom_left = 2

	# Progress Bar Fill: Critical (<3s Warning Crimson)
	_bar_fill_critical = StyleBoxFlat.new()
	_bar_fill_critical.bg_color = Color(0.92, 0.22, 0.22, 0.95)
	_bar_fill_critical.corner_radius_top_left = 2
	_bar_fill_critical.corner_radius_top_right = 2
	_bar_fill_critical.corner_radius_bottom_right = 2
	_bar_fill_critical.corner_radius_bottom_left = 2

	# Progress Bar Fill: Complete (Radiant Emerald)
	_bar_fill_complete = StyleBoxFlat.new()
	_bar_fill_complete.bg_color = Color(0.3, 0.85, 0.45, 0.95)
	_bar_fill_complete.corner_radius_top_left = 2
	_bar_fill_complete.corner_radius_top_right = 2
	_bar_fill_complete.corner_radius_bottom_right = 2
	_bar_fill_complete.corner_radius_bottom_left = 2


# =========================================================
# PUBLIC CONFIGURATION & VISIBILITY
# =========================================================

func set_total_time(time_val: float) -> void:
	_total_time = max(0.1, time_val)
	if progress_bar:
		progress_bar.max_value = _total_time


func show_ui() -> void:
	if _is_visible and card_panel.visible:
		return

	_is_visible = true
	card_panel.visible = true

	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_fade_tween.tween_property(card_panel, "modulate:a", 1.0, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func hide_ui(delay: float = 0.0) -> void:
	if not _is_visible:
		return

	_is_visible = false

	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if delay > 0.0:
		_fade_tween.tween_interval(delay)
	_fade_tween.tween_property(card_panel, "modulate:a", 0.0, 0.5) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	_fade_tween.tween_callback(func():
		card_panel.visible = false
		message_label.visible = false
	)


# =========================================================
# PUZZLE INTERACTION METHODS
# =========================================================

func update_red_pressed() -> void:
	show_ui()
	message_label.visible = false

	red_icon.text = "✓"
	red_label.text = "RED: ACTIVE"
	red_icon.modulate = Color(1.0, 0.85, 0.85, 1.0)
	red_label.modulate = Color(1.0, 0.95, 0.95, 1.0)
	red_badge.add_theme_stylebox_override("panel", _red_active_style)

	# Punch animation on the badge
	_pulse_badge(red_badge)


func update_blue_pressed() -> void:
	show_ui()
	message_label.visible = false

	blue_icon.text = "✓"
	blue_label.text = "BLUE: ACTIVE"
	blue_icon.modulate = Color(0.85, 0.95, 1.0, 1.0)
	blue_label.modulate = Color(0.9, 0.98, 1.0, 1.0)
	blue_badge.add_theme_stylebox_override("panel", _blue_active_style)

	# Punch animation on the badge
	_pulse_badge(blue_badge)


func update_timer(time_left: float) -> void:
	if _is_completed:
		return

	show_ui()

	var clamped_time: float = max(0.0, time_left)
	timer_badge.text = "%.1fs" % clamped_time
	progress_bar.value = clamped_time

	if clamped_time <= 3.0 and clamped_time > 0.0:
		timer_badge.modulate = Color(1.0, 0.35, 0.35, 1.0)
		progress_bar.add_theme_stylebox_override("fill", _bar_fill_critical)
	else:
		timer_badge.modulate = Color(0.95, 0.85, 0.55, 1.0)
		progress_bar.add_theme_stylebox_override("fill", _bar_fill_normal)


func show_completed() -> void:
	_is_completed = true
	show_ui()

	message_label.text = "✓ MECHANISM SOLVED! DOOR OPEN"
	message_label.modulate = Color(0.55, 0.95, 0.65, 1.0)
	message_label.visible = true

	timer_badge.text = "SOLVED"
	timer_badge.modulate = Color(0.55, 0.95, 0.65, 1.0)

	progress_bar.add_theme_stylebox_override("fill", _bar_fill_complete)
	progress_bar.value = _total_time

	# Toast notification across HUD
	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr:
		ui_mgr.notify_success("Temple Mechanism Solved! Gateway Opened.", 4.0)

	# Fade out after player has seen success
	hide_ui(3.0)


func show_timeout() -> void:
	if _is_completed:
		return

	message_label.text = "TIME EXPIRED — RESETTING..."
	message_label.modulate = Color(1.0, 0.65, 0.3, 1.0)
	message_label.visible = true

	timer_badge.text = "0.0s"
	timer_badge.modulate = Color(1.0, 0.35, 0.35, 1.0)
	progress_bar.value = 0.0

	_reset_badges()

	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr:
		ui_mgr.notify_warning("Mechanism timed out. Resetting pedestals...", 2.5)

	# Fade out smoothly until player presses a button again
	hide_ui(1.6)


func reset_display() -> void:
	_is_completed = false
	message_label.visible = false

	_reset_badges()

	timer_badge.text = "%.1fs" % _total_time
	timer_badge.modulate = Color(0.95, 0.85, 0.55, 1.0)

	progress_bar.max_value = _total_time
	progress_bar.value = _total_time
	progress_bar.add_theme_stylebox_override("fill", _bar_fill_normal)


func _reset_badges() -> void:
	red_icon.text = "●"
	red_label.text = "RED: WAITING"
	red_icon.modulate = Color(0.9, 0.4, 0.4, 1.0)
	red_label.modulate = Color(0.75, 0.6, 0.6, 0.9)
	red_badge.add_theme_stylebox_override("panel", _red_waiting_style)

	blue_icon.text = "●"
	blue_label.text = "BLUE: WAITING"
	blue_icon.modulate = Color(0.4, 0.7, 1.0, 1.0)
	blue_label.modulate = Color(0.6, 0.7, 0.8, 0.9)
	blue_badge.add_theme_stylebox_override("panel", _blue_waiting_style)


func _pulse_badge(badge: Control) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(badge, "modulate", Color(1.4, 1.4, 1.4, 1.0), 0.1)
	tween.tween_property(badge, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
