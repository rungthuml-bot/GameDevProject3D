extends Node3D

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func assert_true(condition: bool, test_name: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
		print("  [PASS] %s" % test_name)
	else:
		failed_tests += 1
		print("  [FAIL] %s" % test_name)

func assert_false(condition: bool, test_name: String) -> void:
	assert_true(not condition, test_name)

func assert_eq(a, b, test_name: String) -> void:
	total_tests += 1
	if a == b:
		passed_tests += 1
		print("  [PASS] %s (%s == %s)" % [test_name, str(a), str(b)])
	else:
		failed_tests += 1
		print("  [FAIL] %s (Expected %s, got %s)" % [test_name, str(b), str(a)])

func _ready() -> void:
	print("\n=======================================================")
	print("REVAMPED MAP 0 (LEVEL 0) & LEVEL 1 VERIFICATION SUITE")
	print("=======================================================\n")
	
	await get_tree().process_frame
	await get_tree().physics_frame
	
	test_level0_structure()
	test_level1_structure()
	test_relic_and_final_door_integration()
	test_audio_and_ui_sync()
	test_all_door_transitions()
	
	print("\n=======================================================")
	print("VERIFICATION SUMMARY")
	print("Total Tests: %d | Passed: %d | Failed: %d" % [total_tests, passed_tests, failed_tests])
	print("=======================================================")
	
	if failed_tests == 0:
		print(">>> ALL VERIFICATION TESTS PASSED SUCCESSFULLY! <<<\n")
	else:
		print(">>> SOME VERIFICATION TESTS FAILED! <<<\n")
		
	get_tree().quit(0 if failed_tests == 0 else 1)

func test_level0_structure() -> void:
	print("--- 1. Testing Level 0 (The Forgotten Entrance) Structure ---")
	var l0_scene = load("res://Scenes/Level/level_0.tscn")
	assert_true(l0_scene != null, "level_0.tscn loaded successfully")
	var l0 = l0_scene.instantiate()
	add_child(l0)
	
	assert_eq(l0.name, "Level_0", "Root node name is Level_0")
	assert_true(l0.find_child("WorldEnvironment", true, false) != null, "Has WorldEnvironment")
	assert_true(l0.find_child("Sunlight", true, false) != null, "Has Sunlight (DirectionalLight3D)")
	assert_true(l0.find_child("GroundBase", true, false) != null, "Has solid GroundBase terrain")
	assert_true(l0.find_child("CourtyardBase", true, false) != null, "Has solid CourtyardBase terrain")
	assert_true(l0.find_child("StairsCollision", true, false) != null, "Has solid StairsCollision ramp")
	assert_true(l0.find_child("InvisibleWalls", true, false) != null, "Has perimeter InvisibleWalls")
	
	# Spawns
	assert_true(l0.find_child("Spawn_Default", true, false) != null, "Has Spawn_Default marker")
	assert_true(l0.find_child("PlayerSpawn", true, false) != null, "Has PlayerSpawn marker")
	assert_true(l0.find_child("Spawn_From_MainMenu", true, false) != null, "Has Spawn_From_MainMenu marker")
	assert_true(l0.find_child("Spawn_From_Level1", true, false) != null, "Has Spawn_From_Level1 marker")
	
	# Player & UI
	var player = l0.find_child("Player", true, false)
	assert_true(player != null, "Has Player instance")
	assert_true(player.is_in_group("player"), "Player is in group 'player'")
	var ui = l0.find_child("InteractionUI", true, false)
	assert_true(ui != null, "Has InteractionUI")
	assert_true(ui.is_in_group("interaction_ui"), "InteractionUI is in group 'interaction_ui'")
	assert_true(l0.find_child("HUD", true, false) != null, "Has HUD")
	
	# Landmark & Lore
	var ruins_relic = l0.find_child("Inspect_RuinsRelic", true, false)
	assert_true(ruins_relic != null, "Has inspectable Ancient Boundary Monument (Inspect_RuinsRelic)")
	if ruins_relic:
		assert_true(ruins_relic.is_in_group("interactable"), "Inspect_RuinsRelic is in group 'interactable'")
		assert_true(ruins_relic.find_child("Col_RuinsRelic", true, false) != null, "Inspect_RuinsRelic has collision")
	
	# Grand Door to Level 1
	var door = l0.find_child("Door_To_Level1", true, false)
	assert_true(door != null, "Has Door_To_Level1")
	if door:
		assert_eq(door.target_scene, "res://Scenes/Level/level_1.tscn", "Door targets level_1.tscn")
		assert_true(door.target_spawn_id in ["Spawn_From_Map0", "Spawn_From_Level0"], "Door targets Spawn_From_Map0/Level0")
		assert_true(door.find_child("TriggerShape", true, false) != null, "Door has TriggerShape collision")
		assert_true(door.find_child("InteractionLabel", true, false) != null, "Door has InteractionLabel")
		assert_true(door.find_child("PortalLight", true, false) != null, "Door has PortalLight")
		
	# Composition Zones
	assert_true(l0.find_child("Zone_A_Trail", true, false) != null, "Has Zone_A_Trail")
	assert_true(l0.find_child("Zone_B_Ruins", true, false) != null, "Has Zone_B_Ruins")
	assert_true(l0.find_child("Zone_C_Gate", true, false) != null, "Has Zone_C_Gate")
	assert_true(l0.find_child("Forest_Foliage", true, false) != null, "Has Forest_Foliage")
	
	remove_child(l0)
	l0.free()

func test_level1_structure() -> void:
	print("\n--- 2. Testing Level 1 (Sanctuary Hub) Structure ---")
	var l1_scene = load("res://Scenes/Level/level_1.tscn")
	assert_true(l1_scene != null, "level_1.tscn loaded successfully")
	var l1 = l1_scene.instantiate()
	add_child(l1)
	
	assert_eq(l1.name, "Level_1", "Root node name is Level_1")
	assert_true(l1.find_child("WorldEnvironment", true, false) != null, "Has WorldEnvironment")
	assert_true(l1.find_child("SanctuaryLight", true, false) != null, "Has SanctuaryLight")
	assert_true(l1.find_child("GroundBase", true, false) != null, "Has solid GroundBase stone floor")
	assert_true(l1.find_child("InvisibleWalls", true, false) != null, "Has perimeter InvisibleWalls")
	
	# Spawns
	assert_true(l1.find_child("Spawn_From_Map0", true, false) != null, "Has Spawn_From_Map0 marker")
	assert_true(l1.find_child("Spawn_From_Level0", true, false) != null, "Has Spawn_From_Level0 marker")
	assert_true(l1.find_child("Spawn_From_Level1", true, false) != null, "Has Spawn_From_Level1 marker")
	assert_true(l1.find_child("Spawn_From_Level2", true, false) != null, "Has Spawn_From_Level2 marker")
	assert_true(l1.find_child("Spawn_From_Level8", true, false) != null, "Has Spawn_From_Level8 marker")
	
	# Player & UI
	var player = l1.find_child("Player", true, false)
	assert_true(player != null, "Has Player instance")
	assert_true(player.is_in_group("player"), "Player is in group 'player'")
	var ui = l1.find_child("InteractionUI", true, false)
	assert_true(ui != null, "Has InteractionUI")
	assert_true(ui.is_in_group("interaction_ui"), "InteractionUI is in group 'interaction_ui'")
	assert_true(l1.find_child("HUD", true, false) != null, "Has HUD")
	
	# Architectural Groups
	assert_true(l1.find_child("Sanctuary_Floor", true, false) != null, "Has Sanctuary_Floor")
	assert_true(l1.find_child("Sanctuary_Walls", true, false) != null, "Has Sanctuary_Walls")
	assert_true(l1.find_child("Sanctuary_Pillars", true, false) != null, "Has Sanctuary_Pillars")
	assert_true(l1.find_child("Sanctuary_Lights", true, false) != null, "Has Sanctuary_Lights")
	assert_true(l1.find_child("Sanctuary_Props", true, false) != null, "Has Sanctuary_Props")
	
	# Door_To_Level2
	var door2 = l1.find_child("Door_To_Level2", true, false)
	assert_true(door2 != null, "Has Door_To_Level2")
	if door2:
		assert_eq(door2.target_scene, "res://Scenes/Level/level_2.tscn", "Door2 targets level_2.tscn")
		assert_eq(door2.target_spawn_id, "Spawn_From_Level1", "Door2 targets Spawn_From_Level1")
		assert_true(door2.find_child("TriggerShape", true, false) != null, "Door2 has TriggerShape")
		assert_true(door2.find_child("InteractionLabel", true, false) != null, "Door2 has InteractionLabel")

	# RelicAltar & FinalDoor
	var altar = l1.find_child("RelicAltar", true, false)
	assert_true(altar != null, "Has RelicAltar")
	if altar:
		assert_true(altar.find_child("AltarMesh", true, false) != null, "RelicAltar has AltarMesh")
		assert_true(altar.find_child("RelicVisual", true, false) != null, "RelicAltar has RelicVisual")
		assert_true(altar.find_child("CollisionShape3D", true, false) != null, "RelicAltar has CollisionShape3D")
		assert_true(altar.find_child("InteractionLabel", true, false) != null, "RelicAltar has InteractionLabel")
		assert_true(altar.find_child("StaticBody3D", true, false) != null, "RelicAltar has solid StaticBody3D")

	var final_door = l1.find_child("FinalDoor", true, false)
	assert_true(final_door != null, "Has FinalDoor")
	if final_door:
		assert_true(final_door.find_child("CollisionShape3D", true, false) != null, "FinalDoor has CollisionShape3D")
		assert_true(final_door.find_child("InteractionLabel", true, false) != null, "FinalDoor has InteractionLabel")
		
	remove_child(l1)
	l1.free()

func test_relic_and_final_door_integration() -> void:
	print("\n--- 3. Testing RelicAltar & FinalDoor Gameplay Integration ---")
	var l1_scene = load("res://Scenes/Level/level_1.tscn")
	var l1 = l1_scene.instantiate()
	add_child(l1)
	
	var altar = l1.find_child("RelicAltar", true, false)
	var final_door = l1.find_child("FinalDoor", true, false)
	var relic_visual = altar.find_child("RelicVisual", true, false)
	
	# State 1: Reset / No Relic
	GameManager.reset_game_state()
	assert_false(GameManager.has_relic, "GameManager.has_relic is false")
	assert_false(GameManager.relic_returned, "GameManager.relic_returned is false")
	
	altar.interact()
	assert_false(GameManager.relic_returned, "Altar cannot be returned without relic")
	assert_false(relic_visual.visible, "RelicVisual remains hidden without relic")
	
	final_door.interact()
	assert_false(final_door._ending_triggered, "FinalDoor blocked when has_relic=false")
	
	# State 2: Has Relic, Not Returned
	GameManager.has_relic = true
	final_door.interact()
	assert_false(final_door._ending_triggered, "FinalDoor blocked when relic_returned=false")
	
	# State 3: Return Relic at Altar
	altar.interact()
	assert_true(GameManager.relic_returned, "Altar interaction sets relic_returned=true")
	assert_true(relic_visual.visible, "RelicVisual is visible on altar after return")
	
	# State 4: FinalDoor Unlocked
	UIManager.current_state = UIManager.GameState.WIN # Prevent premature scene unloading
	final_door.interact()
	assert_true(final_door._ending_triggered, "FinalDoor unlocks and triggers ending when conditions met")
	
	remove_child(l1)
	l1.free()

func test_audio_and_ui_sync() -> void:
	print("\n--- 4. Testing Audio & UI Manager Scene Mappings ---")
	assert_true(AudioManager._scene_music_map.has("res://Scenes/Level/level_0.tscn"), "AudioManager has level_0.tscn music")
	assert_true(AudioManager._scene_music_map.has("res://Scenes/Level/level_1.tscn"), "AudioManager has level_1.tscn music")
	assert_true(AudioManager._scene_ambient_map.has("res://Scenes/Level/level_0.tscn"), "AudioManager has level_0.tscn ambient (AMBIENT_FOREST)")
	assert_eq(UIManager.current_level_path, "res://Scenes/Level/level_0.tscn", "UIManager starts at level_0.tscn")
	assert_true(DialogueDatabase.has_dialogue("level_0_intro"), "DialogueDatabase contains level_0_intro")
	var l0_dlg = DialogueDatabase.get_dialogue("level_0_intro")
	assert_eq(l0_dlg.get("title", ""), "The Forgotten Entrance", "level_0_intro title is 'The Forgotten Entrance'")

func test_all_door_transitions() -> void:
	print("\n--- 5. Testing Door Transitions Across All Levels ---")
	var scenes_to_check = [
		{"path": "res://Scenes/Level/level_0.tscn", "doors": ["Door_To_Level1"], "spawns": ["Spawn_Default"]},
		{"path": "res://Scenes/Level/level_1.tscn", "doors": ["Door_To_Level2", "FinalDoor"], "spawns": ["Spawn_From_Map0", "Spawn_From_Level0", "Spawn_From_Level2", "Spawn_From_Level8"]},
		{"path": "res://Scenes/Level/level_2.tscn", "doors": ["Door_To_Level1", "Door_To_Level3"], "spawns": ["Spawn_From_Level1", "Spawn_From_Level3"]},
		{"path": "res://Scenes/Level/level_3.tscn", "doors": ["Door_To_Level2", "Door_To_Level4"], "spawns": ["Spawn_From_Level2", "Spawn_From_Level4"]},
		{"path": "res://Scenes/Level/level_4.tscn", "doors": ["Door_To_Level3", "Door_To_Level5"], "spawns": ["Spawn_From_Level3", "Spawn_From_Level5"]},
		{"path": "res://Scenes/Level/level_5.tscn", "doors": ["Door_To_Level4", "Door_To_Level6"], "spawns": ["Spawn_From_Level4", "Spawn_From_Level6"]},
		{"path": "res://Scenes/Level/level_6.tscn", "doors": ["Door_To_Level5", "Door_To_Level7"], "spawns": ["Spawn_From_Level5", "Spawn_From_Level7"]},
		{"path": "res://Scenes/Level/level_7.tscn", "doors": ["Door_To_Level6", "Door_To_Level8"], "spawns": ["Spawn_From_Level6", "Spawn_From_Level8"]},
		{"path": "res://Scenes/Level/level_8.tscn", "doors": ["Door_To_Level7", "Door_To_Level1"], "spawns": ["Spawn_From_Level7"]},
	]
	
	for entry in scenes_to_check:
		var scn = load(entry["path"])
		assert_true(scn != null, "Scene %s loads" % entry["path"].get_file())
		if scn:
			var inst = scn.instantiate()
			add_child(inst)
			for d in entry["doors"]:
				var d_node = inst.find_child(d, true, false)
				assert_true(d_node != null, "  Door %s exists in %s" % [d, entry["path"].get_file()])
			for s in entry["spawns"]:
				var s_node = inst.find_child(s, true, false)
				assert_true(s_node != null, "  Spawn %s exists in %s" % [s, entry["path"].get_file()])
			remove_child(inst)
			inst.free()
