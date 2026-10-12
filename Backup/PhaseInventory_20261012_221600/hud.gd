extends CanvasLayer

## In-Game HUD — Cinematic Adventure style
## Presentation layer for Health, Dynamic Objectives, Interaction Prompts,
## Toast Notifications, Damage & Warning Feedback, and UI Test Mode.

const NotificationSystemScript = preload("res://Scripts/UI/notification_system.gd")

# =========================================================
# NODE REFERENCES
# =========================================================

# Status & Timer
@onready var level_label: Label = $MarginContainer/TopBar/LeftSection/LevelLabel
@onready var timer_label: Label = $MarginContainer/TopBar/RightSection/TimerLabel
@onready var top_objective_label: Label = $MarginContainer/TopBar/CenterSection/ObjectiveLabel
@onready var objective_panel: PanelContainer = $MarginContainer/TopBar/RightSection/ObjectivePanel
@onready var objective_list: VBoxContainer = $MarginContainer/TopBar/RightSection/ObjectivePanel/MarginContainer/VBoxContainer/ObjectiveList

# Overlays & Sensory Feedback
@onready var damage_overlay: ColorRect = $DamageOverlay
@onready var crosshair: CenterContainer = $Crosshair

# Interaction Prompt
@onready var interaction_prompt: CenterContainer = $InteractionPrompt
@onready var prompt_key_label: Label = $InteractionPrompt/PanelContainer/MarginContainer/HBoxContainer/KeyBadge/KeyLabel
@onready var prompt_text_label: Label = $InteractionPrompt/PanelContainer/MarginContainer/HBoxContainer/PromptLabel

# Toast Notifications
@onready var notification_list: VBoxContainer = $NotificationContainer/NotificationList

# UI Test Mode
@onready var test_mode_panel: PanelContainer = $TestModePanel

# Pause & End Game Overlays
@onready var pause_menu: Control = $PauseMenu
@onready var win_screen: Control = $WinScreen
@onready var lose_screen: Control = $LoseScreen

@onready var pause_main_panel: Control = $PauseMenu/CenterContainer
@onready var pause_settings_panel: Control = $PauseMenu/PauseSettings
@onready var pause_volume_slider: HSlider = $PauseMenu/PauseSettings/PanelContainer/MarginContainer/VBoxContainer/VolumeSection/VolumeSlider
@onready var pause_sensitivity_slider: HSlider = $PauseMenu/PauseSettings/PanelContainer/MarginContainer/VBoxContainer/SensitivitySection/SensitivitySlider
@onready var pause_fullscreen_check: CheckButton = $PauseMenu/PauseSettings/PanelContainer/MarginContainer/VBoxContainer/DisplaySection/FullscreenCheck
@onready var pause_settings_back_btn: Button = $PauseMenu/PauseSettings/PanelContainer/MarginContainer/VBoxContainer/SettingsBackButton
@onready var pause_resume_btn: Button = $PauseMenu/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var pause_settings_btn: Button = $PauseMenu/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SettingsButton

# =========================================================
# STATE & TWEENS
# =========================================================

var elapsed_time: float = 0.0
var timer_running: bool = true

var _damage_tween: Tween = null
var _prompt_tween: Tween = null

var _test_objective_counter: int = 1
var _test_prompt_visible: bool = false


# =========================================================
# INITIALIZATION
# =========================================================

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Labels setup
	level_label.text = "LEVEL " + str(UIManager.current_level_index)
	timer_label.text = "00:00"
	top_objective_label.text = "Find the exit"

	# Initial hidden overlays
	pause_menu.visible = false
	pause_settings_panel.visible = false
	win_screen.visible = false
	lose_screen.visible = false
	interaction_prompt.visible = false
	interaction_prompt.modulate.a = 0.0
	damage_overlay.modulate.a = 0.0
	test_mode_panel.visible = UIManager.ui_test_mode_enabled

	# Initial Objectives display
	_refresh_objective_list()

	# Connect Pause & Navigation signals
	pause_volume_slider.value_changed.connect(_on_pause_settings_changed)
	pause_sensitivity_slider.value_changed.connect(_on_pause_settings_changed)
	pause_fullscreen_check.toggled.connect(_on_pause_settings_changed)

	UIManager.win_triggered.connect(_show_win_screen)
	UIManager.lose_triggered.connect(_show_lose_screen)

	# Connect Presentation Layer signals
	UIManager.damage_taken.connect(_on_damage_taken)
	UIManager.objective_added.connect(_on_objective_added)
	UIManager.objective_completed.connect(_on_objective_completed)
	UIManager.objective_removed.connect(_on_objective_removed)
	UIManager.objectives_cleared.connect(_on_objectives_cleared)
	UIManager.interaction_prompt_shown.connect(_on_interaction_prompt_shown)
	UIManager.interaction_prompt_hidden.connect(_on_interaction_prompt_hidden)
	UIManager.notification_requested.connect(_on_notification_requested)
	UIManager.warning_triggered.connect(_on_warning_triggered)
	UIManager.success_triggered.connect(_on_success_triggered)
	UIManager.test_mode_toggled.connect(_on_test_mode_toggled)

	# Cinematic Top Objective fade in
	top_objective_label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_interval(1.2)
	tween.tween_property(top_objective_label, "modulate:a", 1.0, 1.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	# Check and trigger level intro dialogue if entering level for first time
	call_deferred("_check_level_intro")


func _check_level_intro() -> void:
	var current_level_node = get_parent()
	UIManager.check_and_trigger_level_intro(current_level_node)


func _process(delta: float) -> void:
	if timer_running and UIManager.is_playing():
		elapsed_time += delta
		_update_timer_display()


func _update_timer_display() -> void:
	var minutes: int = int(elapsed_time / 60.0)
	var seconds: int = int(elapsed_time) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]


func _unhandled_input(event: InputEvent) -> void:
	# Don't trigger pause menu if dialogue is currently active
	if UIManager.is_dialogue_active():
		return

	if event.is_action_pressed("ui_pause"):
		_toggle_pause()
	elif event is InputEventKey and event.pressed and not event.echo:
		# Quick hotkeys when test panel is visible
		if test_mode_panel.visible:
			match event.keycode:
				KEY_3:
					_on_test_add_obj()
					get_viewport().set_input_as_handled()
				KEY_4:
					_on_test_done_obj()
					get_viewport().set_input_as_handled()
				KEY_5:
					_on_test_toast_info()
					get_viewport().set_input_as_handled()
				KEY_6:
					_on_test_toast_warn()
					get_viewport().set_input_as_handled()
				KEY_7:
					_on_test_toast_succ()
					get_viewport().set_input_as_handled()
				KEY_8:
					_on_test_toggle_prompt()
					get_viewport().set_input_as_handled()


# =========================================================
# DAMAGE FEEDBACK
# =========================================================

func _on_damage_taken(_amount: float) -> void:
	# Flash crimson damage overlay
	if _damage_tween and _damage_tween.is_valid():
		_damage_tween.kill()

	damage_overlay.modulate.a = 0.45
	_damage_tween = create_tween()
	_damage_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_damage_tween.tween_property(damage_overlay, "modulate:a", 0.0, 0.4) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


# =========================================================
# OBJECTIVES PRESENTATION
# =========================================================

func _on_objective_added(_id: String, text: String) -> void:
	_refresh_objective_list()
	UIManager.notify_info("New Objective: " + text, 3.0)


func _on_objective_completed(id: String) -> void:
	var obj_text := UIManager.objective_manager.find_text(id)
	_refresh_objective_list()
	if not obj_text.is_empty():
		UIManager.notify_success("Objective Complete: " + obj_text, 3.5)


func _on_objective_removed(_id: String) -> void:
	_refresh_objective_list()


func _on_objectives_cleared() -> void:
	_refresh_objective_list()


func _refresh_objective_list() -> void:
	# Clear existing list nodes
	for child in objective_list.get_children():
		child.queue_free()

	var all_objs := UIManager.get_objectives()

	if all_objs.is_empty():
		objective_panel.visible = false
		top_objective_label.text = "Explore the maze"
		return

	objective_panel.visible = true

	# Set top bar text to first active objective or fallback
	var first_active: String = ""
	for obj in all_objs:
		if not obj["completed"] and first_active.is_empty():
			first_active = obj["text"]

	if not first_active.is_empty():
		top_objective_label.text = first_active
	else:
		top_objective_label.text = "All current objectives completed"

	# Build checklist rows
	for obj in all_objs:
		var row := HBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_constant_override("separation", 6)

		var bullet := Label.new()
		bullet.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bullet.add_theme_font_size_override("font_size", 12)

		var label := Label.new()
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.text = obj["text"]
		label.add_theme_font_size_override("font_size", 13)

		if obj["completed"]:
			bullet.text = "✓"
			bullet.add_theme_color_override("font_color", Color(0.45, 0.85, 0.55, 1.0))
			label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.60, 0.75))
		else:
			bullet.text = "◇"
			bullet.add_theme_color_override("font_color", Color(0.85, 0.72, 0.45, 1.0))
			label.add_theme_color_override("font_color", Color(0.91, 0.88, 0.78, 0.95))

		row.add_child(bullet)
		row.add_child(label)
		objective_list.add_child(row)


# =========================================================
# SCREEN-SPACE INTERACTION PROMPT
# =========================================================

func _on_interaction_prompt_shown(text: String, action_key: String) -> void:
	prompt_key_label.text = action_key
	prompt_text_label.text = text

	if _prompt_tween and _prompt_tween.is_valid():
		_prompt_tween.kill()

	interaction_prompt.visible = true
	_prompt_tween = create_tween()
	_prompt_tween.tween_property(interaction_prompt, "modulate:a", 1.0, 0.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func _on_interaction_prompt_hidden() -> void:
	if not interaction_prompt.visible:
		return

	if _prompt_tween and _prompt_tween.is_valid():
		_prompt_tween.kill()

	_prompt_tween = create_tween()
	_prompt_tween.tween_property(interaction_prompt, "modulate:a", 0.0, 0.2) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_prompt_tween.tween_callback(func(): interaction_prompt.visible = false)


# =========================================================
# TOAST NOTIFICATIONS
# =========================================================

func _on_notification_requested(text: String, type_name: String, duration: float) -> void:
	# Keep maximum visible notifications within limit
	while notification_list.get_child_count() >= NotificationSystemScript.MAX_VISIBLE_NOTIFICATIONS:
		var oldest = notification_list.get_child(0)
		oldest.queue_free()

	var n_type = NotificationSystemScript.parse_type(type_name)
	var accent_color: Color = NotificationSystemScript.get_color(n_type)
	var icon_str: String = NotificationSystemScript.get_icon(n_type)

	# Container for the toast item
	var toast := PanelContainer.new()
	toast.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Toast style
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.045, 0.06, 0.92)
	style.border_width_left = 3
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = accent_color
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	toast.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 8)
	toast.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_theme_constant_override("separation", 10)
	margin.add_child(hbox)

	var icon_label := Label.new()
	icon_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_label.text = icon_str
	icon_label.add_theme_color_override("font_color", accent_color)
	icon_label.add_theme_font_size_override("font_size", 14)
	hbox.add_child(icon_label)

	var msg_label := Label.new()
	msg_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	msg_label.text = text
	msg_label.add_theme_color_override("font_color", Color(0.92, 0.9, 0.85, 1.0))
	msg_label.add_theme_font_size_override("font_size", 14)
	hbox.add_child(msg_label)

	# Initial transparent state
	toast.modulate.a = 0.0
	notification_list.add_child(toast)

	# Fade in and stay, then fade out
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(toast, "modulate:a", 1.0, 0.25) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_interval(duration)
	tween.tween_property(toast, "modulate:a", 0.0, 0.35) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(toast.queue_free)


# =========================================================
# SENSORY FEEDBACK
# =========================================================

func _on_warning_triggered(_message: String) -> void:
	# Subtle amber flash
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var prev_color := damage_overlay.color
	damage_overlay.color = Color(0.95, 0.65, 0.1, 0.0)
	damage_overlay.modulate.a = 0.3
	tween.tween_property(damage_overlay, "modulate:a", 0.0, 0.35) \
		.set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): damage_overlay.color = prev_color)


func _on_success_triggered(_message: String) -> void:
	# Subtle emerald pulse on top objective label
	var tween := create_tween()
	tween.tween_property(top_objective_label, "modulate", Color(0.5, 1.0, 0.6, 1.0), 0.2)
	tween.tween_property(top_objective_label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)


# =========================================================
# UI TEST / DEBUG MODE HANDLERS
# =========================================================

func _on_test_mode_toggled(is_enabled: bool) -> void:
	test_mode_panel.visible = is_enabled


func _on_test_dmg() -> void:
	pass


func _on_test_heal() -> void:
	pass


func _on_test_add_obj() -> void:
	var id := "test_obj_" + str(_test_objective_counter)
	var sample_tasks := [
		"Find the Rusty Iron Key",
		"Inspect the Ancient Sarcophagus",
		"Deactivate the Poison Dart Trap",
		"Unlock the Northern Dungeon Gate",
		"Recover the Lost Crest"
	]
	var task_text: String = sample_tasks[(_test_objective_counter - 1) % sample_tasks.size()]
	_test_objective_counter += 1
	UIManager.add_objective(id, task_text)


func _on_test_done_obj() -> void:
	var objs := UIManager.get_objectives()
	for obj in objs:
		if not obj["completed"]:
			UIManager.complete_objective(obj["id"])
			return
	UIManager.notify_info("All objectives already complete!", 2.5)


func _on_test_toast_info() -> void:
	UIManager.notify_info("The ancient walls echo with distant footsteps.")


func _on_test_toast_warn() -> void:
	UIManager.notify_warning("Pressure plate clicked beneath your boots!")


func _on_test_toast_succ() -> void:
	UIManager.notify_success("Found Secret Altar of Eldoria!")


func _on_test_toggle_prompt() -> void:
	_test_prompt_visible = not _test_prompt_visible
	if _test_prompt_visible:
		UIManager.show_interaction_prompt("Examine Carved Tombstone", "E")
	else:
		UIManager.hide_interaction_prompt()


func _on_test_dlg_l1() -> void:
	UIManager.start_dialogue("level_1_intro", true)


func _on_test_dlg_l2() -> void:
	UIManager.start_dialogue("level_2_intro", true)


func _on_test_dlg_l3() -> void:
	UIManager.start_dialogue("level_3_intro", true)


func _on_test_dlg_l4() -> void:
	UIManager.start_dialogue("level_4_intro", true)


func _on_test_reset_seen() -> void:
	UIManager.reset_seen_dialogues()
	UIManager.notify_info("Dialogue history reset.", 2.5)


# =========================================================
# PAUSE MENU & OVERLAYS
# =========================================================

func _toggle_pause() -> void:
	if UIManager.current_state == UIManager.GameState.PLAYING:
		pause_main_panel.visible = true
		pause_settings_panel.visible = false
		UIManager.pause_game()
		_show_overlay(pause_menu)
		timer_running = false
		pause_resume_btn.call_deferred("grab_focus")
	elif UIManager.current_state == UIManager.GameState.PAUSED:
		_on_resume()


func _show_overlay(overlay: Control) -> void:
	overlay.modulate.a = 0.0
	overlay.visible = true
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.4) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)


func _on_resume() -> void:
	pause_menu.visible = false
	pause_settings_panel.visible = false
	timer_running = true
	UIManager.resume_game()


func _on_restart() -> void:
	pause_menu.visible = false
	UIManager.restart_level()


func _on_settings() -> void:
	pause_volume_slider.value = UIManager.master_volume
	pause_sensitivity_slider.value = UIManager.get_sensitivity_percent()
	pause_fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

	pause_main_panel.visible = false
	pause_settings_panel.visible = true
	pause_settings_back_btn.grab_focus()


func _on_settings_back() -> void:
	pause_settings_panel.visible = false
	pause_main_panel.visible = true
	pause_settings_btn.grab_focus()


func _on_pause_settings_changed(_val = 0) -> void:
	UIManager.update_settings(
		pause_volume_slider.value,
		pause_sensitivity_slider.value,
		pause_fullscreen_check.button_pressed
	)


func _on_main_menu() -> void:
	pause_menu.visible = false
	UIManager.go_to_main_menu()


# =========================================================
# WIN SCREEN
# =========================================================

func _show_win_screen() -> void:
	timer_running = false

	var time_label = win_screen.get_node_or_null(
		"CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TimeLabel"
	)
	if time_label:
		var minutes: int = int(elapsed_time / 60.0)
		var seconds: int = int(elapsed_time) % 60
		time_label.text = "Time: %02d:%02d" % [minutes, seconds]

	var next_btn = win_screen.get_node_or_null(
		"CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsContainer/NextLevelButton"
	)
	if next_btn:
		next_btn.visible = UIManager.has_next_level()

	_show_overlay(win_screen)


func _on_win_next_level() -> void:
	win_screen.visible = false
	UIManager.load_next_level()


func _on_win_retry() -> void:
	win_screen.visible = false
	UIManager.restart_level()


func _on_win_main_menu() -> void:
	win_screen.visible = false
	UIManager.go_to_main_menu()


# =========================================================
# LOSE SCREEN
# =========================================================

func _show_lose_screen() -> void:
	timer_running = false
	_show_overlay(lose_screen)


func _on_lose_retry() -> void:
	lose_screen.visible = false
	UIManager.restart_level()


func _on_lose_main_menu() -> void:
	lose_screen.visible = false
	UIManager.go_to_main_menu()
