# Generator script for the complete Architectural Redesign of Level 1 (Sanctuary Hub)
# Designed as a grand, serene, beautifully lit ancient stone sanctuary with clear sightlines.

scene_content = """[gd_scene format=3 uid="uid://level_1_sanctuary_hub_v1"]

[ext_resource type="PackedScene" path="res://Scenes/Player/Player.tscn" id="1_player"]
[ext_resource type="Script" path="res://Scripts/player.gd" id="2_playerscript"]
[ext_resource type="PackedScene" path="res://Scenes/UI/InteractionUI.tscn" id="3_interactionui"]
[ext_resource type="Script" path="res://Scripts/interaction_ui.gd" id="4_uiscript"]
[ext_resource type="PackedScene" path="res://Scenes/UI/HUD.tscn" id="5_hud"]
[ext_resource type="Script" path="res://Scripts/UI/hud.gd" id="6_hudscript"]
[ext_resource type="Script" path="res://Scripts/door.gd" id="7_doorscript"]
[ext_resource type="PackedScene" path="res://Scenes/FinalDoor.tscn" id="8_finaldoorscene"]
[ext_resource type="Script" path="res://Scripts/relic_altar.gd" id="9_relicaltarscript"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_tile_large.gltf" id="10_floor_tile"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_tile_large_rocks.gltf" id="11_floor_rocky"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_foundation_allsides.gltf" id="12_floor_foundation"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_tile_small_decorated.gltf" id="13_floor_decorated"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall.gltf" id="14_wall"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_arched.gltf" id="15_wall_arched"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_pillar.gltf" id="16_wall_pillar"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_doorway.gltf" id="17_wall_doorway"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_broken.gltf" id="18_wall_broken"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_cracked.gltf" id="19_wall_cracked"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/pillar_decorated.gltf" id="20_pillar_decorated"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/column.gltf" id="21_column"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/torch_lit.gltf" id="22_torch_lit"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/candle_triple.gltf" id="23_candle_triple"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/table_small_decorated_A.gltf" id="24_altar_table"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/chest_gold.gltf" id="25_relic_chest"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/banner_shield_blue.gltf" id="26_banner_shield"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/banner_patternA_blue.gltf" id="27_banner_pattern"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/barrel_large.gltf" id="28_barrel"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/crates_stacked.gltf" id="29_crates"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/rubble_large.gltf" id="30_rubble_large"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/rubble_half.gltf" id="31_rubble_half"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/sword_shield.gltf" id="32_sword_shield"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/ceiling_tile.gltf" id="33_ceiling_tile"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/banner_patternA_yellow.gltf" id="34_banner_gold"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/shelf_small_candles.gltf" id="35_shelf_candles"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/table_medium_decorated_A.gltf" id="36_side_table"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/chair.gltf" id="37_chair"]

[sub_resource type="Environment" id="Env_sanctuary"]
background_mode = 0
background_color = Color(0.018, 0.02, 0.03, 1)
ambient_light_source = 2
ambient_light_color = Color(0.28, 0.32, 0.44, 1)
ambient_light_energy = 1.35
tonemap_mode = 3
fog_enabled = true
fog_light_color = Color(0.12, 0.15, 0.24, 1)
fog_density = 0.016
fog_depth_begin = 8.0
fog_depth_end = 45.0

[sub_resource type="StandardMaterial3D" id="Mat_dungeon_stone"]
albedo_color = Color(0.24, 0.25, 0.28, 1)
roughness = 0.9

[sub_resource type="StandardMaterial3D" id="Mat_sanctuary_carpet"]
albedo_color = Color(0.16, 0.20, 0.30, 1)
roughness = 0.85

[sub_resource type="StandardMaterial3D" id="Mat_altar_carpet"]
albedo_color = Color(0.42, 0.32, 0.12, 1)
roughness = 0.75

[sub_resource type="BoxMesh" id="Mesh_floor_base"]
material = SubResource("Mat_dungeon_stone")
size = Vector3(28, 1, 38)

[sub_resource type="BoxShape3D" id="Shape_floor_base"]
size = Vector3(28, 1, 38)

[sub_resource type="BoxShape3D" id="Shape_altar_trigger"]
size = Vector3(3.4, 2.4, 3.4)

[sub_resource type="BoxShape3D" id="Shape_altar_solid"]
size = Vector3(1.6, 1.0, 1.6)

[sub_resource type="BoxShape3D" id="Shape_door2_trigger"]
size = Vector3(3.0, 2.8, 1.6)

[sub_resource type="BoxShape3D" id="Shape_inv_wall_ns"]
size = Vector3(28, 12, 1)

[sub_resource type="BoxShape3D" id="Shape_inv_wall_ew"]
size = Vector3(1, 12, 38)

[sub_resource type="BoxMesh" id="Mesh_central_runner"]
material = SubResource("Mat_sanctuary_carpet")
size = Vector3(3.8, 0.02, 28.0)

[sub_resource type="BoxMesh" id="Mesh_altar_runner"]
material = SubResource("Mat_altar_carpet")
size = Vector3(4.8, 0.025, 4.8)

[node name="Level_1" type="Node3D"]

[node name="WorldEnvironment" type="WorldEnvironment" parent="." unique_id=10001]
environment = SubResource("Env_sanctuary")

[node name="SanctuaryLight" type="DirectionalLight3D" parent="." unique_id=10002]
transform = Transform3D(0.866, 0.354, -0.354, 0, 0.707, 0.707, 0.5, -0.612, 0.612, 0, 18, 0)
light_color = Color(0.68, 0.76, 0.94, 1)
light_energy = 0.65
shadow_enabled = true

[node name="GroundBase" type="StaticBody3D" parent="." unique_id=10003]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, -7)

[node name="MeshInstance3D" type="MeshInstance3D" parent="GroundBase" unique_id=10004]
mesh = SubResource("Mesh_floor_base")

[node name="CollisionShape3D" type="CollisionShape3D" parent="GroundBase" unique_id=10005]
shape = SubResource("Shape_floor_base")

[node name="InvisibleWalls" type="StaticBody3D" parent="." unique_id=10006]

[node name="Wall_South" type="CollisionShape3D" parent="InvisibleWalls" unique_id=10007]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 6, 11)
shape = SubResource("Shape_inv_wall_ns")

[node name="Wall_North" type="CollisionShape3D" parent="InvisibleWalls" unique_id=10008]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 6, -25)
shape = SubResource("Shape_inv_wall_ns")

[node name="Wall_West" type="CollisionShape3D" parent="InvisibleWalls" unique_id=10009]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -13, 6, -7)
shape = SubResource("Shape_inv_wall_ew")

[node name="Wall_East" type="CollisionShape3D" parent="InvisibleWalls" unique_id=10010]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 13, 6, -7)
shape = SubResource("Shape_inv_wall_ew")

[node name="Spawn_From_Map0" type="Marker3D" parent="." unique_id=987654321]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.2, 6)

[node name="Spawn_From_Level0" type="Marker3D" parent="." unique_id=987654322]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.2, 6)

[node name="Spawn_From_Level1" type="Marker3D" parent="." unique_id=208036464]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.2, 6)

[node name="Spawn_From_Level2" type="Marker3D" parent="." unique_id=1277896878]
transform = Transform3D(-1, 0, -8.742278e-08, 0, 1, 0, 8.742278e-08, 0, -1, 5.0, 0.2, -18.0)

[node name="Spawn_From_Level8" type="Marker3D" parent="." unique_id=2080090965]
transform = Transform3D(-1, 0, -8.742278e-08, 0, 1, 0, 8.742278e-08, 0, -1, 0.0, 0.2, -15.0)

[node name="Player" type="CharacterBody3D" parent="." unique_id=263796391 groups=["player"] instance=ExtResource("1_player")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.2, 6)
script = ExtResource("2_playerscript")

[node name="InteractionUI" type="CanvasLayer" parent="." unique_id=929617552 groups=["interaction_ui"] instance=ExtResource("3_interactionui")]
script = ExtResource("4_uiscript")

[node name="HUD" type="CanvasLayer" parent="." unique_id=1499615655 instance=ExtResource("5_hud")]
process_mode = 3
script = ExtResource("6_hudscript")

[node name="Sanctuary_Floor" type="Node3D" parent="." unique_id=11000]

[node name="Sanctuary_Walls" type="Node3D" parent="." unique_id=12000]

[node name="Sanctuary_Pillars" type="Node3D" parent="." unique_id=13000]

[node name="Sanctuary_Lights" type="Node3D" parent="." unique_id=14000]

[node name="Sanctuary_Props" type="Node3D" parent="." unique_id=15000]

[node name="Sanctuary_Ceilings" type="Node3D" parent="." unique_id=16000]
"""

# Floor Grid (48 tiles)
floor_tiles = []
uid_counter = 20000

xs = [-10, -6, -2, 2, 6, 10]
zs = [8, 4, 0, -4, -8, -12, -16, -20]

for x in xs:
    for z in zs:
        res = "10_floor_tile"
        if x in [-2, 2] and z in [4, 0, -4, -8, -12]:
            res = "13_floor_decorated"
        elif x == 0 and z in [-8, -12]:
            res = "13_floor_decorated"
        elif abs(x) == 10 and z in [-4, -16]:
            res = "11_floor_rocky"
            
        tile_str = f"""[node name="floor_{x}_{z}" type="Node3D" parent="Sanctuary_Floor" unique_id={uid_counter} instance=ExtResource("{res}")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x}, 0, {z})
"""
        floor_tiles.append(tile_str)
        uid_counter += 1

# Floor runners (Subtle stone carpets)
runners = f"""[node name="CentralStoneRunner" type="MeshInstance3D" parent="Sanctuary_Floor" unique_id={uid_counter}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.005, -5)
mesh = SubResource("Mesh_central_runner")

[node name="AltarSanctumRunner" type="MeshInstance3D" parent="Sanctuary_Floor" unique_id={uid_counter + 1}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.0, 0.01, -10.0)
mesh = SubResource("Mesh_altar_runner")
"""
uid_counter += 2

# Sanctuary Walls (Perimeter)
walls = []

# South walls (z = 10, facing North)
south_defs = [
    (-10, "14_wall"),
    (-6, "15_wall_arched"),
    (-2, "16_wall_pillar"),
    (0, "17_wall_doorway"), # Main entrance
    (2, "16_wall_pillar"),
    (6, "15_wall_arched"),
    (10, "14_wall"),
]
for i, (x, res) in enumerate(south_defs):
    w_str = f"""[node name="wall_s_{i}" type="Node3D" parent="Sanctuary_Walls" unique_id={uid_counter} instance=ExtResource("{res}")]
transform = Transform3D(-1, 0, -8.742278e-08, 0, 1, 0, 8.742278e-08, 0, -1, {x}, 0, 10)
"""
    walls.append(w_str)
    uid_counter += 1

# North walls (z = -22, facing South)
north_defs = [
    (-10, "14_wall"),
    (-6, "17_wall_doorway"), # Final Door frame
    (-2, "15_wall_arched"),
    (0, "16_wall_pillar"),
    (2, "15_wall_arched"),
    (6, "17_wall_doorway"), # Level 2 Door frame
    (10, "14_wall"),
]
for i, (x, res) in enumerate(north_defs):
    w_str = f"""[node name="wall_n_{i}" type="Node3D" parent="Sanctuary_Walls" unique_id={uid_counter} instance=ExtResource("{res}")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x}, 0, -22)
"""
    walls.append(w_str)
    uid_counter += 1

# West walls (x = -12, facing East: rot_y = -90)
west_defs = [
    (8, "14_wall"),
    (4, "15_wall_arched"),
    (0, "16_wall_pillar"),
    (-4, "15_wall_arched"),
    (-8, "15_wall_arched"),
    (-12, "15_wall_arched"),
    (-16, "16_wall_pillar"),
    (-20, "14_wall"),
]
for z, res in west_defs:
    w_str = f"""[node name="wall_w_{z}" type="Node3D" parent="Sanctuary_Walls" unique_id={uid_counter} instance=ExtResource("{res}")]
transform = Transform3D(-4.371139e-08, 0, 1, 0, 1, 0, -1, 0, -4.371139e-08, -12, 0, {z})
"""
    walls.append(w_str)
    uid_counter += 1

# East walls (x = 12, facing West: rot_y = 90)
east_defs = [
    (8, "14_wall"),
    (4, "15_wall_arched"),
    (0, "16_wall_pillar"),
    (-4, "15_wall_arched"),
    (-8, "15_wall_arched"),
    (-12, "19_wall_cracked"),
    (-16, "16_wall_pillar"),
    (-20, "14_wall"),
]
for z, res in east_defs:
    w_str = f"""[node name="wall_e_{z}" type="Node3D" parent="Sanctuary_Walls" unique_id={uid_counter} instance=ExtResource("{res}")]
transform = Transform3D(-4.371139e-08, 0, -1, 0, 1, 0, 1, 0, -4.371139e-08, 12, 0, {z})
"""
    walls.append(w_str)
    uid_counter += 1

# Pillars (Spacious layout: wide nave opening 10m wide!)
pillars = []
pillar_defs = [
    # Wide nave colonnade (x = -5.0 and +5.0)
    (-5.0, 3.0), (5.0, 3.0),
    (-5.0, -4.0), (5.0, -4.0),
    (-5.0, -15.0), (5.0, -15.0),
]
for px, pz in pillar_defs:
    p_str = f"""[node name="pillar_{'w' if px < 0 else 'e'}_{int(pz)}" type="Node3D" parent="Sanctuary_Pillars" unique_id={uid_counter} instance=ExtResource("20_pillar_decorated")]
transform = Transform3D(1.15, 0, 0, 0, 1.15, 0, 0, 0, 1.15, {px}, 0, {pz})
"""
    pillars.append(p_str)
    uid_counter += 1

# Terminus and Altar shrine pillars
shrine_pillars = f"""[node name="terminus_pillar_left" type="Node3D" parent="Sanctuary_Pillars" unique_id={uid_counter} instance=ExtResource("20_pillar_decorated")]
transform = Transform3D(1.2, 0, 0, 0, 1.2, 0, 0, 0, 1.2, -2.5, 0, -19.0)

[node name="terminus_pillar_right" type="Node3D" parent="Sanctuary_Pillars" unique_id={uid_counter + 1} instance=ExtResource("20_pillar_decorated")]
transform = Transform3D(1.2, 0, 0, 0, 1.2, 0, 0, 0, 1.2, 2.5, 0, -19.0)

[node name="altar_col_fl" type="Node3D" parent="Sanctuary_Pillars" unique_id={uid_counter + 2} instance=ExtResource("21_column")]
transform = Transform3D(0.9, 0, 0, 0, 0.9, 0, 0, 0, 0.9, -2.2, 0, -8.2)

[node name="altar_col_fr" type="Node3D" parent="Sanctuary_Pillars" unique_id={uid_counter + 3} instance=ExtResource("21_column")]
transform = Transform3D(0.9, 0, 0, 0, 0.9, 0, 0, 0, 0.9, 2.2, 0, -8.2)

[node name="altar_col_bl" type="Node3D" parent="Sanctuary_Pillars" unique_id={uid_counter + 4} instance=ExtResource("21_column")]
transform = Transform3D(0.9, 0, 0, 0, 0.9, 0, 0, 0, 0.9, -2.2, 0, -11.8)

[node name="altar_col_br" type="Node3D" parent="Sanctuary_Pillars" unique_id={uid_counter + 5} instance=ExtResource("21_column")]
transform = Transform3D(0.9, 0, 0, 0, 0.9, 0, 0, 0, 0.9, 2.2, 0, -11.8)
"""
uid_counter += 6

# Sanctuary Lights (Warm Golden Torches & Balanced Ambient)
lights = []
torch_defs = [
    # South entrance
    (-2.2, 2.4, 9.5),
    (2.2, 2.4, 9.5),
    # Wide nave colonnade torches
    (-5.0, 2.6, 3.0),
    (5.0, 2.6, 3.0),
    (-5.0, 2.6, -4.0),
    (5.0, 2.6, -4.0),
    (-5.0, 2.6, -15.0),
    (5.0, 2.6, -15.0),
    # North Gates
    (-4.2, 2.4, -21.4), # Final Door left
    (-7.8, 2.4, -21.4), # Final Door right
    (4.2, 2.4, -21.4),  # Level 2 Door left
    (7.8, 2.4, -21.4),  # Level 2 Door right
]

for idx, (tx, ty, tz) in enumerate(torch_defs):
    t_str = f"""[node name="torch_{idx}" type="Node3D" parent="Sanctuary_Lights" unique_id={uid_counter} instance=ExtResource("22_torch_lit")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {tx}, {ty}, {tz})

[node name="light_{idx}" type="OmniLight3D" parent="Sanctuary_Lights" unique_id={uid_counter + 1}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {tx}, {ty + 0.45}, {tz})
light_color = Color(1.0, 0.78, 0.42, 1)
light_energy = 2.4
shadow_enabled = true
omni_range = 8.5
"""
    lights.append(t_str)
    uid_counter += 2

# Special Aura, Gate Lights & Ambient Fill Lights
special_lights = f"""[node name="AltarSacredGlow" type="OmniLight3D" parent="Sanctuary_Lights" unique_id={uid_counter}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.0, 2.5, -10.0)
light_color = Color(1.0, 0.90, 0.48, 1)
light_energy = 3.8
shadow_enabled = true
omni_range = 9.0

[node name="FinalDoorGlow" type="OmniLight3D" parent="Sanctuary_Lights" unique_id={uid_counter + 1}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -6.0, 2.4, -20.5)
light_color = Color(0.20, 0.75, 1.0, 1)
light_energy = 3.2
shadow_enabled = true
omni_range = 8.5

[node name="SanctuaryNaveLight" type="OmniLight3D" parent="Sanctuary_Lights" unique_id={uid_counter + 2}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.0, 3.8, 0.0)
light_color = Color(0.85, 0.88, 1.0, 1)
light_energy = 1.4
omni_range = 16.0

[node name="SanctuaryNorthLight" type="OmniLight3D" parent="Sanctuary_Lights" unique_id={uid_counter + 3}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.0, 3.8, -17.0)
light_color = Color(0.85, 0.88, 1.0, 1)
light_energy = 1.4
omni_range = 16.0
"""
uid_counter += 4

# Sanctuary Props (Varied, natural, non-repetitive)
props = f"""[node name="AltarDais" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter} instance=ExtResource("12_floor_foundation")]
transform = Transform3D(1.1, 0, 0, 0, 1.0, 0, 0, 0, 1.1, 0.0, 0, -10.0)

[node name="AltarCandlesLeft" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 1} instance=ExtResource("23_candle_triple")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -1.4, 0.0, -10.0)

[node name="AltarCandlesRight" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 2} instance=ExtResource("23_candle_triple")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 1.4, 0.0, -10.0)

[node name="AltarGoldBanner" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 3} instance=ExtResource("34_banner_gold")]
transform = Transform3D(1.2, 0, 0, 0, 1.2, 0, 0, 0, 1.2, 0.0, 2.6, -11.9)

[node name="Door2SignBanner" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 4} instance=ExtResource("34_banner_gold")]
transform = Transform3D(1.0, 0, 0, 0, 1.0, 0, 0, 0, 1.0, 6.0, 2.6, -21.7)

[node name="FinalDoorBanner" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 5} instance=ExtResource("27_banner_pattern")]
transform = Transform3D(1.1, 0, 0, 0, 1.1, 0, 0, 0, 1.1, -6.0, 2.6, -21.7)

[node name="FinalDoorShield" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 6} instance=ExtResource("26_banner_shield")]
transform = Transform3D(1.15, 0, 0, 0, 1.15, 0, 0, 0, 1.15, -6.0, 3.2, -21.7)

[node name="banner_left" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 7} instance=ExtResource("27_banner_pattern")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -2.0, 2.2, -18.8)

[node name="banner_right" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 8} instance=ExtResource("27_banner_pattern")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 2.0, 2.2, -18.8)

[node name="shield_left" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 9} instance=ExtResource("26_banner_shield")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -1.8, 2.4, 9.8)

[node name="shield_right" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 10} instance=ExtResource("26_banner_shield")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 1.8, 2.4, 9.8)

[node name="prop_0" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 11} instance=ExtResource("28_barrel")]
transform = Transform3D(1.1, 0, 0, 0, 1.1, 0, 0, 0, 1.1, -10.5, 0, 8.5)

[node name="prop_1" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 12} instance=ExtResource("29_crates")]
transform = Transform3D(1.0, 0, 0, 0, 1.0, 0, 0, 0, 1.0, -9.5, 0, 8.5)

[node name="prop_2" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 13} instance=ExtResource("28_barrel")]
transform = Transform3D(1.1, 0, 0, 0, 1.1, 0, 0, 0, 1.1, 10.5, 0, 8.5)

[node name="prop_3" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 14} instance=ExtResource("29_crates")]
transform = Transform3D(1.0, 0, 0, 0, 1.0, 0, 0, 0, 1.0, 9.5, 0, 8.5)

[node name="prop_4" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 15} instance=ExtResource("30_rubble_large")]
transform = Transform3D(1.2, 0, 0, 0, 1.2, 0, 0, 0, 1.2, -10.5, 0, -19.5)

[node name="prop_5" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 16} instance=ExtResource("31_rubble_half")]
transform = Transform3D(1.1, 0, 0, 0, 1.1, 0, 0, 0, 1.1, 10.5, 0, -19.5)

[node name="prop_6" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 17} instance=ExtResource("32_sword_shield")]
transform = Transform3D(1.0, 0, 0, 0, 1.0, 0, 0, 0, 1.0, 10.5, 0, -12.0)

[node name="sanctuary_shelf_w" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 18} instance=ExtResource("35_shelf_candles")]
transform = Transform3D(-4.371139e-08, 0, 1, 0, 1, 0, -1, 0, -4.371139e-08, -11.6, 1.2, -4.0)

[node name="sanctuary_side_table_e" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 19} instance=ExtResource("36_side_table")]
transform = Transform3D(-4.371139e-08, 0, -1, 0, 1, 0, 1, 0, -4.371139e-08, 10.5, 0, -4.0)

[node name="sanctuary_chair_e" type="Node3D" parent="Sanctuary_Props" unique_id={uid_counter + 20} instance=ExtResource("37_chair")]
transform = Transform3D(-0.7071, 0, -0.7071, 0, 1, 0, 0.7071, 0, -0.7071, 9.2, 0, -3.8)
"""
uid_counter += 21

# Ceilings (High Vaulted at Y = 5.6m)
ceilings = []
ceiling_uid = 30001
for x in xs:
    for z in zs:
        c_str = f"""[node name="ceiling_{x}_{z}" type="Node3D" parent="Sanctuary_Ceilings" unique_id={ceiling_uid} instance=ExtResource("33_ceiling_tile")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x}, 5.6, {z})
"""
        ceilings.append(c_str)
        ceiling_uid += 1

# Interactive Components (RelicAltar at center, Doors with distinctive cues)
interactives = f"""[node name="RelicAltar" type="Area3D" parent="." unique_id=198877665]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.0, 0.0, -10.0)
script = ExtResource("9_relicaltarscript")
interaction_text = "Place Relic"
interaction_title = "Altar of the Sovereign"

[node name="AltarMesh" parent="RelicAltar" unique_id=198877666 instance=ExtResource("24_altar_table")]
transform = Transform3D(1.25, 0, 0, 0, 1.25, 0, 0, 0, 1.25, 0, 0, 0)

[node name="CollisionShape3D" type="CollisionShape3D" parent="RelicAltar" unique_id=198877667]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.0, 0)
shape = SubResource("Shape_altar_trigger")

[node name="InteractionLabel" type="Label3D" parent="RelicAltar" unique_id=198877668]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.1, 0)
visible = false
billboard = 1
modulate = Color(1, 0.94, 0.52, 1)

[node name="RelicVisual" parent="RelicAltar" unique_id=198877669 instance=ExtResource("25_relic_chest")]
transform = Transform3D(0.95, 0, 0, 0, 0.95, 0, 0, 0, 0.95, 0, 0.88, 0)
visible = false

[node name="StaticBody3D" type="StaticBody3D" parent="RelicAltar" unique_id=198877671]

[node name="TableCol" type="CollisionShape3D" parent="RelicAltar/StaticBody3D" unique_id=198877672]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.5, 0)
shape = SubResource("Shape_altar_solid")

[node name="FinalDoor" parent="." unique_id=198877670 instance=ExtResource("8_finaldoorscene")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -6.0, 0.0, -21.4)

[node name="Door_To_Level2" type="Area3D" parent="." unique_id=1327668518]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 6.0, 0.0, -21.4)
script = ExtResource("7_doorscript")
interaction_text = "Enter Level 2"
target_scene = "res://Scenes/Level/level_2.tscn"
target_spawn_id = "Spawn_From_Level1"

[node name="TriggerShape" type="CollisionShape3D" parent="Door_To_Level2" unique_id=1431421115]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.4, 0.2)
shape = SubResource("Shape_door2_trigger")

[node name="InteractionLabel" type="Label3D" parent="Door_To_Level2" unique_id=20121]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.8, 0.6)
visible = false
billboard = 1

[node name="Door2Glow" type="OmniLight3D" parent="Door_To_Level2" unique_id=20122]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.0, 0.3)
light_color = Color(1.0, 0.74, 0.22, 1)
light_energy = 2.8
omni_range = 7.5
"""

full_scene = scene_content + "\n"
full_scene += "\n".join(floor_tiles) + "\n"
full_scene += runners + "\n"
full_scene += "\n".join(walls) + "\n"
full_scene += "\n".join(pillars) + "\n"
full_scene += shrine_pillars + "\n"
full_scene += "\n".join(lights) + "\n"
full_scene += special_lights + "\n"
full_scene += props + "\n"
full_scene += "\n".join(ceilings) + "\n"
full_scene += interactives + "\n"

with open("Scenes/Level/level_1.tscn", "w", encoding="utf-8") as f:
    f.write(full_scene)

print("level_1.tscn redesign completed successfully!")
