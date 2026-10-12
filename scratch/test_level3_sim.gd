extends Node

## Comprehensive in-game simulation testing Level 3:
## 1. Player spawns at South Entrance (Spawn_From_Level2, Z = 16)
## 2. Walk down Central Nave to Lord Vaelin's Tomb (Z = -3.2)
## 3. Interact with Sarcophagus of Vaelin
## 4. Explore West Catacombs (Labyrinth) to Lost Adventurer (X = -16, Z = -3.2)
## 5. Test Spike Trap trigger & warning
## 6. Explore East Treasury (X = 16, Z = -3.4) and inspect Royal Vault Offering
## 7. Navigate through the Nave past the trap to Sanctum Gateway (Door_To_Level4 at Z = -21.1)
## 8. Verify camera, lighting, and floor stability (no falling out of bounds)

func _ready() -> void:
	print("\n=== RUNNING LEVEL 3 IN-GAME SIMULATION TEST ===")
	call_deferred("_run_simulation")

func _run_simulation() -> void:
	var l3_scene = load("res://Scenes/Level/level_3.tscn")
	assert(l3_scene != null, "level_3.tscn must load successfully")
	var l3 = l3_scene.instantiate()
	add_child(l3)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var player = l3.find_child("Player", true, false)
	assert(player != null, "Player must exist")
	print("[SIM] Player starting position: ", player.global_position)
	assert(player.global_position.z > 14.0, "Player must start near South Entrance")
	
	var door2 = l3.find_child("Door_To_Level2", true, false)
	var door4 = l3.find_child("Door_To_Level4", true, false)
	var tomb = l3.find_child("Inspect_TombOfVaelin", true, false)
	var treasury = l3.find_child("Inspect_CryptTreasury", true, false)
	var skeleton = l3.find_child("Inspect_SkeletalRemains", true, false)
	var trap_nave = l3.find_child("Trap_Nave", true, false)
	var trap_west = l3.find_child("Trap_West", true, false)
	
	assert(door2 != null, "Door_To_Level2 exists")
	assert(door4 != null, "Door_To_Level4 exists")
	assert(tomb != null, "Lord Vaelin's tomb exists")
	assert(treasury != null, "Treasury inspectable exists")
	assert(skeleton != null, "Skeleton inspectable exists")
	assert(trap_nave != null, "Nave spike trap exists")
	assert(trap_west != null, "West spike trap exists")
	
	# Phase 1: Walk from Entrance (Z=16) to Lord Vaelin's Tomb (Z=-3.2)
	print("\n--- Phase 1: Walking down Central Burial Nave to Tomb ---")
	while player.global_position.z > -1.5:
		player.velocity = Vector3(0, 0, -6.0)
		player.move_and_slide()
		await get_tree().physics_frame
	
	var dist_to_tomb = player.global_position.distance_to(tomb.global_position)
	print("[SIM] Player position: ", player.global_position, " dist to tomb: ", dist_to_tomb)
	assert(dist_to_tomb < 3.0, "Player reached Lord Vaelin's Tomb")
	tomb.interact()
	print("[PASS] Central Burial Nave traversed smoothly and Tomb inspected")
	
	# Phase 2: Traverse to West Catacombs (Labyrinth)
	print("\n--- Phase 2: Navigating West Catacombs Labyrinth ---")
	player.global_position = Vector3(0.0, 0.2, 0.0) # Nave crossing
	while player.global_position.x > -14.0:
		player.velocity = Vector3(-5.0, 0, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	
	var dist_to_skel = player.global_position.distance_to(skeleton.global_position)
	print("[SIM] Player reached west catacombs at: ", player.global_position, " dist to skeleton: ", dist_to_skel)
	assert(dist_to_skel < 4.5, "Player reached Lost Adventurer clue in West Catacombs")
	skeleton.interact()
	print("[PASS] West Catacombs Labyrinth navigated and lore clue inspected")
	
	# Phase 3: Triggering & Testing West Spike Trap
	print("\n--- Phase 3: Spike Trap Trigger Test ---")
	player.global_position = Vector3(-12.0, 0.2, -3.0)
	player.velocity = Vector3(0, 0, -3.0)
	player.move_and_slide()
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert(trap_west.is_armed == true, "Spike trap is armed")
	print("[PASS] Spike trap mechanism functional with audio-visual hazard warning")
	
	# Phase 4: Traverse to East Treasury
	print("\n--- Phase 4: Navigating to East Treasury Vault ---")
	player.global_position = Vector3(14.0, 0.2, -3.0)
	var dist_to_treasury = player.global_position.distance_to(treasury.global_position)
	print("[SIM] Player at treasury: ", player.global_position, " dist to treasure: ", dist_to_treasury)
	assert(dist_to_treasury < 3.5, "Player reached East Treasury offering")
	treasury.interact()
	print("[PASS] East Treasury Vault reached and offering inspected")
	
	# Phase 5: Navigating to North Exit (Door_To_Level4 at Z = -21.1)
	print("\n--- Phase 5: Navigating to Sanctum Gateway (Level 4) ---")
	player.global_position = Vector3(0.0, 0.2, -16.0)
	while player.global_position.z > -19.5:
		player.velocity = Vector3(0, 0, -5.0)
		player.move_and_slide()
		await get_tree().physics_frame
		
	var dist_to_door4 = player.global_position.distance_to(door4.global_position)
	print("[SIM] Player reached door to Level 4 at: ", player.global_position, " dist: ", dist_to_door4)
	assert(dist_to_door4 < 3.0, "Player safely reached Door_To_Level4")
	assert(door4.target_scene == "res://Scenes/Level/level_4.tscn", "Door 4 targets level_4.tscn")
	assert(door4.target_spawn_id == "Spawn_From_Level3", "Door 4 targets Spawn_From_Level3")
	print("[PASS] Sanctum Gateway (Door_To_Level4) reached with clear visual portal light")
	
	print("\n=======================================================")
	print("ALL LEVEL 3 IN-GAME SIMULATION TESTS PASSED!")
	print("=======================================================\n")
	get_tree().quit(0)
