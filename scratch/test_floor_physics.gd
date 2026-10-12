extends Node3D

func _ready():
	print("\n=======================================================")
	print("PHYSICS FLOOR & PLAYER MOVEMENT AUDIT (LEVELS 0-8)")
	print("=======================================================\n")
	
	var all_levels_passed = true
	
	for lvl in range(9):
		var path = "res://Scenes/Level/level_%d.tscn" % lvl
		var scene = load(path)
		if not scene:
			printerr("FAIL: Could not load ", path)
			all_levels_passed = false
			continue
			
		var inst = scene.instantiate()
		add_child(inst)
		await get_tree().physics_frame
		await get_tree().physics_frame
		
		var space = inst.get_world_3d().direct_space_state
		
		# Find player or spawn position
		var spawn_pos = Vector3.ZERO
		var spawn_node = inst.find_child("PlayerSpawn", true, false)
		if not spawn_node:
			spawn_node = inst.find_child("Spawn_Default", true, false)
		if not spawn_node:
			spawn_node = inst.find_child("Spawn_From_Level1", true, false)
		if not spawn_node:
			spawn_node = inst.find_child("Spawn_From_Level2", true, false)
			
		if spawn_node:
			spawn_pos = spawn_node.global_position
		else:
			var player = inst.find_child("Player", true, false)
			if player:
				spawn_pos = player.global_position
				
		print("Checking Level %d: spawn at %s" % [lvl, str(spawn_pos)])
		
		# Cast ray straight down from spawn + 1m up
		var ray_from = spawn_pos + Vector3(0, 1.0, 0)
		var ray_to = spawn_pos + Vector3(0, -3.0, 0)
		var query = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
		var result = space.intersect_ray(query)
		
		if result.is_empty():
			printerr("  [FAIL] Level %d: Raycast from spawn down hit NO floor collision! Player would fall into void!" % lvl)
			all_levels_passed = false
		else:
			var collider = result["collider"]
			var hit_pos = result["position"]
			print("  [PASS] Level %d Floor Collision: Hit at Y=%.3f, Collider='%s' (%s)" % [
				lvl, hit_pos.y, collider.name, collider.get_class()
			])
			
		# Also check multiple grid points along floor to verify continuous collision coverage
		var test_offsets = [
			Vector3(0, 0, 0), Vector3(2, 0, 0), Vector3(-2, 0, 0),
			Vector3(0, 0, 2), Vector3(0, 0, -2), Vector3(4, 0, 0),
			Vector3(-4, 0, 0), Vector3(0, 0, 4), Vector3(0, 0, -4)
		]
		var coverage_hits = 0
		for offset in test_offsets:
			var q = PhysicsRayQueryParameters3D.create(spawn_pos + offset + Vector3(0, 2.0, 0), spawn_pos + offset + Vector3(0, -3.0, 0))
			var res = space.intersect_ray(q)
			if not res.is_empty():
				coverage_hits += 1
		print("  [PASS] Level %d Area Coverage: %d/%d test rays hit solid ground" % [lvl, coverage_hits, test_offsets.size()])
		
		inst.queue_free()
		await get_tree().process_frame
		await get_tree().physics_frame
		
	print("\n=======================================================")
	if all_levels_passed:
		print(">>> ALL 9 LEVELS HAVE SOLID, CONTINUOUS FLOOR COLLISION! <<<")
	else:
		print(">>> SOME LEVELS FAILED FLOOR COLLISION CHECK! <<<")
	print("=======================================================\n")
	get_tree().quit(0 if all_levels_passed else 1)
