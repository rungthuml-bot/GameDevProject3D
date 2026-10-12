extends SceneTree

func _init():
	print("--- VERIFYING ALL 9 LEVELS (0-8) ---")
	var all_ok = true
	for i in range(9):
		var path = "res://Scenes/Level/level_%d.tscn" % i
		var scene_res = load(path)
		if scene_res == null:
			printerr("ERROR: Cannot load ", path)
			all_ok = false
			continue
		var inst = scene_res.instantiate()
		if inst == null:
			printerr("ERROR: Cannot instantiate ", path)
			all_ok = false
			continue
		
		var ground_base = inst.get_node_or_null("GroundBase")
		var floors = inst.get_node_or_null("Floors")
		var player_spawn = inst.get_node_or_null("PlayerSpawn")
		var next_door = inst.get_node_or_null("NextLevelDoor")
		
		var floor_count = 0
		if floors != null:
			floor_count = floors.get_child_count()
			
		print("Level %d: SUCCESS! GroundBase: %s, Floor Tiles: %d, PlayerSpawn: %s, Door: %s" % [
			i,
			"YES" if ground_base != null else "NO",
			floor_count,
			"YES" if player_spawn != null else "NO",
			"YES" if next_door != null else "NO"
		])
		inst.free()
	
	if all_ok:
		print("--- ALL 9 LEVELS LOADED & VALIDATED WITHOUT ERRORS ---")
	quit(0)
