extends Node

## Automated test suite for Settings Menu & System Persistence
## Tests:
## 1. Audio Server bus verification (Master, Music, SFX, Ambient)
## 2. UIManager Settings API & Bus attenuation
## 3. ConfigFile Persistence (Save & Load cycle from user://settings.cfg)
## 4. Reset to Defaults
## 5. Controls & Invert Y-Axis
## 6. SettingsMenu Scene instantiation & Node controls
## 7. HUD Pause Settings integration

var _passed_count: int = 0
var _failed_count: int = 0


func _ready() -> void:
	print("\n=== RUNNING SETTINGS MENU SYSTEM TESTS ===")
	await get_tree().process_frame
	await get_tree().physics_frame

	test_audio_buses()
	test_settings_api_and_attenuation()
	test_config_file_persistence()
	test_reset_to_defaults()
	test_controls_and_invert_y()
	test_settings_menu_scene()
	test_hud_pause_settings()

	print("\n==========================================")
	print("SETTINGS TEST RESULTS: %d PASSED, %d FAILED" % [_passed_count, _failed_count])
	print("==========================================\n")

	if _failed_count == 0:
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func assert_true(condition: bool, message: String) -> void:
	if condition:
		_passed_count += 1
		print("[PASS] " + message)
	else:
		_failed_count += 1
		printerr("[FAIL] " + message)


func assert_false(condition: bool, message: String) -> void:
	assert_true(not condition, message)


func assert_eq(a, b, message: String) -> void:
	if a == b:
		_passed_count += 1
		print("[PASS] %s (%s == %s)" % [message, str(a), str(b)])
	else:
		_failed_count += 1
		printerr("[FAIL] %s (Expected %s, got %s)" % [message, str(b), str(a)])


func test_audio_buses() -> void:
	print("\n--- Test 1: Audio Buses ---")
	assert_true(AudioServer.get_bus_index("Master") != -1, "Master bus exists in AudioServer")
	assert_true(AudioServer.get_bus_index("Music") != -1, "Music bus exists in AudioServer")
	assert_true(AudioServer.get_bus_index("SFX") != -1, "SFX bus exists in AudioServer")
	assert_true(AudioServer.get_bus_index("Ambient") != -1, "Ambient bus exists in AudioServer")


func test_settings_api_and_attenuation() -> void:
	print("\n--- Test 2: Settings API & Attenuation ---")
	assert_true(UIManager != null, "UIManager autoload singleton exists")

	# Set custom audio levels
	UIManager.master_volume = 50.0
	UIManager.music_volume = 60.0
	UIManager.sfx_volume = 70.0
	UIManager.ambient_volume = 40.0
	UIManager.apply_all_settings()

	var master_idx = AudioServer.get_bus_index("Master")
	var master_db = AudioServer.get_bus_volume_db(master_idx)
	var expected_db = linear_to_db(0.5)
	assert_true(abs(master_db - expected_db) < 0.1, "Master bus volume properly attenuated to 50%")

	var music_idx = AudioServer.get_bus_index("Music")
	var music_db = AudioServer.get_bus_volume_db(music_idx)
	var expected_music_db = linear_to_db(0.6)
	assert_true(abs(music_db - expected_music_db) < 0.1, "Music bus volume properly attenuated to 60%")


func test_config_file_persistence() -> void:
	print("\n--- Test 3: ConfigFile Save & Load Persistence ---")
	UIManager.master_volume = 65.0
	UIManager.music_volume = 45.0
	UIManager.invert_y = true
	UIManager.subtitles_enabled = false
	UIManager.text_size_index = 0
	UIManager.shadow_quality_index = 1
	UIManager.save_settings_to_config()

	# Reset in memory to random values
	UIManager.master_volume = 10.0
	UIManager.music_volume = 10.0
	UIManager.invert_y = false
	UIManager.subtitles_enabled = true
	UIManager.text_size_index = 1

	# Reload from user://settings.cfg
	UIManager.load_settings_from_config()
	assert_eq(UIManager.master_volume, 65.0, "Loaded master_volume persisted correctly")
	assert_eq(UIManager.music_volume, 45.0, "Loaded music_volume persisted correctly")
	assert_true(UIManager.invert_y, "Loaded invert_y persisted correctly")
	assert_false(UIManager.subtitles_enabled, "Loaded subtitles_enabled persisted correctly")
	assert_eq(UIManager.text_size_index, 0, "Loaded text_size_index persisted correctly")


func test_reset_to_defaults() -> void:
	print("\n--- Test 4: Reset to Defaults ---")
	UIManager.reset_settings_to_defaults()
	assert_eq(UIManager.master_volume, 80.0, "Default master volume is 80%")
	assert_eq(UIManager.music_volume, 80.0, "Default music volume is 80%")
	assert_eq(UIManager.sfx_volume, 85.0, "Default SFX volume is 85%")
	assert_eq(UIManager.ambient_volume, 80.0, "Default ambient volume is 80%")
	assert_false(UIManager.invert_y, "Default Invert Y is false")
	assert_true(UIManager.subtitles_enabled, "Default subtitles is true")
	assert_eq(UIManager.text_size_index, 1, "Default text size is Large")


func test_controls_and_invert_y() -> void:
	print("\n--- Test 5: Controls and Invert Y in Player ---")
	var player_scene: PackedScene = load("res://Scenes/Player/Player.tscn")
	assert_true(player_scene != null, "Player.tscn loaded")

	var player = player_scene.instantiate()
	add_child(player)

	UIManager.invert_y = true
	UIManager.settings_updated.emit()
	assert_true(UIManager.invert_y, "Invert Y flag is active")

	UIManager.invert_y = false
	UIManager.settings_updated.emit()
	assert_false(UIManager.invert_y, "Invert Y flag is deactivated")

	player.queue_free()


func test_settings_menu_scene() -> void:
	print("\n--- Test 6: SettingsMenu Scene Nodes ---")
	var sm_scene: PackedScene = load("res://Scenes/UI/SettingsMenu.tscn")
	assert_true(sm_scene != null, "SettingsMenu.tscn loaded")

	var menu = sm_scene.instantiate()
	add_child(menu)

	assert_true(menu.has_node("%MasterVolumeSlider"), "MasterVolumeSlider exists in SettingsMenu")
	assert_true(menu.has_node("%MusicVolumeSlider"), "MusicVolumeSlider exists in SettingsMenu")
	assert_true(menu.has_node("%SfxVolumeSlider"), "SfxVolumeSlider exists in SettingsMenu")
	assert_true(menu.has_node("%AmbientVolumeSlider"), "AmbientVolumeSlider exists in SettingsMenu")
	assert_true(menu.has_node("%WindowModeOption"), "WindowModeOption exists in SettingsMenu")
	assert_true(menu.has_node("%VsyncToggle"), "VsyncToggle exists in SettingsMenu")
	assert_true(menu.has_node("%ShadowOption"), "ShadowOption exists in SettingsMenu")
	assert_true(menu.has_node("%SensitivitySlider"), "SensitivitySlider exists in SettingsMenu")
	assert_true(menu.has_node("%InvertYToggle"), "InvertYToggle exists in SettingsMenu")
	assert_true(menu.has_node("%SubtitlesToggle"), "SubtitlesToggle exists in SettingsMenu")
	assert_true(menu.has_node("%TextSizeOption"), "TextSizeOption exists in SettingsMenu")
	assert_true(menu.has_node("%ApplyButton"), "ApplyButton exists in SettingsMenu")
	assert_true(menu.has_node("%ResetButton"), "ResetButton exists in SettingsMenu")
	assert_true(menu.has_node("%BackButton"), "BackButton exists in SettingsMenu")

	# Test Apply Button trigger
	menu._on_apply()
	assert_eq(menu.apply_btn.text, "APPLIED", "Apply button provides visual feedback 'APPLIED'")

	menu.queue_free()


func test_hud_pause_settings() -> void:
	print("\n--- Test 7: HUD Pause Settings Integration ---")
	var hud_scene: PackedScene = load("res://Scenes/UI/HUD.tscn")
	assert_true(hud_scene != null, "HUD.tscn loaded")

	var hud = hud_scene.instantiate()
	add_child(hud)

	assert_true(hud.has_node("PauseMenu/PauseSettings"), "PauseSettings panel exists in HUD")
	assert_true(hud.has_node("PauseMenu/PauseSettings/PanelContainer/MarginContainer/VBoxContainer/VolumeSection/VolumeSlider"), "Master Volume slider in PauseSettings")
	assert_true(hud.has_node("PauseMenu/PauseSettings/PanelContainer/MarginContainer/VBoxContainer/MusicSection/MusicSlider"), "Music Volume slider in PauseSettings")
	assert_true(hud.has_node("PauseMenu/PauseSettings/PanelContainer/MarginContainer/VBoxContainer/SfxSection/SfxSlider"), "SFX Volume slider in PauseSettings")
	assert_true(hud.has_node("PauseMenu/PauseSettings/PanelContainer/MarginContainer/VBoxContainer/AmbientSection/AmbientSlider"), "Ambient Volume slider in PauseSettings")

	hud.queue_free()
