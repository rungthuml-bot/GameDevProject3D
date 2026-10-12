import os

def generate_map0():
    out_path = r'c:\Users\ACER\Downloads\GameDevProject3D-map-3-4-rebuild\Scenes\Level\map_0.tscn'
    
    lines = []
    lines.append('[gd_scene format=3]')
    lines.append('')
    
    # ExtResources
    ext_resources = [
        ("PackedScene", "res://Scenes/Player/Player.tscn", "1_player"),
        ("Script", "res://Scripts/player.gd", "2_playerscript"),
        ("PackedScene", "res://Scenes/UI/InteractionUI.tscn", "3_interactionui"),
        ("Script", "res://Scripts/interaction_ui.gd", "4_uiscript"),
        ("PackedScene", "res://Scenes/UI/HUD.tscn", "5_hud"),
        ("Script", "res://Scripts/UI/hud.gd", "6_hudscript"),
        ("Script", "res://Scripts/door.gd", "7_doorscript"),
        ("Script", "res://Scripts/interactable.gd", "8_interactablescript"),
        # Forest models
        ("PackedScene", "res://Assets/Forest/trees/cypress/Cypress_L_flat.glb", "10_cypress"),
        ("PackedScene", "res://Assets/Forest/trees/spruce/Spruce_L_flat.glb", "11_spruce"),
        ("PackedScene", "res://Assets/Forest/trees/birch/Birch_L_flat.glb", "12_birch"),
        ("PackedScene", "res://Assets/Forest/trees/other/Mistletoe_Tree_flat.glb", "13_mistletoe"),
        ("PackedScene", "res://Assets/Forest/forest_floor/boulders/Boulder_01_flat.glb", "14_boulder"),
        ("PackedScene", "res://Assets/Forest/forest_floor/rocks/Rock_01_flat.glb", "15_rock"),
        ("PackedScene", "res://Assets/Forest/forest_floor/bushes/Bush_Clumps_L_flat.glb", "16_bush"),
        ("PackedScene", "res://Assets/Forest/forest_floor/logs_and_stumps/Fallen_Log_flat.glb", "17_log"),
        ("PackedScene", "res://Assets/Forest/forest_floor/logs_and_stumps/Tree_Stump_flat.glb", "18_stump"),
        ("PackedScene", "res://Assets/Forest/forest_floor/shrooms/Mushroom_Red_L_flat.glb", "19_shroom_red"),
        ("PackedScene", "res://Assets/Forest/forest_floor/shrooms/Mushroom_Brown_L_flat.glb", "20_shroom_brown"),
        # KayKit Dungeon models
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_dirt_large.gltf", "21_dirt_large"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_dirt_large_rocky.gltf", "22_dirt_rocky"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_tile_large.gltf", "23_tile_large"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_tile_large_rocks.gltf", "24_tile_rocky"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_tile_small_weeds_A.gltf", "25_tile_weeds"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_tile_small_broken_A.gltf", "26_tile_broken"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/stairs_wide.gltf", "27_stairs_wide"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_doorway.gltf", "28_wall_doorway"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_arched.gltf", "29_wall_arched"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_pillar.gltf", "30_wall_pillar"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall.gltf", "31_wall"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_broken.gltf", "32_wall_broken"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_cracked.gltf", "33_wall_cracked"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/pillar.gltf", "34_pillar"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/pillar_decorated.gltf", "35_pillar_decorated"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/column.gltf", "36_column"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/rubble_large.gltf", "37_rubble_large"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/rubble_half.gltf", "38_rubble_half"),
        ("PackedScene", "res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/torch_lit.gltf", "39_torch_lit")
    ]
    
    for res_type, path, res_id in ext_resources:
        lines.append(f'[ext_resource type="{res_type}" path="{path}" id="{res_id}"]')
    lines.append('')
    
    # SubResources
    lines.append('[sub_resource type="ProceduralSkyMaterial" id="SkyMat_map0"]')
    lines.append('sky_top_color = Color(0.20, 0.32, 0.35, 1)')
    lines.append('sky_horizon_color = Color(0.42, 0.48, 0.40, 1)')
    lines.append('ground_bottom_color = Color(0.12, 0.15, 0.11, 1)')
    lines.append('ground_horizon_color = Color(0.32, 0.38, 0.30, 1)')
    lines.append('')
    
    lines.append('[sub_resource type="Sky" id="Sky_map0"]')
    lines.append('sky_material = SubResource("SkyMat_map0")')
    lines.append('')
    
    lines.append('[sub_resource type="Environment" id="Env_map0"]')
    lines.append('background_mode = 2')
    lines.append('sky = SubResource("Sky_map0")')
    lines.append('ambient_light_source = 2')
    lines.append('ambient_light_color = Color(0.26, 0.30, 0.28, 1)')
    lines.append('ambient_light_energy = 1.3')
    lines.append('tonemap_mode = 3')
    lines.append('fog_enabled = true')
    lines.append('fog_light_color = Color(0.30, 0.38, 0.34, 1)')
    lines.append('fog_density = 0.014')
    lines.append('fog_depth_begin = 8.0')
    lines.append('fog_depth_end = 65.0')
    lines.append('')
    
    lines.append('[sub_resource type="StandardMaterial3D" id="Mat_ground_forest"]')
    lines.append('albedo_color = Color(0.28, 0.25, 0.20, 1)')
    lines.append('roughness = 0.95')
    lines.append('')
    
    lines.append('[sub_resource type="BoxMesh" id="Mesh_ground_base"]')
    lines.append('material = SubResource("Mat_ground_forest")')
    lines.append('size = Vector3(50, 1, 75)')
    lines.append('')
    
    lines.append('[sub_resource type="BoxShape3D" id="Shape_ground_base"]')
    lines.append('size = Vector3(50, 1, 75)')
    lines.append('')
    
    lines.append('[sub_resource type="BoxShape3D" id="Shape_courtyard_base"]')
    lines.append('size = Vector3(24, 1.2, 22)')
    lines.append('')
    
    lines.append('[sub_resource type="BoxShape3D" id="Shape_stairs_ramp"]')
    lines.append('size = Vector3(6, 1.2, 3)')
    lines.append('')
    
    lines.append('[sub_resource type="BoxShape3D" id="Shape_door_trigger"]')
    lines.append('size = Vector3(3.0, 2.8, 1.5)')
    lines.append('')
    
    lines.append('[sub_resource type="BoxShape3D" id="Shape_inspect_trigger"]')
    lines.append('size = Vector3(2.5, 2.0, 2.5)')
    lines.append('')
    
    lines.append('[sub_resource type="BoxShape3D" id="Shape_inv_wall_ns"]')
    lines.append('size = Vector3(40, 12, 1)')
    lines.append('')
    
    lines.append('[sub_resource type="BoxShape3D" id="Shape_inv_wall_ew"]')
    lines.append('size = Vector3(1, 12, 75)')
    lines.append('')
    
    # Root Node
    lines.append('[node name="Map_0" type="Node3D"]')
    lines.append('')
    
    # WorldEnvironment & Sunlight
    lines.append('[node name="WorldEnvironment" type="WorldEnvironment" parent="." unique_id=10001]')
    lines.append('environment = SubResource("Env_map0")')
    lines.append('')
    
    lines.append('[node name="Sunlight" type="DirectionalLight3D" parent="." unique_id=10002]')
    lines.append('transform = Transform3D(0.819, 0.469, -0.328, 0, 0.573, 0.819, 0.573, -0.671, 0.469, 0, 20, 0)')
    lines.append('light_color = Color(0.92, 0.94, 0.86, 1)')
    lines.append('light_energy = 1.6')
    lines.append('shadow_enabled = true')
    lines.append('')
    
    # Spawn Markers
    lines.append('[node name="Spawn_Default" type="Marker3D" parent="." unique_id=20001]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.2, 28)')
    lines.append('')
    lines.append('[node name="PlayerSpawn" type="Marker3D" parent="." unique_id=20002]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.2, 28)')
    lines.append('')
    
    # Player & UI Nodes
    lines.append('[node name="Player" type="CharacterBody3D" parent="." unique_id=20003 groups=["player"] instance=ExtResource("1_player")]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.2, 28)')
    lines.append('script = ExtResource("2_playerscript")')
    lines.append('')
    lines.append('[node name="InteractionUI" type="CanvasLayer" parent="." unique_id=20004 groups=["interaction_ui"] instance=ExtResource("3_interactionui")]')
    lines.append('script = ExtResource("4_uiscript")')
    lines.append('')
    lines.append('[node name="HUD" type="CanvasLayer" parent="." unique_id=20005 instance=ExtResource("5_hud")]')
    lines.append('process_mode = 3')
    lines.append('script = ExtResource("6_hudscript")')
    lines.append('')
    
    # Solid Base Terrain
    lines.append('[node name="GroundBase" type="StaticBody3D" parent="." unique_id=10003]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 5)')
    lines.append('')
    lines.append('[node name="MeshInstance3D" type="MeshInstance3D" parent="GroundBase" unique_id=10004]')
    lines.append('mesh = SubResource("Mesh_ground_base")')
    lines.append('')
    lines.append('[node name="CollisionShape3D" type="CollisionShape3D" parent="GroundBase" unique_id=10005]')
    lines.append('shape = SubResource("Shape_ground_base")')
    lines.append('')
    
    # Courtyard Elevated Solid Base (Zone C: Y = +1.0)
    lines.append('[node name="CourtyardBase" type="StaticBody3D" parent="." unique_id=10006]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.5, -17)')
    lines.append('')
    lines.append('[node name="CollisionShape3D" type="CollisionShape3D" parent="CourtyardBase" unique_id=10007]')
    lines.append('shape = SubResource("Shape_courtyard_base")')
    lines.append('')
    
    # Stairs Collision Ramp
    lines.append('[node name="StairsCollision" type="StaticBody3D" parent="." unique_id=10008]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 0.94, -0.34, 0, 0.34, 0.94, 0, 0.4, -6.5)')
    lines.append('')
    lines.append('[node name="CollisionShape3D" type="CollisionShape3D" parent="StairsCollision" unique_id=10009]')
    lines.append('shape = SubResource("Shape_stairs_ramp")')
    lines.append('')
    
    # Invisible Walls around perimeter
    lines.append('[node name="InvisibleWalls" type="StaticBody3D" parent="." unique_id=10010]')
    lines.append('')
    lines.append('[node name="Wall_South" type="CollisionShape3D" parent="InvisibleWalls" unique_id=10011]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 6, 34)')
    lines.append('shape = SubResource("Shape_inv_wall_ns")')
    lines.append('')
    lines.append('[node name="Wall_North" type="CollisionShape3D" parent="InvisibleWalls" unique_id=10012]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 6, -26)')
    lines.append('shape = SubResource("Shape_inv_wall_ns")')
    lines.append('')
    lines.append('[node name="Wall_West" type="CollisionShape3D" parent="InvisibleWalls" unique_id=10013]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -16, 6, 5)')
    lines.append('shape = SubResource("Shape_inv_wall_ew")')
    lines.append('')
    lines.append('[node name="Wall_East" type="CollisionShape3D" parent="InvisibleWalls" unique_id=10014]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 16, 6, 5)')
    lines.append('shape = SubResource("Shape_inv_wall_ew")')
    lines.append('')
    
    # Spawn Markers
    lines.append('[node name="PlayerSpawn" type="Marker3D" parent="." unique_id=10020]')
    lines.append('transform = Transform3D(-1, 0, -8.742278e-08, 0, 1, 0, 8.742278e-08, 0, -1, 0, 0.2, 28)')
    lines.append('')
    lines.append('[node name="Spawn_Default" type="Marker3D" parent="." unique_id=10021]')
    lines.append('transform = Transform3D(-1, 0, -8.742278e-08, 0, 1, 0, 8.742278e-08, 0, -1, 0, 0.2, 28)')
    lines.append('')
    
    # Player Instance
    lines.append('[node name="Player" type="CharacterBody3D" parent="." unique_id=263796391 groups=["player"] instance=ExtResource("1_player")]')
    lines.append('transform = Transform3D(-1, 0, -8.742278e-08, 0, 1, 0, 8.742278e-08, 0, -1, 0, 0.2, 28)')
    lines.append('script = ExtResource("2_playerscript")')
    lines.append('')
    
    # UI Instances
    lines.append('[node name="InteractionUI" type="CanvasLayer" parent="." unique_id=929617552 groups=["interaction_ui"] instance=ExtResource("3_interactionui")]')
    lines.append('script = ExtResource("4_uiscript")')
    lines.append('')
    lines.append('[node name="HUD" type="CanvasLayer" parent="." unique_id=1499615655 instance=ExtResource("5_hud")]')
    lines.append('process_mode = 3')
    lines.append('script = ExtResource("6_hudscript")')
    lines.append('')
    
    # Container Nodes for Organization
    lines.append('[node name="Zone_A_Trail" type="Node3D" parent="." unique_id=11000]')
    lines.append('[node name="Zone_B_Ruins" type="Node3D" parent="." unique_id=12000]')
    lines.append('[node name="Zone_C_Gate" type="Node3D" parent="." unique_id=13000]')
    lines.append('[node name="Nature_Props" type="Node3D" parent="." unique_id=14000]')
    lines.append('')
    
    uid_counter = 15000
    
    # --- ZONE A: The Forgotten Trail Floor Pieces (Z = 30 to 14) ---
    trail_dirt = [
        (-2, 0, 28), (2, 0, 28),
        (-2, 0, 24), (2, 0, 24),
        (-2, 0, 20), (2, 0, 20),
        (-2, 0, 16), (2, 0, 16)
    ]
    for idx, (x, y, z) in enumerate(trail_dirt):
        ext_id = "22_dirt_rocky" if (idx % 2 == 1) else "21_dirt_large"
        lines.append(f'[node name="dirt_trail_{idx}" type="Node3D" parent="Zone_A_Trail" unique_id={uid_counter} instance=ExtResource("{ext_id}")]')
        lines.append(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x}, {y}, {z})')
        lines.append('')
        uid_counter += 1

    # --- ZONE B: The Forgotten Ruins Floor Pieces (Z = 12 to -4) ---
    ruins_floors = [
        (-2, 0, 12, "22_dirt_rocky"), (2, 0, 12, "22_dirt_rocky"),
        (-2, 0, 8, "24_tile_rocky"),  (2, 0, 8, "24_tile_rocky"),
        (-2, 0, 4, "24_tile_rocky"),  (2, 0, 4, "23_tile_large"),
        (-2, 0, 0, "23_tile_large"),  (2, 0, 0, "24_tile_rocky"),
        (-2, 0, -4, "23_tile_large"), (2, 0, -4, "23_tile_large")
    ]
    for idx, (x, y, z, ext_id) in enumerate(ruins_floors):
        lines.append(f'[node name="ruins_floor_{idx}" type="Node3D" parent="Zone_B_Ruins" unique_id={uid_counter} instance=ExtResource("{ext_id}")]')
        lines.append(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x}, {y}, {z})')
        lines.append('')
        uid_counter += 1

    # Small weed / broken tiles scattered in ruins
    scattered_tiles = [
        (-3.5, 0.02, 6, "25_tile_weeds"),
        (3.5, 0.02, 2, "26_tile_broken"),
        (-3.0, 0.02, -2, "25_tile_weeds"),
        (3.0, 0.02, -3, "26_tile_broken")
    ]
    for idx, (x, y, z, ext_id) in enumerate(scattered_tiles):
        lines.append(f'[node name="scatter_tile_{idx}" type="Node3D" parent="Zone_B_Ruins" unique_id={uid_counter} instance=ExtResource("{ext_id}")]')
        lines.append(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x}, {y}, {z})')
        lines.append('')
        uid_counter += 1

    # Ruins Architecture (broken walls, columns, rubble)
    ruin_structures = [
        # Left broken wall sequence
        (-4.5, 0, 10, 0, "33_wall_cracked"),
        (-4.5, 0, 6, 0, "32_wall_broken"),
        (-5.0, 0, 2, 0.2, "34_pillar"),
        (-5.5, 0, -2, 0, "32_wall_broken"),
        # Right colonnade & rubble
        (4.5, 0, 10, 0, "34_pillar"),
        (4.8, 0, 6, 0.5, "36_column"),
        (5.0, 0, 2, 0, "37_rubble_large"),
        (4.5, 0, -2, 0, "38_rubble_half"),
        (5.2, 0, -4, 0, "34_pillar")
    ]
    for idx, (x, y, z, rot_y, ext_id) in enumerate(ruin_structures):
        rot_deg = rot_y
        lines.append(f'[node name="ruin_arch_{idx}" type="Node3D" parent="Zone_B_Ruins" unique_id={uid_counter} instance=ExtResource("{ext_id}")]')
        lines.append(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x}, {y}, {z})')
        lines.append('')
        uid_counter += 1

    # --- ZONE C: The Ancient Gate (Z = -6 to -24, Y = 1.0) ---
    # Stairs leading up to courtyard
    lines.append(f'[node name="CourtyardStairs" type="Node3D" parent="Zone_C_Gate" unique_id={uid_counter} instance=ExtResource("27_stairs_wide")]')
    lines.append('transform = Transform3D(1.5, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -6)')
    lines.append('')
    uid_counter += 1

    # Courtyard tiles (Y = 1.0)
    courtyard_tiles = [
        (-6, 1.0, -10), (-2, 1.0, -10), (2, 1.0, -10), (6, 1.0, -10),
        (-6, 1.0, -14), (-2, 1.0, -14), (2, 1.0, -14), (6, 1.0, -14),
        (-6, 1.0, -18), (-2, 1.0, -18), (2, 1.0, -18), (6, 1.0, -18),
        (-6, 1.0, -22), (-2, 1.0, -22), (2, 1.0, -22), (6, 1.0, -22)
    ]
    for idx, (x, y, z) in enumerate(courtyard_tiles):
        ext_id = "23_tile_large" if (idx % 3 != 0) else "24_tile_rocky"
        lines.append(f'[node name="court_tile_{idx}" type="Node3D" parent="Zone_C_Gate" unique_id={uid_counter} instance=ExtResource("{ext_id}")]')
        lines.append(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x}, {y}, {z})')
        lines.append('')
        uid_counter += 1

    # Grand Decorated Pillars flanking courtyard
    pillars_c = [
        (-4.0, 1.0, -12, "35_pillar_decorated"),
        (4.0, 1.0, -12, "35_pillar_decorated"),
        (-4.0, 1.0, -18, "35_pillar_decorated"),
        (4.0, 1.0, -18, "35_pillar_decorated")
    ]
    for idx, (x, y, z, ext_id) in enumerate(pillars_c):
        lines.append(f'[node name="grand_pillar_{idx}" type="Node3D" parent="Zone_C_Gate" unique_id={uid_counter} instance=ExtResource("{ext_id}")]')
        lines.append(f'transform = Transform3D(1.2, 0, 0, 0, 1.2, 0, 0, 0, 1.2, {x}, {y}, {z})')
        lines.append('')
        uid_counter += 1

    # Courtyard side walls
    court_walls = [
        (-7.8, 1.0, -10, 1.5708, "31_wall"),
        (-7.8, 1.0, -14, 1.5708, "30_wall_pillar"),
        (-7.8, 1.0, -18, 1.5708, "29_wall_arched"),
        (7.8, 1.0, -10, -1.5708, "31_wall"),
        (7.8, 1.0, -14, -1.5708, "30_wall_pillar"),
        (7.8, 1.0, -18, -1.5708, "29_wall_arched")
    ]
    for idx, (x, y, z, rot, ext_id) in enumerate(court_walls):
        lines.append(f'[node name="court_wall_{idx}" type="Node3D" parent="Zone_C_Gate" unique_id={uid_counter} instance=ExtResource("{ext_id}")]')
        lines.append(f'transform = Transform3D(0, 0, 1, 0, 1, 0, -1, 0, 0, {x}, {y}, {z})' if rot > 0 else f'transform = Transform3D(0, 0, -1, 0, 1, 0, 1, 0, 0, {x}, {y}, {z})')
        lines.append('')
        uid_counter += 1

    # Back wall facade framing the Ancient Gate
    gate_facade = [
        (-4.0, 1.0, -22.0, "29_wall_arched"),
        (0.0, 1.0, -22.0, "28_wall_doorway"),
        (4.0, 1.0, -22.0, "29_wall_arched"),
        (-8.0, 1.0, -22.0, "30_wall_pillar"),
        (8.0, 1.0, -22.0, "30_wall_pillar")
    ]
    for idx, (x, y, z, ext_id) in enumerate(gate_facade):
        scale_mod = "1.25, 0, 0, 0, 1.25, 0, 0, 0, 1.25" if idx == 1 else "1, 0, 0, 0, 1, 0, 0, 0, 1"
        lines.append(f'[node name="gate_facade_{idx}" type="Node3D" parent="Zone_C_Gate" unique_id={uid_counter} instance=ExtResource("{ext_id}")]')
        lines.append(f'transform = Transform3D({scale_mod}, {x}, {y}, {z})')
        lines.append('')
        uid_counter += 1

    # Twin Torches on gate
    torches = [
        (-2.2, 2.8, -21.6),
        (2.2, 2.8, -21.6)
    ]
    for idx, (x, y, z) in enumerate(torches):
        lines.append(f'[node name="gate_torch_{idx}" type="Node3D" parent="Zone_C_Gate" unique_id={uid_counter} instance=ExtResource("39_torch_lit")]')
        lines.append(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x}, {y}, {z})')
        lines.append('')
        uid_counter += 1
        lines.append(f'[node name="torch_light_{idx}" type="OmniLight3D" parent="Zone_C_Gate" unique_id={uid_counter}]')
        lines.append(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x}, {y + 0.3}, {z + 0.3})')
        lines.append('light_color = Color(1.0, 0.72, 0.35, 1)')
        lines.append('light_energy = 2.4')
        lines.append('omni_range = 8.0')
        lines.append('')
        uid_counter += 1

    # THE ANCIENT GATE DOOR (Area3D using door.gd)
    lines.append('[node name="Door_To_Level1" type="Area3D" parent="Zone_C_Gate" unique_id=13900]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.0, -22.0)')
    lines.append('script = ExtResource("7_doorscript")')
    lines.append('interaction_text = "Enter Level 1"')
    lines.append('interaction_title = "The Ancient Gate"')
    lines.append('description = "Step through the threshold into the ancient forest ruins (Level 1)."')
    lines.append('target_scene = "res://Scenes/Level/level_1.tscn"')
    lines.append('target_spawn_id = "Spawn_From_Map0"')
    lines.append('require_puzzle = false')
    lines.append('')
    lines.append('[node name="TriggerShape" type="CollisionShape3D" parent="Zone_C_Gate/Door_To_Level1" unique_id=13901]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.4, 0)')
    lines.append('shape = SubResource("Shape_door_trigger")')
    lines.append('')
    lines.append('[node name="InteractionLabel" type="Label3D" parent="Zone_C_Gate/Door_To_Level1" unique_id=13902]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.2, 0.6)')
    lines.append('')
    lines.append('[node name="PortalTitle" type="Label3D" parent="Zone_C_Gate/Door_To_Level1" unique_id=13903]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3.4, 0.3)')
    lines.append('modulate = Color(0.95, 0.85, 0.45, 1)')
    lines.append('text = "[ THE ANCIENT GATE ]"')
    lines.append('font_size = 28')
    lines.append('outline_size = 6')
    lines.append('')
    lines.append('[node name="PortalLight" type="OmniLight3D" parent="Zone_C_Gate/Door_To_Level1" unique_id=13904]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.8, 0.4)')
    lines.append('light_color = Color(1.0, 0.82, 0.45, 1)')
    lines.append('light_energy = 2.0')
    lines.append('omni_range = 7.0')
    lines.append('')

    # --- LORE INTERACTION PROPS ---
    # 1. Trail boundary milestone in Zone A
    lines.append('[node name="Inspect_TrailMarker" type="Area3D" parent="Zone_A_Trail" unique_id=11950]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 2.8, 0.0, 23.0)')
    lines.append('script = ExtResource("8_interactablescript")')
    lines.append('interaction_text = "Read"')
    lines.append('interaction_title = "Ancient Boundary Stone"')
    lines.append('description = "A moss-covered milestone carved with ancient glyphs: \'Beyond the overgrown path lies the entrance to the Forgotten Maze.\'"')
    lines.append('')
    lines.append('[node name="Col_TrailMarker" type="CollisionShape3D" parent="Zone_A_Trail/Inspect_TrailMarker" unique_id=11951]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.0, 0)')
    lines.append('shape = SubResource("Shape_inspect_trigger")')
    lines.append('')
    lines.append('[node name="InteractionLabel" type="Label3D" parent="Zone_A_Trail/Inspect_TrailMarker" unique_id=11952]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.8, 0)')
    lines.append('')

    # 2. Fallen Sentry Statue in Zone B
    lines.append('[node name="Inspect_RuinsRelic" type="Area3D" parent="Zone_B_Ruins" unique_id=12950]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -3.4, 0.0, 2.0)')
    lines.append('script = ExtResource("8_interactablescript")')
    lines.append('interaction_text = "Examine"')
    lines.append('interaction_title = "Fallen Sentry Statue"')
    lines.append('description = "A shattered stone guardian from an ancient kingdom. Moss fills the chisel marks across its carved shield."')
    lines.append('')
    lines.append('[node name="Col_RuinsRelic" type="CollisionShape3D" parent="Zone_B_Ruins/Inspect_RuinsRelic" unique_id=12951]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.0, 0)')
    lines.append('shape = SubResource("Shape_inspect_trigger")')
    lines.append('')
    lines.append('[node name="InteractionLabel" type="Label3D" parent="Zone_B_Ruins/Inspect_RuinsRelic" unique_id=12952]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.8, 0)')
    lines.append('')

    # 3. Gate Runes in Zone C
    lines.append('[node name="Inspect_GateRunes" type="Area3D" parent="Zone_C_Gate" unique_id=13950]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -3.2, 1.0, -20.5)')
    lines.append('script = ExtResource("8_interactablescript")')
    lines.append('interaction_text = "Read Inscription"')
    lines.append('interaction_title = "Threshold Inscription"')
    lines.append('description = "Carved deep into the archway stone: \'All who seek the mystery of the maze must pass this gate. May courage guide your steps.\'"')
    lines.append('')
    lines.append('[node name="Col_GateRunes" type="CollisionShape3D" parent="Zone_C_Gate/Inspect_GateRunes" unique_id=13951]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.0, 0)')
    lines.append('shape = SubResource("Shape_inspect_trigger")')
    lines.append('')
    lines.append('[node name="InteractionLabel" type="Label3D" parent="Zone_C_Gate/Inspect_GateRunes" unique_id=13952]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.8, 0)')
    lines.append('')

    # --- NATURE ASSETS: Dense framing trees, boulders, bushes, vegetation ---
    nature_assets = [
        # South start border trees
        (-6.0, 0, 31.0, "11_spruce", 1.4),
        (-2.0, 0, 32.0, "10_cypress", 1.3),
        (2.0, 0, 32.0, "11_spruce", 1.5),
        (6.0, 0, 31.0, "10_cypress", 1.4),
        (0.0, 0, 33.0, "14_boulder", 2.2),
        
        # West forest wall (Z: 28 down to -10)
        (-6.5, 0, 27.0, "10_cypress", 1.3),
        (-9.0, 0, 25.0, "11_spruce", 1.6),
        (-6.0, 0, 22.0, "12_birch", 1.2),
        (-8.5, 0, 19.0, "14_boulder", 1.8),
        (-6.5, 0, 15.0, "10_cypress", 1.4),
        (-9.0, 0, 12.0, "11_spruce", 1.5),
        (-7.0, 0, 8.0, "13_mistletoe", 1.2),
        (-10.0, 0, 4.0, "14_boulder", 2.0),
        (-8.0, 0, 0.0, "11_spruce", 1.6),
        (-7.5, 0, -5.0, "10_cypress", 1.5),
        (-10.5, 0, -10.0, "11_spruce", 1.7),
        (-11.0, 1.0, -16.0, "10_cypress", 1.4),
        (-11.5, 1.0, -22.0, "14_boulder", 2.2),

        # East forest wall (Z: 28 down to -10)
        (6.5, 0, 27.0, "11_spruce", 1.4),
        (9.0, 0, 25.0, "10_cypress", 1.5),
        (6.0, 0, 22.0, "13_mistletoe", 1.2),
        (8.5, 0, 19.0, "14_boulder", 1.9),
        (6.5, 0, 15.0, "12_birch", 1.3),
        (9.0, 0, 12.0, "11_spruce", 1.6),
        (7.0, 0, 8.0, "10_cypress", 1.4),
        (10.0, 0, 4.0, "14_boulder", 2.1),
        (8.0, 0, 0.0, "11_spruce", 1.5),
        (7.5, 0, -5.0, "12_birch", 1.3),
        (10.5, 0, -10.0, "10_cypress", 1.6),
        (11.0, 1.0, -16.0, "11_spruce", 1.7),
        (11.5, 1.0, -22.0, "14_boulder", 2.2),

        # Trail props: bushes, logs, stumps, rocks, shrooms
        (-3.5, 0, 26.0, "16_bush", 1.0),
        (3.5, 0, 25.0, "17_log", 1.0),
        (-3.2, 0, 21.0, "18_stump", 1.0),
        (3.4, 0, 21.0, "15_rock", 1.2),
        (-3.0, 0, 18.0, "19_shroom_red", 1.0),
        (-2.5, 0, 18.2, "20_shroom_brown", 1.0),
        (3.5, 0, 17.0, "16_bush", 1.0),
        (-3.8, 0, 14.0, "15_rock", 1.4),
        (3.6, 0, 13.0, "17_log", 1.0),
        (-3.5, 0, 9.0, "16_bush", 1.1),
        (3.8, 0, 8.0, "18_stump", 1.0),
        (-3.5, 0, 4.0, "19_shroom_red", 1.0),
        (3.6, 0, 3.5, "16_bush", 1.0),
        (-3.8, 0, -1.0, "15_rock", 1.3),
        (3.8, 0, -2.0, "20_shroom_brown", 1.0)
    ]
    
    for idx, (x, y, z, ext_id, scale_val) in enumerate(nature_assets):
        s = scale_val
        lines.append(f'[node name="nature_{idx}" type="Node3D" parent="Nature_Props" unique_id={uid_counter} instance=ExtResource("{ext_id}")]')
        lines.append(f'transform = Transform3D({s}, 0, 0, 0, {s}, 0, 0, 0, {s}, {x}, {y}, {z})')
        lines.append('')
        uid_counter += 1

    content = '\n'.join(lines)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Successfully generated map_0.tscn at {out_path} ({len(lines)} lines, {len(content)} bytes)')

if __name__ == '__main__':
    generate_map0()
