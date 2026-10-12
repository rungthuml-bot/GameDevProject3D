extends SceneTree

func _init():
	print("==================================================")
	print("INSPECTING ARCHITECTURE & ROOF/CEILING ACROSS LEVELS 1-8")
	print("==================================================")
	
	for lvl in range(1, 9):
		var path = "res://Scenes/Level/level_%d.tscn" % lvl
		var res = load(path)
		if not res:
			printerr("Cannot load: ", path)
			continue
		var inst = res.instantiate()
		
		# Check Ceilings or Roof node
		var ceilings = inst.find_child("Ceilings", true, false)
		var roof = inst.find_child("Roof", true, false)
		var kaykit = inst.find_child("KayKitDungeon", true, false)
		var walls = inst.find_child("Walls", true, false)
		var maze = inst.find_child("Maze", true, false)
		var sanctuary = inst.find_child("Sanctuary_Walls", true, false)
		
		var ceiling_count = 0
		if ceilings:
			ceiling_count = ceilings.get_child_count()
		elif roof:
			ceiling_count = roof.get_child_count()
			
		print("Level %d: " % lvl)
		print("  Ceilings/Roof node: %s (Count: %d)" % [
			"YES" if (ceilings or roof) else "NO",
			ceiling_count
		])
		print("  Walls container: %s | Maze: %s | SanctuaryWalls: %s" % [
			"YES" if walls else "NO",
			"YES" if maze else "NO",
			"YES" if sanctuary else "NO"
		])
		
		# Find sample wall heights and positions
		var wall_y_list = []
		for child in inst.get_children():
			check_y_recursive(child, wall_y_list)
		if wall_y_list.size() > 0:
			wall_y_list.sort()
			print("  Wall Y range: min=%.2f, max=%.2f, median=%.2f (Samples: %d)" % [
				wall_y_list[0],
				wall_y_list[wall_y_list.size()-1],
				wall_y_list[wall_y_list.size()/2],
				wall_y_list.size()
			])
		inst.free()
	quit(0)

func check_y_recursive(node: Node, y_list: Array):
	if "wall" in node.name.to_lower():
		if node is Node3D:
			y_list.append(node.position.y)
	for child in node.get_children():
		check_y_recursive(child, y_list)
