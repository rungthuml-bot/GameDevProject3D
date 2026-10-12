extends Node3D

func _ready():
	print("\n=======================================================")
	print("AUDITING CAMERA VISIBILITY & OCCLUSION (LEVELS 1-8)")
	print("=======================================================")
	
	var all_clear = true
	
	for lvl in range(1, 9):
		var path = "res://Scenes/Level/level_%d.tscn" % lvl
		var scene = load(path)
		var inst = scene.instantiate()
		add_child(inst)
		await get_tree().physics_frame
		await get_tree().physics_frame
		
		var space = inst.get_world_3d().direct_space_state
		
		# Find Player
		var player = inst.find_child("Player", true, false)
		var player_pos = Vector3.ZERO
		if player:
			player_pos = player.global_position
		else:
			var sp = inst.find_child("PlayerSpawn", true, false)
			if sp: player_pos = sp.global_position
			
		# In 3rd person camera:
		# Player eye/head is at player_pos + Vector3(0, 1.4, 0)
		# Camera position is head + THIRD_PERSON_CAM_POS (Vector3(0, 1.0, 4.5)) -> Y = player_pos.y + 2.4, Z = player_pos.z + 4.5
		var head_pos = player_pos + Vector3(0, 1.4, 0)
		var cam_pos = head_pos + Vector3(0, 1.0, 4.5)
		
		# Cast ray from head to camera to see if roof/ceiling occludes camera
		var q = PhysicsRayQueryParameters3D.create(head_pos, cam_pos)
		var hit = space.intersect_ray(q)
		
		# Cast ray straight UP from head to roof to verify clearance
		var q_up = PhysicsRayQueryParameters3D.create(head_pos, head_pos + Vector3(0, 10.0, 0))
		var hit_up = space.intersect_ray(q_up)
		
		var roof_height = "No solid collision above"
		if not hit_up.is_empty():
			roof_height = "Hit at Y=%.2f (Headroom=%.2f m)" % [hit_up["position"].y, hit_up["position"].y - head_pos.y]
			
		print("Level %d: Player at %s | Headroom: %s" % [lvl, str(player_pos), roof_height])
		
		if not hit.is_empty():
			var collider = hit["collider"]
			print("  [WARN] Camera line of sight hit '%s' at distance %.2f m" % [collider.name, head_pos.distance_to(hit["position"])])
		else:
			print("  [PASS] 3rd person camera has clear line of sight to character (no roof occlusion)!")
			
		inst.queue_free()
		await get_tree().process_frame
		await get_tree().physics_frame
		
	print("\n=======================================================")
	print(">>> CAMERA & HEADROOM AUDIT FINISHED! <<<")
	print("=======================================================\n")
	get_tree().quit(0)
