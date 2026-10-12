extends SceneTree

func _init():
	print("==================================================")
	print("AUDITING SPECIAL OPENS / WINDOWS / HOLES IN CEILINGS 3-8")
	print("==================================================")
	
	for lvl in range(3, 9):
		var path = "res://Scenes/Level/level_%d.tscn" % lvl
		var res = load(path)
		var inst = res.instantiate()
		var kaykit = inst.find_child("KayKitDungeon", true, false)
		var floors = inst.find_child("Floors", true, false)
		var ceilings = inst.find_child("Ceilings", true, false)
		var lights = []
		for child in inst.get_children():
			find_lights(child, lights)
			
		print("--- Level %d Lights found: %d ---" % [lvl, lights.size()])
		for l in lights:
			print("  Light: %s at %s, energy=%.2f" % [l.name, str(l.position), l.light_energy if "light_energy" in l else 0.0])
		inst.free()
	quit(0)

func find_lights(node: Node, lights: Array):
	if node is Light3D:
		lights.append(node)
	for child in node.get_children():
		find_lights(child, lights)
