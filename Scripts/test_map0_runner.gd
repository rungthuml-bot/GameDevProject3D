extends Node3D

var passed: int = 0
var failed: int = 0

var map0_instance: Node3D = null
var player: CharacterBody3D = null

func _ready() -> void:
	print("==================================================")
	print("STARTING TEST SUITE: PHASE MAP 0 VERIFICATION")
	print("==================================================")
	
	var map0_scene = load("res://Scenes/Level/map_0.tscn")
	assert_true(map0_scene != null, "map_0.tscn loaded successfully")
	map0_instance = map0_scene.instantiate()
	add_child(map0_instance)
	player = map0_instance.get_node_or_null("Player")
	
	# Settle physics server (2 frames)
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	await run_all_tests()


func assert_true(condition: bool, test_name: String) -> void:
	if condition:
		print("  [PASS] ", test_name)
		passed += 1
	else:
		print("  [FAIL] ", test_name)
		failed += 1


func run_all_tests() -> void:
	test_map0_structure()
	test_audio_mapping()
	test_level1_marker()
	await test_physics_walkthrough()
	test_door_and_transition()
	
	print("\n==================================================")
	print("FINAL TEST RESULTS:")
	print("Passed: %d, Failed: %d" % [passed, failed])
	print("==================================================")
	
	if failed == 0:
		print("SUCCESS: ALL MAP 0 CRITERIA VERIFIED!")
	else:
		print("FAILURE: ONE OR MORE TESTS FAILED!")
		
	get_tree().quit(0 if failed == 0 else 1)


func test_map0_structure() -> void:
	print("\n--- 1. Testing Map 0 Structure & Node Hierarchy ---")
	assert_true(map0_instance != null, "Map 0 root instance exists")
	assert_true(map0_instance.has_node("WorldEnvironment"), "Has WorldEnvironment")
	assert_true(map0_instance.has_node("Sunlight"), "Has Sunlight")
	assert_true(player != null, "Has Player node")
	assert_true(map0_instance.has_node("InteractionUI"), "Has InteractionUI")
	assert_true(map0_instance.has_node("HUD"), "Has HUD")
	assert_true(map0_instance.has_node("Spawn_Default"), "Has Spawn_Default")
	assert_true(map0_instance.has_node("PlayerSpawn"), "Has PlayerSpawn")
	
	assert_true(map0_instance.has_node("Zone_A_Trail"), "Zone A: The Forgotten Trail exists")
	assert_true(map0_instance.has_node("Zone_B_Ruins"), "Zone B: The Forgotten Ruins exists")
	assert_true(map0_instance.has_node("Zone_C_Gate"), "Zone C: The Ancient Gate exists")
	assert_true(map0_instance.has_node("Nature_Props"), "Nature vegetation & tree props exist")
	
	assert_true(map0_instance.has_node("Zone_A_Trail/Inspect_TrailMarker"), "Zone A has Trail Marker lore prop")
	assert_true(map0_instance.has_node("Zone_B_Ruins/Inspect_RuinsRelic"), "Zone B has Ruins Sentry lore prop")
	assert_true(map0_instance.has_node("Zone_C_Gate/Inspect_GateRunes"), "Zone C has Gate Inscription lore prop")
	
	var door = map0_instance.get_node_or_null("Zone_C_Gate/Door_To_Level1")
	assert_true(door != null, "Zone C has Door_To_Level1")
	if door:
		assert_true(door.target_scene == "res://Scenes/Level/level_1.tscn", "Door target_scene is level_1.tscn")
		assert_true(door.target_spawn_id == "Spawn_From_Map0", "Door target_spawn_id is Spawn_From_Map0")
		assert_true(door.require_puzzle == false, "Door require_puzzle is false")


func test_audio_mapping() -> void:
	print("\n--- 2. Testing AudioManager Scene Registration ---")
	assert_true(AudioManager._scene_music_map.has("res://Scenes/Level/map_0.tscn"), "AudioManager music map contains map_0.tscn")
	assert_true(AudioManager._scene_ambient_map.has("res://Scenes/Level/map_0.tscn"), "AudioManager ambient map contains map_0.tscn")
	var amb = AudioManager._scene_ambient_map.get("res://Scenes/Level/map_0.tscn", null)
	assert_true(amb != null, "Map 0 ambient stream is valid (ambient_forest.ogg)")
	var mus = AudioManager._scene_music_map.get("res://Scenes/Level/map_0.tscn", null)
	assert_true(mus != null, "Map 0 music stream is valid (MUSIC_LEVEL1)")


func test_level1_marker() -> void:
	print("\n--- 3. Testing Level 1 Target Spawn Marker ---")
	var l1_scene = load("res://Scenes/Level/level_1.tscn")
	assert_true(l1_scene != null, "level_1.tscn loads successfully")
	var l1 = l1_scene.instantiate()
	add_child(l1)
	
	var marker = l1.get_node_or_null("Spawn_From_Map0")
	assert_true(marker != null, "level_1.tscn contains 'Spawn_From_Map0'")
	if marker:
		assert_true(marker.position == Vector3(-15.0, 0.2, 0.5), "Spawn_From_Map0 position matches forest start (-15, 0.2, 0.5)")
	
	l1.queue_free()


func test_physics_walkthrough() -> void:
	print("\n--- 4. Testing Player Physics & Ground Walkthrough ---")
	if player == null:
		assert_true(false, "Player node exists for physics walkthrough")
		return
		
	var space = get_world_3d().direct_space_state
	var all_solid := true
	var samples := 0
	
	# Raycast downward along entire main route from Z = 28 to Z = -21
	for z_int in range(280, -220, -10):
		var z = z_int / 10.0
		var query = PhysicsRayQueryParameters3D.create(Vector3(0, 5.0, z), Vector3(0, -5.0, z))
		var hit = space.intersect_ray(query)
		if hit.is_empty() or hit.position.y < -0.1:
			all_solid = false
		else:
			samples += 1
			
	assert_true(all_solid and samples >= 50, "Full route from Zone A to Gate has solid floor (50 sample checks)")
	
	# Test Zone A spawn
	player.global_position = Vector3(0, 0.2, 28.0)
	for s in range(15):
		player.velocity = Vector3(0, -9.8, 0)
		player.move_and_slide()
		if player.is_on_floor():
			break
	assert_true(player.is_on_floor(), "Player is firmly on floor in Zone A")
	assert_true(player.global_position.z >= 26.0, "Player stands safely in Zone A (z = %.1f)" % player.global_position.z)
	
	# Test Zone B ruins ground contact
	player.global_position = Vector3(0, 0.2, 0.0)
	for s in range(15):
		player.velocity = Vector3(0, -9.8, 0)
		player.move_and_slide()
		if player.is_on_floor():
			break
	assert_true(player.is_on_floor(), "Player is firmly on floor in Zone B Ruins")
	
	# Test Zone C courtyard elevation
	player.global_position = Vector3(0, 1.2, -16.0)
	for s in range(15):
		player.velocity = Vector3(0, -9.8, 0)
		player.move_and_slide()
		if player.is_on_floor():
			break
	assert_true(player.is_on_floor(), "Player is firmly on floor in Zone C Courtyard")
	assert_true(player.global_position.y >= 0.9, "Player stands elevated on courtyard floor (Y = %.2f)" % player.global_position.y)
	
	# Test approaching Ancient Gate
	player.global_position = Vector3(0, 1.2, -20.5)
	for s in range(15):
		player.velocity = Vector3(0, -9.8, 0)
		player.move_and_slide()
		if player.is_on_floor():
			break
	assert_true(player.is_on_floor(), "Player stands stably before the Ancient Gate")


func test_door_and_transition() -> void:
	print("\n--- 5. Testing Door Interaction & GameManager Target ---")
	var door = map0_instance.get_node_or_null("Zone_C_Gate/Door_To_Level1")
	assert_true(door != null, "Door exists at destination")
	if door and player:
		var dist = player.global_position.distance_to(door.global_position)
		assert_true(dist < 3.0, "Player is within interaction distance to door (%.2fm)" % dist)
		
		# Test spawn target config
		GameManager.set_spawn_point(door.target_spawn_id)
		var queued_spawn = GameManager.get_spawn_point()
		assert_true(queued_spawn == "Spawn_From_Map0", "GameManager queues spawn point 'Spawn_From_Map0'")
		
		# Test level index sync
		for i in range(UIManager.levels.size()):
			if UIManager.levels[i] == door.target_scene:
				UIManager.current_level_index = i + 1
				break
		assert_true(UIManager.current_level_index == 1, "UIManager synced current_level_index to 1")
