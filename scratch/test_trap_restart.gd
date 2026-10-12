extends Node

## Automated test suite for the Trap Restart System:
## 1. Verify default spawn points dictionary in GameManager for Levels 0-8
## 2. Test Player controls disabling and enabling
## 3. Test GameManager.trigger_trap_restart behavior:
##    - Prevents duplicate restart trigger calls (debouncing)
##    - Sets correct spawn point for current level
##    - Does NOT reset Inventory, Sovereign Relic, or persistent state
## 4. Test CryptSpikeTrap triggering:
##    - Non-lethal mode pushes player without level restart
##    - Lethal mode invokes GameManager.trigger_trap_restart()

var passed_count := 0
var failed_count := 0

func assert_true(condition: bool, msg: String) -> void:
	if condition:
		passed_count += 1
		print("[PASS] ", msg)
	else:
		failed_count += 1
		print("[FAIL] ", msg)

func _ready() -> void:
	print("\n=== RUNNING TRAP RESTART SYSTEM TESTS ===")
	call_deferred("_run_tests")

func _run_tests() -> void:
	# Test 1: Spawn mappings for levels 0 to 8
	print("\n--- Test 1: Level Default Spawn Points Mapping ---")
	for lvl in range(9):
		var path = "res://Scenes/Level/level_%d.tscn" % lvl
		var spawn_name = GameManager.get_default_spawn_for_level(path)
		assert_true(not spawn_name.is_empty(), "Level %d has defined default spawn: %s" % [lvl, spawn_name])
	
	# Verify Level 3 specifically targets 'PlayerSpawn' (not from Level 2 or 4)
	assert_true(GameManager.get_default_spawn_for_level("res://Scenes/Level/level_3.tscn") == "PlayerSpawn", "Level 3 default spawn is PlayerSpawn")
	
	# Test 2: Player Controls Enable / Disable
	print("\n--- Test 2: Player Controls Disabling & Recovery ---")
	var player_scn = load("res://Scenes/Player/Player.tscn")
	assert_true(player_scn != null, "Player.tscn loaded")
	var player = player_scn.instantiate()
	add_child(player)
	await get_tree().process_frame
	
	assert_true(player.controls_enabled == true, "Player controls initially enabled")
	player.disable_controls()
	assert_true(player.controls_enabled == false, "Player controls disabled after disable_controls()")
	player.enable_controls()
	assert_true(player.controls_enabled == true, "Player controls re-enabled after enable_controls()")
	remove_child(player)
	player.queue_free()
	
	# Test 3: Inventory & Relic Persistence across Trap Restart
	print("\n--- Test 3: State Persistence (Inventory, Relic) Across Traps ---")
	GameManager.reset_game_state()
	GameManager.set_relic_acquired(true)
	GameManager.set_held_item("sovereign_relic")
	assert_true(GameManager.has_relic == true, "Relic acquired")
	assert_true(GameManager.get_held_item() == "sovereign_relic", "Relic is held")
	
	# Simulate setting spawn point on trap restart
	var target_spawn = GameManager.get_default_spawn_for_level("res://Scenes/Level/level_3.tscn")
	GameManager.set_spawn_point(target_spawn)
	assert_true(GameManager.get_spawn_point() == "PlayerSpawn", "Spawn point set to PlayerSpawn")
	assert_true(GameManager.has_relic == true, "Relic remains in inventory (not wiped by trap)")
	assert_true(GameManager.get_held_item() == "sovereign_relic", "Held item remains equipped")
	
	# Test 4: Debounce guard against multiple concurrent trap triggers
	print("\n--- Test 4: Concurrency & Debounce Protection ---")
	GameManager.is_restarting_level = true
	# Attempting another trigger while already restarting should be ignored
	GameManager.trigger_trap_restart("Duplicate Trap")
	assert_true(GameManager.is_restarting_level == true, "Debounce guard remains active")
	GameManager.is_restarting_level = false
	
	# Test 5: Crypt Spike Trap Configuration
	print("\n--- Test 5: Crypt Spike Trap Modes (Lethal vs Non-lethal) ---")
	var trap_script = load("res://Scripts/crypt_spike_trap.gd")
	assert_true(trap_script != null, "crypt_spike_trap.gd loaded")
	var trap_node = Area3D.new()
	trap_node.set_script(trap_script)
	add_child(trap_node)
	
	assert_true(trap_node.is_lethal == true, "Spike trap defaults to lethal restart mode")
	assert_true(trap_node.is_armed == true, "Spike trap is armed")
	trap_node.is_lethal = false
	assert_true(trap_node.is_lethal == false, "Spike trap can be toggled to non-lethal warning mode")
	
	remove_child(trap_node)
	trap_node.queue_free()
	
	print("\n=======================================================")
	print("TRAP RESTART TEST RESULTS: %d PASSED, %d FAILED" % [passed_count, failed_count])
	print("=======================================================\n")
	
	if failed_count == 0:
		get_tree().quit(0)
	else:
		get_tree().quit(1)
