extends Node

## UIManager — Autoload singleton for managing UI state, scene transitions,
## presentation layer communication, and narrative dialogue system.
##
## Note on Architecture:
## UIManager acts as a Presentation Layer hub. Gameplay systems (Character,
## Trap, Objectives, Level) connect to these APIs/signals without UI creating or
## managing actual gameplay logic.

# =========================================================
# SIGNALS — GAME STATE & NAVIGATION
# =========================================================

signal game_paused
signal game_resumed
signal win_triggered
signal lose_triggered
signal settings_updated

# =========================================================
# SIGNALS — HUD PRESENTATION LAYER
# =========================================================

## Health presentation (emitted when gameplay updates player health)
signal health_changed(current: float, max_health: float)

## Dynamic objectives
signal objective_added(id: String, text: String)
signal objective_completed(id: String)
signal objective_removed(id: String)
signal objectives_cleared

## Screen-space interaction prompt (e.g. "[E] Open Door")
signal interaction_prompt_shown(text: String, action_key: String)
signal interaction_prompt_hidden

## Notification / Toast messages (info, success, warning, danger)
signal notification_requested(text: String, type_name: String, duration: float)

## Direct sensory feedback triggers
signal damage_taken(amount: float)
signal warning_triggered(message: String)
signal success_triggered(message: String)

## UI Test Mode
signal test_mode_toggled(is_enabled: bool)

# =========================================================
# SIGNALS — DIALOGUE / NARRATIVE SYSTEM
# =========================================================

signal dialogue_started(dialogue_id: String)
signal dialogue_line_displayed(speaker: String, text: String, line_index: int, total_lines: int, is_last: bool)
signal dialogue_ended(dialogue_id: String)

# =========================================================
# SETTINGS
# =========================================================

var master_volume: float = 80.0
var mouse_sensitivity: float = 0.002
var is_fullscreen: bool = true

# =========================================================
# GAME STATE
# =========================================================

enum GameState { MENU, PLAYING, PAUSED, WIN, LOSE, DIALOGUE }

var current_state: GameState = GameState.MENU
var previous_state: GameState = GameState.PLAYING
var current_level_path: String = ""
var current_level_index: int = 1

# Level registry — add new levels here
var levels: Array[String] = [
	"res://Scenes/Level/level_1.tscn",
	"res://Scenes/Level/level_2.tscn",
]

# =========================================================
# PRESENTATION STATE CACHE & MANAGERS
# =========================================================

const ObjectiveManagerScript = preload("res://Scripts/UI/objective_manager.gd")
const DialogueManagerScript = preload("res://Scripts/UI/dialogue_manager.gd")
const DialogueUIScene = preload("res://Scenes/UI/DialogueUI.tscn")

var current_health: float = 100.0
var max_health: float = 100.0
var objective_manager = ObjectiveManagerScript.new()
var dialogue_manager = DialogueManagerScript.new()
var ui_test_mode_enabled: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Ensure game starts in fullscreen mode
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	is_fullscreen = true

	# Connect DialogueManager signals
	dialogue_manager.dialogue_started.connect(_on_dialogue_mgr_started)
	dialogue_manager.dialogue_line_ready.connect(_on_dialogue_mgr_line_ready)
	dialogue_manager.dialogue_ended.connect(_on_dialogue_mgr_ended)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11 or (event.keycode == KEY_ENTER and event.alt_pressed):
			toggle_fullscreen()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F3:
			# Toggle UI Test / Debug mode
			toggle_test_mode()
			get_viewport().set_input_as_handled()


func toggle_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		is_fullscreen = false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		is_fullscreen = true
	settings_updated.emit()


# =========================================================
# STATE MANAGEMENT
# =========================================================

func set_state(new_state: GameState) -> void:
	current_state = new_state


func is_playing() -> bool:
	return current_state == GameState.PLAYING


# =========================================================
# SCENE TRANSITIONS
# =========================================================

func go_to_main_menu() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	current_state = GameState.MENU
	_reset_level_presentation_state()
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")


func start_game() -> void:
	current_level_index = 1
	load_level(current_level_index)


func load_level(level_index: int) -> void:
	if level_index < 1 or level_index > levels.size():
		print("UIManager: Invalid level index: ", level_index)
		return

	current_level_index = level_index
	current_level_path = levels[level_index - 1]
	current_state = GameState.PLAYING
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_reset_level_presentation_state()
	get_tree().change_scene_to_file(current_level_path)


func restart_level() -> void:
	get_tree().paused = false
	current_state = GameState.PLAYING
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_reset_level_presentation_state()
	get_tree().reload_current_scene()


func load_next_level() -> void:
	var next_index = current_level_index + 1
	if next_index > levels.size():
		go_to_main_menu()
		return
	load_level(next_index)


func has_next_level() -> bool:
	return current_level_index < levels.size()


func _reset_level_presentation_state() -> void:
	current_health = 100.0
	max_health = 100.0
	objective_manager.clear()


# =========================================================
# PAUSE
# =========================================================

func pause_game() -> void:
	if current_state != GameState.PLAYING:
		return
	current_state = GameState.PAUSED
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_paused.emit()


func resume_game() -> void:
	if current_state != GameState.PAUSED:
		return
	current_state = GameState.PLAYING
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	game_resumed.emit()


# =========================================================
# WIN / LOSE
# =========================================================

func trigger_win() -> void:
	current_state = GameState.WIN
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	win_triggered.emit()


func trigger_lose() -> void:
	current_state = GameState.LOSE
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	lose_triggered.emit()


# =========================================================
# ENDING CUTSCENE
# =========================================================

## Call this when the player completes the final level.
## The cutscene will play and then show the Game Complete screen.
## Integration point: call UIManager.trigger_ending_cutscene() from
## your win condition trigger (e.g. a "final door" interact(), trap cleared, etc.)
func trigger_ending_cutscene() -> void:
	if current_state == GameState.WIN:
		return  # Already triggered
	current_state = GameState.WIN
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://Scenes/UI/EndingCutscene.tscn")



# =========================================================
# QUIT
# =========================================================

func quit_game() -> void:
	get_tree().quit()


# =========================================================
# SETTINGS API
# =========================================================

func update_settings(volume: float, sensitivity_percent: float, fullscreen: bool) -> void:
	master_volume = volume
	mouse_sensitivity = remap(sensitivity_percent, 0.0, 100.0, 0.0005, 0.006)
	is_fullscreen = fullscreen

	# Apply audio
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume / 100.0))

	# Apply display
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	settings_updated.emit()


func get_sensitivity_percent() -> float:
	return remap(mouse_sensitivity, 0.0005, 0.006, 0.0, 100.0)


# =========================================================
# HEALTH PRESENTATION API (For Gameplay/Character Team)
# =========================================================

func set_health(current: float, max_val: float = -1.0) -> void:
	if max_val > 0.0:
		max_health = max_val
	current_health = clamp(current, 0.0, max_health)
	health_changed.emit(current_health, max_health)


func trigger_damage_feedback(amount: float = 15.0) -> void:
	current_health = clamp(current_health - amount, 0.0, max_health)
	health_changed.emit(current_health, max_health)
	damage_taken.emit(amount)


func heal_feedback(amount: float = 15.0) -> void:
	current_health = clamp(current_health + amount, 0.0, max_health)
	health_changed.emit(current_health, max_health)


# =========================================================
# OBJECTIVE SYSTEM API
# =========================================================

func add_objective(id: String, text: String) -> void:
	objective_manager.add(id, text)
	objective_added.emit(id, text)


func complete_objective(id: String) -> void:
	if objective_manager.complete(id):
		objective_completed.emit(id)


func remove_objective(id: String) -> void:
	if objective_manager.remove(id):
		objective_removed.emit(id)


func clear_objectives() -> void:
	objective_manager.clear()
	objectives_cleared.emit()


func get_objectives() -> Array[Dictionary]:
	return objective_manager.get_all()


# =========================================================
# INTERACTION PROMPT API (Screen-space)
# =========================================================

func show_interaction_prompt(text: String, action_key: String = "E") -> void:
	interaction_prompt_shown.emit(text, action_key)


func hide_interaction_prompt() -> void:
	interaction_prompt_hidden.emit()


# =========================================================
# NOTIFICATION SYSTEM API (Toast alerts)
# =========================================================

func notify(text: String, type_name: String = "info", duration: float = 3.5) -> void:
	notification_requested.emit(text, type_name, duration)


func notify_info(text: String, duration: float = 3.5) -> void:
	notify(text, "info", duration)


func notify_success(text: String, duration: float = 3.5) -> void:
	notify(text, "success", duration)


func notify_warning(text: String, duration: float = 3.5) -> void:
	notify(text, "warning", duration)


func notify_danger(text: String, duration: float = 3.5) -> void:
	notify(text, "danger", duration)


# =========================================================
# SENSORY FEEDBACK TRIGGERS
# =========================================================

func trigger_warning(message: String = "") -> void:
	warning_triggered.emit(message)
	if not message.is_empty():
		notify_warning(message)


func trigger_success(message: String = "") -> void:
	success_triggered.emit(message)
	if not message.is_empty():
		notify_success(message)


# =========================================================
# UI TEST / DEBUG MODE
# =========================================================

func toggle_test_mode() -> void:
	ui_test_mode_enabled = not ui_test_mode_enabled
	test_mode_toggled.emit(ui_test_mode_enabled)


# =========================================================
# DIALOGUE / NARRATIVE SYSTEM API
# =========================================================

func start_dialogue(dialogue_id: String, force_replay: bool = false) -> bool:
	_ensure_dialogue_ui_exists()
	if not dialogue_manager.start_dialogue(dialogue_id, force_replay):
		return false

	previous_state = current_state
	current_state = GameState.DIALOGUE
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	return true


func show_dialogue(dialogue_data: Dictionary, force_replay: bool = false) -> bool:
	_ensure_dialogue_ui_exists()
	if not dialogue_manager.start_dialogue_data(dialogue_data, force_replay):
		return false

	previous_state = current_state
	current_state = GameState.DIALOGUE
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	return true


func next_dialogue() -> void:
	if dialogue_manager.is_dialogue_active():
		dialogue_manager.advance_line()


func close_dialogue() -> void:
	if dialogue_manager.is_dialogue_active():
		dialogue_manager.close_dialogue()


func is_dialogue_active() -> bool:
	return dialogue_manager.is_dialogue_active()


func has_seen_dialogue(dialogue_id: String) -> bool:
	return dialogue_manager.has_seen(dialogue_id)


func mark_dialogue_seen(dialogue_id: String) -> void:
	dialogue_manager.mark_seen(dialogue_id)


func reset_seen_dialogues() -> void:
	dialogue_manager.reset_seen()


func set_allow_dialogue_replay(allow: bool) -> void:
	dialogue_manager.set_allow_replay(allow)


func check_and_trigger_level_intro(level_node: Node = null) -> bool:
	# Check if there is an intro dialogue for this level that hasn't been seen yet
	var dialogue_id := ""

	if level_node != null:
		if level_node.has_meta("dialogue_id"):
			dialogue_id = str(level_node.get_meta("dialogue_id"))
		else:
			var node_name := level_node.name.to_lower().replace("_", "")
			if "level1" in node_name:
				dialogue_id = "level_1_intro"
			elif "level2" in node_name:
				dialogue_id = "level_2_intro"
			elif "level3" in node_name:
				dialogue_id = "level_3_intro"
			elif "level4" in node_name:
				dialogue_id = "level_4_intro"

	if dialogue_id.is_empty():
		dialogue_id = "level_%d_intro" % current_level_index

	if not has_seen_dialogue(dialogue_id):
		return start_dialogue(dialogue_id)

	return false


func _ensure_dialogue_ui_exists() -> void:
	var existing = get_tree().get_first_node_in_group("dialogue_ui")
	if existing == null:
		var dlg_instance = DialogueUIScene.instantiate()
		get_tree().root.add_child.call_deferred(dlg_instance)


func _on_dialogue_mgr_started(id: String, _total: int) -> void:
	dialogue_started.emit(id)


func _on_dialogue_mgr_line_ready(speaker: String, text: String, line_idx: int, total: int, is_last: bool) -> void:
	dialogue_line_displayed.emit(speaker, text, line_idx, total, is_last)


func _on_dialogue_mgr_ended(id: String) -> void:
	if current_state == GameState.DIALOGUE:
		current_state = GameState.PLAYING
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	dialogue_ended.emit(id)
