extends SceneTree

# Test Suite: Phase Map 0 — The Forgotten Entrance

var passed: int = 0
var failed: int = 0

func _init() -> void:
	print("==================================================")
	print("STARTING TEST SUITE: PHASE MAP 0 VERIFICATION")
	print("==================================================")
	
	test_map0_structure()
	test_map0_physics_walkthrough()
	test_level1_connection()
	test_audiomanager_mapping()
	
	print("\n==================================================")
	print("TEST RESULTS:")
	print("Passed: %d, Failed: %d" % [passed, failed])
	print("==================================================")
	if failed == 0:
		print("SUCCESS: ALL MAP 0 VERIFICATION TESTS PASSED!")
	else:
		print("FAILURE: ONE OR MORE TESTS FAILED!")
	quit(0 if failed == 0 else 1)


func assert_true(condition: bool, test_name: String) -> void:
	if condition:
		print("  [PASS] ", test_name)
		passed += 1
	else:
		print("  [FAIL] ", test_name)
		failed += 1


func test_map0_structure() -> void:
	print("\n--- 1. Testing Map 0 Scene Structure & Assets ---")
	var map0_scene = load("res://Scenes/Level/map_0.tscn")
	assert_true(map0_scene != null, "map_0.tscn loaded successfully")
	var map0 = map0_scene.instantiate()
	root.add_child(map0)
	
	assert_true(map0.name == "Map_0", "Root node name is Map_0")
	assert_true(map0.has_node("WorldEnvironment"), "Has WorldEnvironment")
	assert_true(map0.has_node("Sunlight"), "Has Sunlight (DirectionalLight3D)")
	assert_true(map0.has_node("Player"), "Has Player node")
	assert_true(map0.has_node("InteractionUI"), "Has InteractionUI")
	assert_true(map0.has_node("HUD"), "Has HUD")
	assert_true(map0.has_node("Spawn_Default"), "Has Spawn_Default marker")
	assert_true(map0.has_node("PlayerSpawn"), "Has PlayerSpawn marker")
	
	# Verify Three Zones
	assert_true(map0.has_node("Zone_A_Trail"), "Has Zone_A_Trail container")
	assert_true(map0.has_node("Zone_B_Ruins"), "Has Zone_B_Ruins container")
	assert_true(map0.has_node("Zone_C_Gate"), "Has Zone_C_Gate container")
	assert_true(map0.has_node("Nature_Props"), "Has Nature_Props container")
	
	# Verify Lore Inspectables
	assert_true(map0.has_node("Zone_A_Trail/Inspect_TrailMarker"), "Zone A has Inspect_TrailMarker")
	assert_true(map0.has_node("Zone_B_Ruins/Inspect_RuinsRelic"), "Zone B has Inspect_RuinsRelic")
	assert_true(map0.has_node("Zone_C_Gate/Inspect_GateRunes"), "Zone C has Inspect_GateRunes")
	
	# Verify Ancient Gate Door
	assert_true(map0.has_node("Zone_C_Gate/Door_To_Level1"), "Zone C has Door_To_Level1")
	var door = map0.get_node("Zone_C_Gate/Door_To_Level1")
	assert_true(door.target_scene == "res://Scenes/Level/level_1.tscn", "Door targets level_1.tscn")
	assert_true(door.target_spawn_id == "Spawn_From_Map0", "Door targets Spawn_From_Map0")
	assert_true(door.require_puzzle == false, "Door does not require puzzle")
	
	# Verify Player Initial Spawn
	var player = map0.get_node("Player")
	assert_true(player.position.z >= 26.0, "Player spawns safely in Zone A (z = %.1f)" % player.position.z)
	
	map0.queue_free()


func test_map0_physics_walkthrough() -> void:
	print("\n--- 2. Testing Map 0 Physics & Walkthrough Simulation ---")
	var map0_scene = load("res://Scenes/Level/map_0.tscn")
	var map0 = map0_scene.instantiate()
	root.add_child(map0)
	
	var player = map0.get_node("Player")
	var delta := 1.0 / 60.0
	
	# Settle player on ground
	for f in range(15):
		player.velocity = Vector3(0, -9.8, 0)
		player.move_and_slide()
	assert_true(player.is_on_floor(), "Player settles firmly on floor (is_on_floor == true)")
	assert_true(player.global_position.y >= 0.0 and player.global_position.y < 1.0, "Player Y is valid on trail: %.2f" % player.global_position.y)
	
	# Simulate walking from Zone A to Zone B (from Z = 28 to Z = 5)
	# At speed 5.0 m/s moving northward (-Z)
	var fell_through := false
	while player.global_position.z > 5.0:
		player.velocity = Vector3(0, -9.8, -5.0)
		player.move_and_slide()
		if player.global_position.y < -2.0:
			fell_through = true
			break
	assert_true(not fell_through, "Walked through Zone A without falling through terrain")
	assert_true(player.is_on_floor(), "Player remains on floor entering Zone B")
	
	# Simulate walking from Zone B through ruins towards stairs (from Z = 5 to Z = -7)
	while player.global_position.z > -7.0:
		player.velocity = Vector3(0, -9.8, -5.0)
		player.move_and_slide()
		if player.global_position.y < -2.0:
			fell_through = true
			break
	assert_true(not fell_through, "Walked through Zone B ruins without falling through")
	
	# Simulate ascending stairs into Zone C courtyard (from Z = -7 to Z = -12)
	while player.global_position.z > -12.0:
		player.velocity = Vector3(0, -5.0, -4.0)
		player.move_and_slide()
		if player.global_position.y < -2.0:
			fell_through = true
			break
	assert_true(not fell_through, "Ascended stairs to Zone C courtyard successfully")
	assert_true(player.global_position.y >= 0.9, "Player elevated on Zone C courtyard (Y = %.2f)" % player.global_position.y)
	
	# Walk across Zone C courtyard to Ancient Gate at Z = -21.0
	while player.global_position.z > -21.0:
		player.velocity = Vector3(0, -9.8, -5.0)
		player.move_and_slide()
		if player.global_position.y < -2.0:
			fell_through = true
			break
	assert_true(not fell_through, "Walked across Zone C courtyard to Ancient Gate threshold")
	assert_true(player.is_on_floor(), "Player firmly on floor in front of Ancient Gate")
	
	# Test Door interaction
	var door = map0.get_node("Zone_C_Gate/Door_To_Level1")
	assert_true(door != null, "Door exists at destination")
	var dist_to_door = player.global_position.distance_to(door.global_position)
	assert_true(dist_to_door < 2.5, "Player reached door within interaction range (dist: %.2fm)" % dist_to_door)
	
	map0.queue_free()


func test_level1_connection() -> void:
	print("\n--- 3. Testing Level 1 Connection & Spawn Marker ---")
	var l1_scene = load("res://Scenes/Level/level_1.tscn")
	assert_true(l1_scene != null, "level_1.tscn loaded successfully")
	var l1 = l1_scene.instantiate()
	root.add_child(l1)
	
	assert_true(l1.has_node("Spawn_From_Map0"), "level_1.tscn has Spawn_From_Map0 marker")
	var spawn_marker = l1.get_node("Spawn_From_Map0")
	assert_true(spawn_marker.position == Vector3(-15.0, 0.2, 0.5), "Spawn_From_Map0 position matches forest entrance (-15, 0.2, 0.5)")
	
	l1.queue_free()


func test_audiomanager_mapping() -> void:
	print("\n--- 4. Testing AudioManager Mappings for Map 0 ---")
	var am_script = load("res://Scripts/audio_manager.gd")
	var am = am_script.new()
	root.add_child(am)
	
	assert_true(am._scene_music_map.has("res://Scenes/Level/map_0.tscn"), "AudioManager music map contains map_0.tscn")
	assert_true(am._scene_ambient_map.has("res://Scenes/Level/map_0.tscn"), "AudioManager ambient map contains map_0.tscn")
	assert_true(am._scene_ambient_map["res://Scenes/Level/map_0.tscn"] != null, "Map 0 ambient stream is valid (ambient_forest.ogg)")
	
	am.queue_free()
