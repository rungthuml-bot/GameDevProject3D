extends SceneTree

# Script to add missing ceilings to Levels 3, 4, 5, 6, 7, 8
# Preserves intentional skylights (SanctumGoldenShaft in L4, MoonShafts in L5, HallMoonShaft in L6)

func _init():
	print("--- FILLING CEILING GAPS IN LEVELS 3-8 ---")
	
	var ext_res_ceiling = {
		3: "14_r8h4v",
		4: "15_xg5ou",
		5: "11_x00gf",
		6: "14_i83de",
		7: "15_cpk0s",
		8: "15_vep3v"
	}
	
	# Skylights we intentionally want to keep open
	var preserved_skylights = {
		4: ["0_0"], # SanctumGoldenShaft at (0, 4.2, 0)
		5: ["-4_-12", "8_-4"], # MoonShafts
		6: ["0_-4"] # HallMoonShaft
	}
	
	for lvl in range(3, 9):
		var path = "res://Scenes/Level/level_%d.tscn" % lvl
		var f = FileAccess.open(path, FileAccess.READ)
		var content = f.get_as_text()
		f.close()
		
		# Parse floors
		var res = load(path)
		var inst = res.instantiate()
		var floors = inst.find_child("Floors", true, false)
		var ceilings = inst.find_child("Ceilings", true, false)
		
		var floor_coords = []
		if floors:
			for fl in floors.get_children():
				var rx = int(round(fl.position.x))
				var rz = int(round(fl.position.z))
				floor_coords.append(Vector2i(rx, rz))
				
		var existing_ceilings = {}
		if ceilings:
			for c in ceilings.get_children():
				var rx = int(round(c.position.x))
				var rz = int(round(c.position.z))
				existing_ceilings["%d_%d" % [rx, rz]] = true
				
		inst.free()
		
		var to_add = []
		var skylight_list = preserved_skylights.get(lvl, [])
		
		for coord in floor_coords:
			var key = "%d_%d" % [coord.x, coord.y]
			if existing_ceilings.has(key):
				continue
			if key in skylight_list:
				print("Level %d: Preserving intentional open skylight at %s" % [lvl, key])
				continue
			to_add.append(coord)
			
		print("Level %d: Need to add %d ceiling tiles" % [lvl, to_add.size()])
		
		# Generate scene text nodes
		var new_nodes_text = ""
		var ext_id = ext_res_ceiling[lvl]
		var ceiling_uid_base = 800000000 + lvl * 1000000
		
		var idx = 0
		for coord in to_add:
			idx += 1
			var uid = ceiling_uid_base + idx
			# e.g. [node name="ceiling_add_X_Z" type="Node3D" parent="KayKitDungeon/Ceilings" unique_id=... instance=ExtResource("...")]
			# transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, X, 4.25, Z)
			var node_str = '\n[node name="ceiling_add_%d_%d" type="Node3D" parent="KayKitDungeon/Ceilings" unique_id=%d instance=ExtResource("%s")]\ntransform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, %d, 4.25, %d)\n' % [
				coord.x, coord.y, uid, ext_id, coord.x, coord.y
			]
			new_nodes_text += node_str
			
		# Insert right before [node name="Props" or [node name="StructureCollision" or [node name="Torches"
		var insert_pos = content.find('\n[node name="Props"')
		if insert_pos == -1:
			insert_pos = content.find('\n[node name="Torches"')
		if insert_pos == -1:
			insert_pos = content.find('\n[node name="StructureCollision"')
			
		if insert_pos != -1:
			var updated_content = content.substr(0, insert_pos) + new_nodes_text + content.substr(insert_pos)
			var f_out = FileAccess.open(path, FileAccess.WRITE)
			f_out.store_string(updated_content)
			f_out.close()
			print("Level %d: Successfully inserted %d ceiling tiles!" % [lvl, to_add.size()])
		else:
			printerr("Level %d: Could not find insert anchor point!" % lvl)
			
	quit(0)
