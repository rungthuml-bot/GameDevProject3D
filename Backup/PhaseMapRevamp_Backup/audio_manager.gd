extends Node

## AudioManager — Centralized Audio Manager Singleton
## Handles BGM crossfading, Ambient loops, and pooled SFX playback.
## Ensures seamless transitions between levels, prevents audio overlap,
## and protects against sound spamming.

# =========================================================
# PRELOADED ASSETS
# =========================================================

# Music Tracks
const MUSIC_MENU = preload("res://Assets/Audio/Music/bgm_menu_a_safe_space.ogg")
const MUSIC_LEVEL1 = preload("res://Assets/Audio/Music/bgm_level1_magic_forest.ogg")
const MUSIC_LEVEL2 = preload("res://Assets/Audio/Music/bgm_level2_wilderness.ogg")
const MUSIC_LEVEL3 = preload("res://Assets/Audio/Music/bgm_level3_crypt_searching_further.ogg")
const MUSIC_LEVEL4 = preload("res://Assets/Audio/Music/bgm_level4_sanctum.ogg")
const MUSIC_LEVEL5 = preload("res://Assets/Audio/Music/bgm_level5_broken_passage_journey.ogg")
const MUSIC_LEVEL6 = preload("res://Assets/Audio/Music/bgm_level6_sunken_temple_call_to_adventure.ogg")
const MUSIC_LEVEL7 = preload("res://Assets/Audio/Music/bgm_level7_crystal_cavern_exploration.ogg")
const MUSIC_LEVEL8 = preload("res://Assets/Audio/Music/bgm_level8_forgotten_throne_terminus.ogg")
const MUSIC_CREDITS = preload("res://Assets/Audio/Music/bgm_credits_call_to_adventure.ogg")

# Ambient Tracks
const AMBIENT_CAVE = preload("res://Assets/Audio/Ambient/ambient_cave.ogg")
const AMBIENT_WATER = preload("res://Assets/Audio/Ambient/ambient_water_stream.ogg")
const AMBIENT_FOREST = preload("res://Assets/Audio/Ambient/ambient_forest.ogg")

# Sound Effects
const SFX_DOOR_OPEN = preload("res://Assets/Audio/SFX/sfx_door_open.ogg")
const SFX_LOCK_UNLOCK = preload("res://Assets/Audio/SFX/sfx_lock_unlock.ogg")
const SFX_BUTTON_PRESS = preload("res://Assets/Audio/SFX/sfx_button_press.ogg")
const SFX_INTERACT = preload("res://Assets/Audio/SFX/sfx_interact_ping.ogg")
const SFX_UI_HOVER = preload("res://Assets/Audio/SFX/sfx_ui_hover.ogg")
const SFX_UI_CLICK = preload("res://Assets/Audio/SFX/sfx_ui_click.ogg")
const SFX_DIALOGUE_TYPING = preload("res://Assets/Audio/SFX/sfx_dialogue_typing.ogg")
const SFX_PLAYER_JUMP = preload("res://Assets/Audio/SFX/sfx_player_jump.ogg")
const SFX_PLAYER_LAND = preload("res://Assets/Audio/SFX/sfx_player_land.ogg")
const SFX_PUZZLE_WARNING = preload("res://Assets/Audio/SFX/sfx_puzzle_warning.ogg")

# Footstep Sound Variations
const SFX_FOOTSTEP_WALK: Array[AudioStream] = [
	preload("res://Assets/Audio/SFX/sfx_footstep_walk_1.ogg"),
	preload("res://Assets/Audio/SFX/sfx_footstep_walk_2.ogg"),
	preload("res://Assets/Audio/SFX/sfx_footstep_walk_3.ogg"),
]
const SFX_FOOTSTEP_RUN: Array[AudioStream] = [
	preload("res://Assets/Audio/SFX/sfx_footstep_run_1.ogg"),
	preload("res://Assets/Audio/SFX/sfx_footstep_run_2.ogg"),
	preload("res://Assets/Audio/SFX/sfx_footstep_run_3.ogg"),
]
const SFX_FOOTSTEP_SNEAK: Array[AudioStream] = [
	preload("res://Assets/Audio/SFX/sfx_footstep_sneak_1.ogg"),
	preload("res://Assets/Audio/SFX/sfx_footstep_sneak_2.ogg"),
	preload("res://Assets/Audio/SFX/sfx_footstep_sneak_3.ogg"),
]

# =========================================================
# CONFIGURATION & STATE
# =========================================================

const SFX_POOL_SIZE := 10
const SFX_COOLDOWN_TIME := 0.08  # 80ms to prevent spamming
const DEFAULT_FADE_DURATION := 1.2

var _music_player_a: AudioStreamPlayer
var _music_player_b: AudioStreamPlayer
var _active_music_player: AudioStreamPlayer = null
var _current_music_stream: AudioStream = null

var _ambient_player: AudioStreamPlayer
var _current_ambient_stream: AudioStream = null

var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_index: int = 0
var _sfx_cooldowns: Dictionary = {}  # Stream -> last play timestamp (ms)

var _current_scene_path: String = ""
var _music_tween: Tween = null
var _ambient_tween: Tween = null

var _scene_music_map: Dictionary = {}
var _scene_ambient_map: Dictionary = {}


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_audio_nodes()
	_setup_scene_mappings()


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if _sfx_pool.is_empty():
		_setup_audio_nodes()
		_setup_scene_mappings()


func _ready() -> void:
	if _sfx_pool.is_empty():
		_setup_audio_nodes()
		_setup_scene_mappings()


func _setup_audio_nodes() -> void:
	if not _sfx_pool.is_empty():
		return
	# Music players for seamless A/B crossfading
	_music_player_a = AudioStreamPlayer.new()
	_music_player_a.name = "MusicPlayerA"
	_music_player_a.bus = "Music" if AudioServer.get_bus_index("Music") != -1 else "Master"
	add_child(_music_player_a)

	_music_player_b = AudioStreamPlayer.new()
	_music_player_b.name = "MusicPlayerB"
	_music_player_b.bus = "Music" if AudioServer.get_bus_index("Music") != -1 else "Master"
	add_child(_music_player_b)

	_active_music_player = _music_player_a

	# Ambient background player
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.name = "AmbientPlayer"
	_ambient_player.bus = "Ambient" if AudioServer.get_bus_index("Ambient") != -1 else "Master"
	add_child(_ambient_player)

	# SFX player pool
	for i in range(SFX_POOL_SIZE):
		var sfx_p = AudioStreamPlayer.new()
		sfx_p.name = "SFXPlayer_%d" % i
		sfx_p.bus = "SFX" if AudioServer.get_bus_index("SFX") != -1 else "Master"
		add_child(sfx_p)
		_sfx_pool.append(sfx_p)


func _setup_scene_mappings() -> void:
	_scene_music_map = {
		"res://Scenes/UI/MainMenu.tscn": MUSIC_MENU,
		"res://Scenes/UI/SettingsMenu.tscn": MUSIC_MENU,
		"res://Scenes/UI/Credits.tscn": MUSIC_CREDITS,
		"res://Scenes/UI/SplashScreen.tscn": MUSIC_MENU,
		"res://Scenes/Level/map_0.tscn": MUSIC_LEVEL1,
		"res://Scenes/Level/level_1.tscn": MUSIC_LEVEL1,
		"res://Scenes/Level/level_2.tscn": MUSIC_LEVEL2,
		"res://Scenes/Level/level_3.tscn": MUSIC_LEVEL3,
		"res://Scenes/Level/level_4.tscn": MUSIC_LEVEL4,
		"res://Scenes/Level/level_5.tscn": MUSIC_LEVEL5,
		"res://Scenes/Level/level_6.tscn": MUSIC_LEVEL6,
		"res://Scenes/Level/level_7.tscn": MUSIC_LEVEL7,
		"res://Scenes/Level/level_8.tscn": MUSIC_LEVEL8,
		"res://Scenes/UI/EndingCutscene.tscn": MUSIC_CREDITS,
	}

	_scene_ambient_map = {
		"res://Scenes/Level/map_0.tscn": AMBIENT_FOREST,
		"res://Scenes/Level/level_3.tscn": AMBIENT_CAVE,
		"res://Scenes/Level/level_6.tscn": AMBIENT_WATER,
		"res://Scenes/Level/level_7.tscn": AMBIENT_CAVE,
		"res://Scenes/Level/level_8.tscn": AMBIENT_CAVE,
	}


func _process(_delta: float) -> void:
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return

	var path = current_scene.scene_file_path
	if not path.is_empty() and path != _current_scene_path:
		_current_scene_path = path
		_on_scene_changed(path)


func _on_scene_changed(scene_path: String) -> void:
	# 1. Update Music
	if _scene_music_map.has(scene_path):
		var target_music: AudioStream = _scene_music_map[scene_path]
		play_music(target_music, DEFAULT_FADE_DURATION)
	elif scene_path.begins_with("res://Scenes/Level/"):
		# Default fallback for unmapped levels
		play_music(MUSIC_LEVEL1, DEFAULT_FADE_DURATION)

	# 2. Update Ambient
	if _scene_ambient_map.has(scene_path):
		var target_ambient: AudioStream = _scene_ambient_map[scene_path]
		play_ambient(target_ambient, DEFAULT_FADE_DURATION)
	else:
		stop_ambient(DEFAULT_FADE_DURATION)


# =========================================================
# MUSIC SYSTEM
# =========================================================

func play_music(stream: AudioStream, fade_time: float = DEFAULT_FADE_DURATION) -> void:
	if stream == null:
		stop_music(fade_time)
		return

	# If the same stream is already playing or fading in, do not restart
	if _current_music_stream == stream and _active_music_player != null and _active_music_player.playing:
		return

	_current_music_stream = stream

	if not is_inside_tree():
		return

	var outgoing_player = _active_music_player
	var incoming_player = _music_player_b if outgoing_player == _music_player_a else _music_player_a
	_active_music_player = incoming_player

	incoming_player.stream = stream
	incoming_player.volume_db = -50.0
	incoming_player.play()

	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()

	_music_tween = create_tween().set_parallel(true)
	_music_tween.tween_property(incoming_player, "volume_db", 0.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if outgoing_player and outgoing_player.playing:
		_music_tween.tween_property(outgoing_player, "volume_db", -50.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		_music_tween.chain().tween_callback(outgoing_player.stop)


func stop_music(fade_time: float = DEFAULT_FADE_DURATION) -> void:
	_current_music_stream = null
	if not is_inside_tree() or _active_music_player == null or not _active_music_player.playing:
		return

	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()

	var player_to_stop = _active_music_player
	_music_tween = create_tween()
	_music_tween.tween_property(player_to_stop, "volume_db", -50.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_music_tween.tween_callback(player_to_stop.stop)


func is_music_playing() -> bool:
	return _active_music_player != null and _active_music_player.playing


# =========================================================
# AMBIENT SYSTEM
# =========================================================

func play_ambient(stream: AudioStream, fade_time: float = DEFAULT_FADE_DURATION) -> void:
	if stream == null:
		stop_ambient(fade_time)
		return

	if _current_ambient_stream == stream and _ambient_player.playing:
		return

	_current_ambient_stream = stream

	if not is_inside_tree():
		return

	if _ambient_tween and _ambient_tween.is_valid():
		_ambient_tween.kill()

	if _ambient_player.playing:
		_ambient_tween = create_tween()
		_ambient_tween.tween_property(_ambient_player, "volume_db", -50.0, fade_time * 0.5)
		_ambient_tween.tween_callback(func():
			_ambient_player.stream = stream
			_ambient_player.play()
		)
		_ambient_tween.tween_property(_ambient_player, "volume_db", 0.0, fade_time * 0.5)
	else:
		_ambient_player.stream = stream
		_ambient_player.volume_db = -50.0
		_ambient_player.play()
		_ambient_tween = create_tween()
		_ambient_tween.tween_property(_ambient_player, "volume_db", 0.0, fade_time)


func stop_ambient(fade_time: float = DEFAULT_FADE_DURATION) -> void:
	_current_ambient_stream = null
	if not is_inside_tree() or not _ambient_player.playing:
		return

	if _ambient_tween and _ambient_tween.is_valid():
		_ambient_tween.kill()

	_ambient_tween = create_tween()
	_ambient_tween.tween_property(_ambient_player, "volume_db", -50.0, fade_time)
	_ambient_tween.tween_callback(_ambient_player.stop)


# =========================================================
# SFX SYSTEM
# =========================================================

func play_sfx(stream: AudioStream, volume_offset_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if stream == null or not is_inside_tree():
		return

	var now = Time.get_ticks_msec() / 1000.0
	var key = stream.resource_path
	if _sfx_cooldowns.has(key):
		if now - _sfx_cooldowns[key] < SFX_COOLDOWN_TIME:
			return  # Suppress duplicate rapid triggering

	_sfx_cooldowns[key] = now

	var player = _sfx_pool[_sfx_pool_index]
	_sfx_pool_index = (_sfx_pool_index + 1) % SFX_POOL_SIZE

	player.stop()
	player.stream = stream
	player.volume_db = volume_offset_db
	player.pitch_scale = pitch_scale
	player.play()


# Convenient SFX triggers
func play_door_sfx() -> void:
	play_sfx(SFX_DOOR_OPEN, -1.0)


func play_lock_unlock_sfx() -> void:
	play_sfx(SFX_LOCK_UNLOCK, 0.0)


func play_button_sfx() -> void:
	play_sfx(SFX_BUTTON_PRESS, 1.0, randf_range(0.96, 1.04))


func play_puzzle_solved_sfx() -> void:
	play_sfx(SFX_LOCK_UNLOCK, 1.0)


func play_interact_sfx() -> void:
	play_sfx(SFX_INTERACT, -2.0)


func play_ui_hover() -> void:
	play_sfx(SFX_UI_HOVER, -6.0, randf_range(0.98, 1.02))


func play_ui_click() -> void:
	play_sfx(SFX_UI_CLICK, -2.0)


func play_dialogue_typing() -> void:
	play_sfx(SFX_DIALOGUE_TYPING, -8.0, randf_range(1.05, 1.20))


func play_jump_sfx() -> void:
	play_sfx(SFX_PLAYER_JUMP, -3.0, randf_range(0.96, 1.04))


func play_land_sfx() -> void:
	play_sfx(SFX_PLAYER_LAND, -1.0, randf_range(0.96, 1.04))


func play_puzzle_warning_sfx(pitch: float = 1.0) -> void:
	play_sfx(SFX_PUZZLE_WARNING, 0.0, pitch)


func play_footstep_walk() -> void:
	if SFX_FOOTSTEP_WALK.is_empty():
		return
	var stream = SFX_FOOTSTEP_WALK[randi() % SFX_FOOTSTEP_WALK.size()]
	play_sfx(stream, -5.0, randf_range(0.96, 1.04))


func play_footstep_run() -> void:
	if SFX_FOOTSTEP_RUN.is_empty():
		return
	var stream = SFX_FOOTSTEP_RUN[randi() % SFX_FOOTSTEP_RUN.size()]
	play_sfx(stream, -1.5, randf_range(0.96, 1.04))


func play_footstep_sneak() -> void:
	if SFX_FOOTSTEP_SNEAK.is_empty():
		return
	var stream = SFX_FOOTSTEP_SNEAK[randi() % SFX_FOOTSTEP_SNEAK.size()]
	play_sfx(stream, -8.0, randf_range(0.97, 1.03))
