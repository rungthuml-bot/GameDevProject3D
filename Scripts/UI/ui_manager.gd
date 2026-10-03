extends Node

## UIManager — Autoload singleton for managing UI state and scene transitions.
## Does NOT handle gameplay logic. Only provides helpers for UI navigation.

# =========================================================
# SIGNALS
# =========================================================

signal game_paused
signal game_resumed
signal win_triggered
signal lose_triggered
signal settings_updated

# =========================================================
# SETTINGS
# =========================================================

var master_volume: float = 80.0
var mouse_sensitivity: float = 0.002
var is_fullscreen: bool = true

# =========================================================
# GAME STATE
# =========================================================

enum GameState { MENU, PLAYING, PAUSED, WIN, LOSE }

var current_state: GameState = GameState.MENU
var current_level_path: String = ""
var current_level_index: int = 1

# Level registry — add new levels here
var levels: Array[String] = [
	"res://Scenes/Level/level_1.tscn",
	"res://Scenes/Level/level_2.tscn",
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Ensure game starts in fullscreen mode
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	is_fullscreen = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11 or (event.keycode == KEY_ENTER and event.alt_pressed):
			toggle_fullscreen()
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
	get_tree().change_scene_to_file(current_level_path)


func restart_level() -> void:
	get_tree().paused = false
	current_state = GameState.PLAYING
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().reload_current_scene()


func load_next_level() -> void:
	var next_index = current_level_index + 1
	if next_index > levels.size():
		# No more levels — go back to main menu
		go_to_main_menu()
		return
	load_level(next_index)


func has_next_level() -> bool:
	return current_level_index < levels.size()


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
# QUIT
# =========================================================

func quit_game() -> void:
	get_tree().quit()


# =========================================================
# SETTINGS API
# =========================================================

func update_settings(volume: float, sensitivity_percent: float, fullscreen: bool) -> void:
	master_volume = volume
	# Map 1..100 to mouse sensitivity range [0.0005, 0.006], default 50 -> 0.002
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

