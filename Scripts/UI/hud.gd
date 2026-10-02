extends CanvasLayer

## In-Game HUD — Cinematic Adventure style
## Minimal HUD with fade-in overlay animations for pause, win, and lose

@onready var level_label: Label = $MarginContainer/TopBar/LevelLabel
@onready var objective_label: Label = $MarginContainer/TopBar/ObjectiveLabel
@onready var timer_label: Label = $MarginContainer/TopBar/TimerLabel
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

var elapsed_time: float = 0.0
var timer_running: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	level_label.text = "LEVEL " + str(UIManager.current_level_index)
	objective_label.text = "Find the exit"
	timer_label.text = "00:00"

	pause_menu.visible = false
	pause_settings_panel.visible = false
	win_screen.visible = false
	lose_screen.visible = false

	pause_volume_slider.value_changed.connect(_on_pause_settings_changed)
	pause_sensitivity_slider.value_changed.connect(_on_pause_settings_changed)
	pause_fullscreen_check.toggled.connect(_on_pause_settings_changed)

	UIManager.win_triggered.connect(_show_win_screen)
	UIManager.lose_triggered.connect(_show_lose_screen)

	# Cinematic objective fade in
	objective_label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(objective_label, "modulate:a", 1.0, 1.5) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)


func _process(delta: float) -> void:
	if timer_running and UIManager.is_playing():
		elapsed_time += delta
		_update_timer_display()


func _update_timer_display() -> void:
	var minutes: int = int(elapsed_time / 60.0)
	var seconds: int = int(elapsed_time) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		_toggle_pause()


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


# =========================================================
# PAUSE MENU
# =========================================================

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
