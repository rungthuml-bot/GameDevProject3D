extends SceneTree

func _init():
	print("--- ADDING CEILINGS TO LEVEL 1 (SANCTUARY HUB) ---")
	var path = "res://Scenes/Level/level_1.tscn"
	var f = FileAccess.open(path, FileAccess.READ)
	var content = f.get_as_text()
	f.close()
	
	# Add ExtResource for ceiling_tile if not present
	# [ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/ceiling_tile.gltf" id="33_ceiling_tile"]
	var ext_line = '[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/ceiling_tile.gltf" id="33_ceiling_tile"]\n'
	if not content.contains("33_ceiling_tile"):
		var last_ext = content.rfind('[ext_resource')
		var next_nl = content.find('\n', last_ext)
		content = content.substr(0, next_nl + 1) + ext_line + content.substr(next_nl + 1)
		
	# Add [node name="Sanctuary_Ceilings" type="Node3D" parent="." unique_id=16000]
	if not content.contains('Sanctuary_Ceilings'):
		var props_line = '[node name="Sanctuary_Props" type="Node3D" parent="." unique_id=15000]\n'
		var idx = content.find(props_line)
		if idx != -1:
			var insert_pt = idx + props_line.length()
			content = content.substr(0, insert_pt) + '[node name="Sanctuary_Ceilings" type="Node3D" parent="." unique_id=16000]\n' + content.substr(insert_pt)
			
	# Generate ceiling nodes for grid:
	# X in [-10, -6, -2, 2, 6, 10]
	# Z in [8, 4, 0, -4, -8, -12, -16, -20]
	# Y = 4.25
	var xs = [-10, -6, -2, 2, 6, 10]
	var zs = [8, 4, 0, -4, -8, -12, -16, -20]
	var ceiling_nodes_str = ""
	var uid = 30000
	for x in xs:
		for z in zs:
			uid += 1
			ceiling_nodes_str += '\n[node name="ceiling_%d_%d" type="Node3D" parent="Sanctuary_Ceilings" unique_id=%d instance=ExtResource("33_ceiling_tile")]\ntransform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, %d, 4.25, %d)\n' % [
				x, z, uid, x, z
			]
			
	# Insert ceiling_nodes_str right before [node name="RelicAltar"
	var altar_pos = content.find('\n[node name="RelicAltar"')
	if altar_pos != -1:
		content = content.substr(0, altar_pos) + ceiling_nodes_str + content.substr(altar_pos)
		var f_out = FileAccess.open(path, FileAccess.WRITE)
		f_out.store_string(content)
		f_out.close()
		print("Successfully added Sanctuary_Ceilings to Level 1! (48 ceiling tiles at Y=4.25)")
	else:
		printerr("Could not find RelicAltar in level_1.tscn!")
		
	quit(0)
