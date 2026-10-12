extends SceneTree

func _init():
	print("--- ADDING CEILING TO LEVEL 2 (MAZE ZONE) ---")
	var path = "res://Scenes/Level/level_2.tscn"
	var f = FileAccess.open(path, FileAccess.READ)
	var content = f.get_as_text()
	f.close()
	
	# Check if ceiling already exists
	if content.contains("Maze_Ceiling_Mesh"):
		print("Level 2 already has Maze_Ceiling_Mesh!")
		quit(0)
		return
		
	# Target insertion before [node name="Player"
	var player_str = '\n[node name="Player" type="CharacterBody3D"'
	var player_idx = content.find(player_str)
	if player_idx == -1:
		printerr("Could not find Player in level_2.tscn!")
		quit(1)
		return
		
	var ceiling_nodes = """
[node name="Maze_Ceiling_Mesh" type="MeshInstance3D" parent="Ground" unique_id=2100760804]
transform = Transform3D(40, 0, 0, 0, 0.2, 0, 0, 0, 40, 0, 6.7, -25)
mesh = SubResource("BoxMesh_qqy1o")

[node name="Maze_Ceiling_Collision" type="CollisionShape3D" parent="Ground" unique_id=742484998]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 6.7, -25)
shape = SubResource("BoxShape3D_y45lv")
"""
	content = content.substr(0, player_idx) + ceiling_nodes + content.substr(player_idx)
	var f_out = FileAccess.open(path, FileAccess.WRITE)
	f_out.store_string(content)
	f_out.close()
	print("Successfully added 40x40 maze ceiling at Y=6.7 to Level 2!")
	quit(0)
