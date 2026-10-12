extends SceneTree

func _init():
	print("--- DETAILED CEILING & FLOOR COMPARISON FOR LEVELS 3-8 ---")
	for lvl in range(3, 9):
		var path = "res://Scenes/Level/level_%d.tscn" % lvl
		var res = load(path)
		var inst = res.instantiate()
		var kaykit = inst.find_child("KayKitDungeon", true, false)
		var floors = inst.find_child("Floors", true, false)
		var ceilings = inst.find_child("Ceilings", true, false)
		
		var floor_positions = {}
		if floors:
			for f in floors.get_children():
				var key = "%d_%d" % [round(f.position.x), round(f.position.z)]
				floor_positions[key] = f.position
				
		var ceiling_positions = {}
		var sample_y = 0.0
		if ceilings:
			for c in ceilings.get_children():
				var key = "%d_%d" % [round(c.position.x), round(c.position.z)]
				ceiling_positions[key] = c.position
				sample_y = c.position.y
				
		var missing_ceilings = []
		for k in floor_positions.keys():
			if not ceiling_positions.has(k):
				missing_ceilings.append(k)
				
		print("Level %d:" % lvl)
		print("  Floors: %d | Ceilings: %d | Ceiling Y: %.2f" % [
			floor_positions.size(),
			ceiling_positions.size(),
			sample_y
		])
		print("  Floor tiles without ceiling: %d / %d" % [missing_ceilings.size(), floor_positions.size()])
		if missing_ceilings.size() > 0:
			var sample_missing = missing_ceilings.slice(0, 10)
			print("  Missing sample coords (X_Z): %s" % str(sample_missing))
		inst.free()
	quit(0)
