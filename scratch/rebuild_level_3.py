# Complete architectural reconstruction of Level 3: Crypt of Shadows
# Features:
# 1. Central Burial Nave (Z = 16 to -18, X = -4 to +4)
# 2. Western Catacombs Labyrinth (X = -8 to -20, Z = 6 to -14)
# 3. Eastern Royal Crypt Treasury (X = 8 to 20, Z = 6 to -14)
# 4. Spike Traps with audio-visual cues and avoidance bypasses
# 5. Clear portal routes: Door_To_Level2 (South at Z=18) and Door_To_Level4 (North at Z=-20)
# 6. Low-Poly Dark Fantasy Crypt Atmosphere: PSX cold blue fog + warm torchlight highlights

class Color:
    def __init__(self, r, g, b):
        self.r = r
        self.g = g
        self.b = b

scene_header = """[gd_scene format=3]

[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_tile_large.gltf" id="1_floor_tile"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_dirt_large_rocky.gltf" id="2_floor_dirt"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_tile_large_rocks.gltf" id="3_floor_rocks"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_tile_big_grate.gltf" id="4_floor_grate"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_cracked.gltf" id="5_wall_cracked"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall.gltf" id="6_wall"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_pillar.gltf" id="7_wall_pillar"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_open_scaffold.gltf" id="8_wall_scaffold"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_arched.gltf" id="9_wall_arched"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_doorway_scaffold.gltf" id="10_wall_doorway"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/wall_archedwindow_gated.gltf" id="11_wall_window"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/pillar.gltf" id="12_pillar"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/pillar_decorated.gltf" id="13_pillar_dec"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/ceiling_tile.gltf" id="14_ceiling_tile"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/candle_lit.gltf" id="15_candle_lit"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/barrier_half.gltf" id="16_barrier_half"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/banner_red.gltf" id="17_banner_red"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/rubble_half.gltf" id="18_rubble_half"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/candle_triple.gltf" id="19_candle_triple"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/table_long_tablecloth_decorated_A.gltf" id="20_tomb_table"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/sword_shield.gltf" id="21_sword_shield"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/rubble_large.gltf" id="22_rubble_large"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/barrier.gltf" id="23_barrier"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/sword_shield_broken.gltf" id="24_sword_broken"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/chest.gltf" id="25_chest"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/chest_gold.gltf" id="26_chest_gold"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/coin_stack_large.gltf" id="27_coin_stack"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/crates_stacked.gltf" id="28_crates"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/barrel_large.gltf" id="29_barrel"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/table_medium_decorated_A.gltf" id="30_table_med"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/banner_shield_red.gltf" id="31_banner_shield"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/torch_mounted.gltf" id="32_torch_mounted"]
[ext_resource type="PackedScene" path="res://Scenes/Player/Player.tscn" id="33_player"]
[ext_resource type="Script" path="res://Scripts/player.gd" id="34_playerscript"]
[ext_resource type="PackedScene" path="res://Scenes/UI/InteractionUI.tscn" id="35_interactionui"]
[ext_resource type="Script" path="res://Scripts/interaction_ui.gd" id="36_uiscript"]
[ext_resource type="PackedScene" path="res://Scenes/UI/HUD.tscn" id="37_hud"]
[ext_resource type="Script" path="res://Scripts/UI/hud.gd" id="38_hudscript"]
[ext_resource type="Script" path="res://Scripts/interactable.gd" id="39_interactable"]
[ext_resource type="Script" path="res://Scripts/door.gd" id="40_doorscript"]
[ext_resource type="PackedScene" path="res://Assets/ThirdParty/KayKitDungeon/Assets/gltf/floor_tile_big_spikes.gltf" id="41_spike_trap_mesh"]
[ext_resource type="Script" path="res://Scripts/crypt_spike_trap.gd" id="42_trap_script"]

[sub_resource type="BoxShape3D" id="BoxShape3D_floor_base"]
size = Vector3(64, 1, 64)

[sub_resource type="StandardMaterial3D" id="StandardMaterial3D_crypt_stone"]
albedo_color = Color(0.12, 0.12, 0.15, 1)
roughness = 0.95

[sub_resource type="BoxMesh" id="BoxMesh_floor_base"]
material = SubResource("StandardMaterial3D_crypt_stone")
size = Vector3(64, 1, 64)

[sub_resource type="Environment" id="Env_crypt"]
background_mode = 0
background_color = Color(0.012, 0.015, 0.022, 1)
ambient_light_source = 2
ambient_light_color = Color(0.18, 0.22, 0.35, 1)
ambient_light_energy = 1.15
tonemap_mode = 3
fog_enabled = true
fog_light_color = Color(0.08, 0.11, 0.20, 1)
fog_density = 0.024
fog_depth_begin = 6.0
fog_depth_end = 42.0

[sub_resource type="BoxShape3D" id="Shape_door_trigger"]
size = Vector3(3.0, 3.2, 2.0)

[sub_resource type="BoxShape3D" id="Shape_inspect_trigger"]
size = Vector3(2.5, 2.2, 2.5)

[sub_resource type="BoxShape3D" id="Shape_trap_trigger"]
size = Vector3(3.6, 1.2, 3.6)

[sub_resource type="BoxShape3D" id="Shape_wall_h"]
size = Vector3(4.0, 4.0, 1.0)

[sub_resource type="BoxShape3D" id="Shape_wall_v"]
size = Vector3(1.0, 4.0, 4.0)

[node name="Level3" type="Node3D" unique_id=457837464]
metadata/dialogue_id = "level_3_intro"

[node name="WorldEnvironment" type="WorldEnvironment" parent="." unique_id=1718691854]
environment = SubResource("Env_crypt")

[node name="DirectionalLight3D" type="DirectionalLight3D" parent="." unique_id=1688811775]
transform = Transform3D(0.819, -0.47, 0.329, 0, 0.574, 0.819, -0.574, -0.671, 0.47, 0, 16, 0)
light_color = Color(0.55, 0.65, 0.90, 1)
light_energy = 0.45
shadow_enabled = true

[node name="Floor" type="StaticBody3D" parent="." unique_id=1277357133]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)

[node name="CollisionShape3D" type="CollisionShape3D" parent="Floor" unique_id=1535086322]
shape = SubResource("BoxShape3D_floor_base")

[node name="MeshInstance3D" type="MeshInstance3D" parent="Floor" unique_id=527075095]
mesh = SubResource("BoxMesh_floor_base")

[node name="Spawn_From_Level2" type="Marker3D" parent="." unique_id=987000301]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.2, 16)

[node name="PlayerSpawn" type="Marker3D" parent="." unique_id=987000302]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.2, 16)

[node name="Spawn_From_Level4" type="Marker3D" parent="." unique_id=1938962580]
transform = Transform3D(-1, 0, -8.742278e-08, 0, 1, 0, 8.742278e-08, 0, -1, 0, 0.2, -17.5)

[node name="Exit" type="Marker3D" parent="." unique_id=611811646]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.2, -20)

[node name="Player" type="CharacterBody3D" parent="." unique_id=263796391 groups=["player"] instance=ExtResource("33_player")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.2, 16)
script = ExtResource("34_playerscript")

[node name="InteractionUI" type="CanvasLayer" parent="." unique_id=929617552 groups=["interaction_ui"] instance=ExtResource("35_interactionui")]
script = ExtResource("36_uiscript")

[node name="HUD" type="CanvasLayer" parent="." unique_id=1499615655 instance=ExtResource("37_hud")]
process_mode = 3
script = ExtResource("38_hudscript")

[node name="KayKitDungeon" type="Node3D" parent="." unique_id=236430169]

[node name="Floors" type="Node3D" parent="KayKitDungeon" unique_id=737507704]

[node name="Walls" type="Node3D" parent="KayKitDungeon" unique_id=1630138902]

[node name="Pillars" type="Node3D" parent="KayKitDungeon" unique_id=300000001]

[node name="Torches" type="Node3D" parent="KayKitDungeon" unique_id=1843516599]

[node name="Props" type="Node3D" parent="KayKitDungeon" unique_id=892550186]

[node name="Ceilings" type="Node3D" parent="KayKitDungeon" unique_id=300000002]

[node name="Traps" type="Node3D" parent="." unique_id=300000003]

[node name="WallCollisions" type="StaticBody3D" parent="." unique_id=300000004]
"""

# Let's define the Map Grid
# Central Nave: X in [-4, 0, 4], Z from 16 down to -20
# West Labyrinth: X in [-16, -12, -8], Z from 4 down to -12
# East Treasury: X in [8, 12, 16], Z from 4 down to -12
# West Hallway link: X = -8, Z = 0
# East Hallway link: X = 8, Z = 0

floor_tiles = []
uid = 500000

# Central Nave floors
central_xs = [-4, 0, 4]
central_zs = [16, 12, 8, 4, 0, -4, -8, -12, -16, -20]

# West Labyrinth floors
west_xs = [-16, -12, -8]
west_zs = [4, 0, -4, -8, -12]

# East Treasury floors
east_xs = [8, 12, 16]
east_zs = [4, 0, -4, -8, -12]

all_floor_coords = []
for z in central_zs:
    for x in central_xs:
        all_floor_coords.append((x, z, "central"))

for z in west_zs:
    for x in west_xs:
        if (x, z) not in [(c[0], c[1]) for c in all_floor_coords]:
            all_floor_coords.append((x, z, "west"))

for z in east_zs:
    for x in east_xs:
        if (x, z) not in [(c[0], c[1]) for c in all_floor_coords]:
            all_floor_coords.append((x, z, "east"))

for x, z, zone in all_floor_coords:
    # Tile variations
    res = "1_floor_tile"
    if zone == "west":
        res = "2_floor_dirt" if (abs(x + z) % 8 == 0) else "3_floor_rocks"
    elif zone == "east":
        res = "1_floor_tile" if (x == 16 and z == -4) else "3_floor_rocks"
    else:
        # central
        if z in [0, -4] and x == 0:
            res = "4_floor_grate"
        elif abs(z) % 8 == 0:
            res = "3_floor_rocks"
            
    f_str = f"""[node name="floor_{x}_{z}" type="Node3D" parent="KayKitDungeon/Floors" unique_id={uid} instance=ExtResource("{res}")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x}, 0, {z})
"""
    floor_tiles.append(f_str)
    uid += 1

# Wall Layout & Collisions
walls = []
wall_cols = []

def add_wall(x, z, rot_y_deg, res, col_shape="h"):
    global uid
    rot_str = "1, 0, 0, 0, 1, 0, 0, 0, 1"
    if rot_y_deg == 90:
        rot_str = "-4.371139e-08, 0, -1, 0, 1, 0, 1, 0, -4.371139e-08"
    elif rot_y_deg == -90 or rot_y_deg == 270:
        rot_str = "-4.371139e-08, 0, 1, 0, 1, 0, -1, 0, -4.371139e-08"
    elif rot_y_deg == 180:
        rot_str = "-1, 0, -8.742278e-08, 0, 1, 0, 8.742278e-08, 0, -1"
        
    w_node = f"""[node name="wall_{x}_{z}_{rot_y_deg}" type="Node3D" parent="KayKitDungeon/Walls" unique_id={uid} instance=ExtResource("{res}")]
transform = Transform3D({rot_str}, {x}, 0, {z})
"""
    walls.append(w_node)
    uid += 1
    
    shape_ref = "Shape_wall_h" if col_shape == "h" else "Shape_wall_v"
    c_node = f"""[node name="col_{x}_{z}_{rot_y_deg}" type="CollisionShape3D" parent="WallCollisions" unique_id={uid}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x}, 2.0, {z})
shape = SubResource("{shape_ref}")
"""
    wall_cols.append(c_node)
    uid += 1

# Perimeter and Room Walls:
# 1. South Entrance Wall (Z = 18): doorway at X=0, walls at -4, +4
add_wall(-4, 18, 180, "6_wall", "h")
add_wall(0, 18, 180, "10_wall_doorway", "h") # Door to level 2
add_wall(4, 18, 180, "6_wall", "h")

# 2. North Sanctum Gateway Wall (Z = -22): doorway at X=0, walls at -4, +4
add_wall(-4, -22, 0, "6_wall", "h")
add_wall(0, -22, 0, "10_wall_doorway", "h") # Door to level 4
add_wall(4, -22, 0, "6_wall", "h")

# 3. Central Nave East & West Walls (South segment: Z=16, 12, 8)
for z in [16, 12, 8]:
    add_wall(-6, z, -90, "9_wall_arched", "v")
    add_wall(6, z, 90, "9_wall_arched", "v")

# 4. Central Nave North segment (Z = -8, -12, -16, -20)
for z in [-8, -12, -16, -20]:
    add_wall(-6, z, -90, "6_wall", "v")
    add_wall(6, z, 90, "6_wall", "v")

# Portals to West and East wings at Z = 4 and Z = -4
# At Z = 0, open corridor connecting West & East!
add_wall(-6, 4, -90, "10_wall_doorway", "v")
add_wall(6, 4, 90, "10_wall_doorway", "v")
add_wall(-6, -4, -90, "10_wall_doorway", "v")
add_wall(6, -4, 90, "10_wall_doorway", "v")

# 5. West Labyrinth Outer Perimeter:
# North wall: Z = -14, X in [-8, -12, -16]
for x in [-8, -12, -16]:
    add_wall(x, -14, 0, "5_wall_cracked", "h")
# South wall: Z = 6, X in [-8, -12, -16]
for x in [-8, -12, -16]:
    add_wall(x, 6, 180, "6_wall", "h")
# Far West wall: X = -18, Z in [4, 0, -4, -8, -12]
for z in [4, 0, -4, -8, -12]:
    add_wall(-18, z, -90, "6_wall", "v")

# West Interior maze partitions:
add_wall(-12, 2, 0, "6_wall", "h")
add_wall(-14, -6, 90, "5_wall_cracked", "v")
add_wall(-10, -8, 0, "11_wall_window", "h")

# 6. East Treasury Outer Perimeter:
# North wall: Z = -14, X in [8, 12, 16]
for x in [8, 12, 16]:
    add_wall(x, -14, 0, "6_wall", "h")
# South wall: Z = 6, X in [8, 12, 16]
for x in [8, 12, 16]:
    add_wall(x, 6, 180, "6_wall", "h")
# Far East wall: X = 18, Z in [4, 0, -4, -8, -12]
for z in [4, 0, -4, -8, -12]:
    add_wall(18, z, 90, "6_wall", "v")

# East Interior treasury partitions:
add_wall(12, 2, 0, "9_wall_arched", "h")
add_wall(14, -6, 90, "11_wall_window", "v")

# Pillars in Nave
pillars = []
nave_pillar_coords = [
    (-4.0, 10.0), (4.0, 10.0),
    (-4.0, 2.0), (4.0, 2.0),
    (-4.0, -6.0), (4.0, -6.0),
    (-4.0, -14.0), (4.0, -14.0),
]
for px, pz in nave_pillar_coords:
    p_str = f"""[node name="pillar_{int(px)}_{int(pz)}" type="Node3D" parent="KayKitDungeon/Pillars" unique_id={uid} instance=ExtResource("13_pillar_dec")]
transform = Transform3D(1.1, 0, 0, 0, 1.1, 0, 0, 0, 1.1, {px}, 0, {pz})
"""
    pillars.append(p_str)
    uid += 1

# Torches & Atmospheric Lighting
torches = []
torch_defs = [
    # South Entrance
    (-2.2, 2.4, 17.5, Color(1.0, 0.75, 0.35), 2.2),
    (2.2, 2.4, 17.5, Color(1.0, 0.75, 0.35), 2.2),
    # Central Nave Tomb Hallway
    (-3.8, 2.4, 6.0, Color(1.0, 0.78, 0.40), 2.0),
    (3.8, 2.4, 6.0, Color(1.0, 0.78, 0.40), 2.0),
    # Lord Vaelin's Tomb (Sarcophagus)
    (-2.5, 2.2, -3.2, Color(0.40, 0.75, 1.0), 2.5), # Ethereal Crypt Blue
    (2.5, 2.2, -3.2, Color(0.40, 0.75, 1.0), 2.5),
    # West Catacombs (Labyrinth)
    (-10.0, 2.4, 0.0, Color(1.0, 0.70, 0.30), 2.0),
    (-16.0, 2.4, -4.0, Color(0.35, 0.70, 1.0), 2.4),
    (-16.0, 2.4, -10.0, Color(1.0, 0.70, 0.30), 2.0),
    # East Treasury
    (10.0, 2.4, 0.0, Color(1.0, 0.85, 0.45), 2.2),
    (16.0, 2.4, -4.0, Color(1.0, 0.85, 0.45), 2.8), # Warm golden gold-room glow
    (16.0, 2.4, -10.0, Color(1.0, 0.80, 0.40), 2.0),
    # North Gate to Level 4
    (-2.4, 2.4, -20.5, Color(0.30, 0.80, 1.0), 2.6),
    (2.4, 2.4, -20.5, Color(0.30, 0.80, 1.0), 2.6),
]

for idx, (tx, ty, tz, col, energy) in enumerate(torch_defs):
    t_str = f"""[node name="torch_{idx}" type="Node3D" parent="KayKitDungeon/Torches" unique_id={uid} instance=ExtResource("32_torch_mounted")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {tx}, {ty}, {tz})

[node name="light_{idx}" type="OmniLight3D" parent="KayKitDungeon/Torches" unique_id={uid + 1}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {tx}, {ty + 0.4}, {tz})
light_color = Color({col.r}, {col.g}, {col.b}, 1)
light_energy = {energy}
shadow_enabled = true
omni_range = 8.0
"""
    torches.append(t_str)
    uid += 2

# Ceilings (High arched crypt ceilings at Y = 5.2m)
ceilings = []
for x, z, _ in all_floor_coords:
    c_str = f"""[node name="ceiling_{x}_{z}" type="Node3D" parent="KayKitDungeon/Ceilings" unique_id={uid} instance=ExtResource("14_ceiling_tile")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x}, 5.2, {z})
"""
    ceilings.append(c_str)
    uid += 1

# Props and Dressing:
# 1. Center: Lord Vaelin's Tomb (Sarcophagus)
# 2. West: Skeletal remains & collapsed ruins
# 3. East: Treasure chests, urns, and gold coins
props = f"""[node name="TombTable" type="Node3D" parent="KayKitDungeon/Props" unique_id={uid} instance=ExtResource("20_tomb_table")]
transform = Transform3D(1.2, 0, 0, 0, 1.2, 0, 0, 0, 1.2, 0.0, 0.0, -3.2)

[node name="TombCandles" type="Node3D" parent="KayKitDungeon/Props" unique_id={uid + 1} instance=ExtResource("19_candle_triple")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.0, 1.1, -3.2)

[node name="TombSword" type="Node3D" parent="KayKitDungeon/Props" unique_id={uid + 2} instance=ExtResource("21_sword_shield")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.0, 1.1, -2.4)

[node name="TombBanner" type="Node3D" parent="KayKitDungeon/Props" unique_id={uid + 3} instance=ExtResource("31_banner_shield")]
transform = Transform3D(1.2, 0, 0, 0, 1.2, 0, 0, 0, 1.2, 0.0, 2.6, -5.5)

[node name="WestRubble1" type="Node3D" parent="KayKitDungeon/Props" unique_id={uid + 4} instance=ExtResource("22_rubble_large")]
transform = Transform3D(1.1, 0, 0, 0, 1.1, 0, 0, 0, 1.1, -16.0, 0.0, -1.5)

[node name="WestRubble2" type="Node3D" parent="KayKitDungeon/Props" unique_id={uid + 5} instance=ExtResource("18_rubble_half")]
transform = Transform3D(1.0, 0, 0, 0, 1.0, 0, 0, 0, 1.0, -14.5, 0.0, -3.2)

[node name="WestBrokenSword" type="Node3D" parent="KayKitDungeon/Props" unique_id={uid + 6} instance=ExtResource("24_sword_broken")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -16.0, 0.0, -3.2)

[node name="EastChestGold" type="Node3D" parent="KayKitDungeon/Props" unique_id={uid + 7} instance=ExtResource("26_chest_gold")]
transform = Transform3D(1.1, 0, 0, 0, 1.1, 0, 0, 0, 1.1, 16.0, 0.0, -3.4)

[node name="EastChestNormal" type="Node3D" parent="KayKitDungeon/Props" unique_id={uid + 8} instance=ExtResource("25_chest")]
transform = Transform3D(1.0, 0, 0, 0, 1.0, 0, 0, 0, 1.0, 14.5, 0.0, -4.5)

[node name="EastCoins" type="Node3D" parent="KayKitDungeon/Props" unique_id={uid + 9} instance=ExtResource("27_coin_stack")]
transform = Transform3D(1.2, 0, 0, 0, 1.2, 0, 0, 0, 1.2, 16.0, 0.0, -2.2)

[node name="EastTable" type="Node3D" parent="KayKitDungeon/Props" unique_id={uid + 10} instance=ExtResource("30_table_med")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 15.0, 0.0, -8.0)

[node name="EastUrnCandles" type="Node3D" parent="KayKitDungeon/Props" unique_id={uid + 11} instance=ExtResource("19_candle_triple")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 15.0, 0.9, -8.0)
"""
uid += 12

# Interactive Traps:
# Trap 1: In the West Catacombs path at (-12.0, 0.0, -4.0)
# Trap 2: In the East Treasury entry at (12.0, 0.0, -4.0)
# Trap 3: Ahead of the crypt center at (0.0, 0.0, -10.0) with side bypass!
traps = f"""[node name="Trap_West" type="Area3D" parent="Traps" unique_id={uid}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -12.0, 0.0, -4.0)
script = ExtResource("42_trap_script")
trap_name = "Catacomb Pressure Plate"

[node name="SpikeMesh" parent="Traps/Trap_West" unique_id={uid + 1} instance=ExtResource("41_spike_trap_mesh")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)

[node name="CollisionShape3D" type="CollisionShape3D" parent="Traps/Trap_West" unique_id={uid + 2}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.6, 0)
shape = SubResource("Shape_trap_trigger")

[node name="WarningLight" type="OmniLight3D" parent="Traps/Trap_West" unique_id={uid + 3}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.6, 0)
light_color = Color(1.0, 0.4, 0.1, 1)
light_energy = 1.5
omni_range = 4.0

[node name="Trap_East" type="Area3D" parent="Traps" unique_id={uid + 4}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 12.0, 0.0, -4.0)
script = ExtResource("42_trap_script")
trap_name = "Treasury Vault Plate"

[node name="SpikeMesh" parent="Traps/Trap_East" unique_id={uid + 5} instance=ExtResource("41_spike_trap_mesh")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)

[node name="CollisionShape3D" type="CollisionShape3D" parent="Traps/Trap_East" unique_id={uid + 6}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.6, 0)
shape = SubResource("Shape_trap_trigger")

[node name="WarningLight" type="OmniLight3D" parent="Traps/Trap_East" unique_id={uid + 7}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.6, 0)
light_color = Color(1.0, 0.4, 0.1, 1)
light_energy = 1.5
omni_range = 4.0

[node name="Trap_Nave" type="Area3D" parent="Traps" unique_id={uid + 8}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.0, 0.0, -10.0)
script = ExtResource("42_trap_script")
trap_name = "Nave Guardian Plate"

[node name="SpikeMesh" parent="Traps/Trap_Nave" unique_id={uid + 9} instance=ExtResource("41_spike_trap_mesh")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)

[node name="CollisionShape3D" type="CollisionShape3D" parent="Traps/Trap_Nave" unique_id={uid + 10}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.6, 0)
shape = SubResource("Shape_trap_trigger")

[node name="WarningLight" type="OmniLight3D" parent="Traps/Trap_Nave" unique_id={uid + 11}]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.6, 0)
light_color = Color(1.0, 0.4, 0.1, 1)
light_energy = 1.5
omni_range = 4.0
"""
uid += 12

# Interactive Lore Points (Inspectables)
inspectables = f"""[node name="Inspect_CryptEntrance" type="Area3D" parent="." unique_id=987000305]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 14.0)
script = ExtResource("39_interactable")
interaction_text = "Read Inscription"
interaction_title = "Crypt of Shadows"
description = "A mossy stone archway bearing an epitaph: 'Rest here, noble souls of the Eldorian realm. Let no shadows disturb your slumber.'"

[node name="CollisionShape3D" type="CollisionShape3D" parent="Inspect_CryptEntrance" unique_id=987000306]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0)
shape = SubResource("Shape_inspect_trigger")

[node name="InteractionLabel" type="Label3D" parent="Inspect_CryptEntrance" unique_id=985584263]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.9, 0)
billboard = 1

[node name="Inspect_TombOfVaelin" type="Area3D" parent="." unique_id=260142812]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -3.2)
script = ExtResource("39_interactable")
interaction_title = "Sarcophagus of Vaelin"
description = "The heavy stone tomb of Lord Vaelin. The funerary sword rests across the carved effigy, untouched for centuries."

[node name="CollisionShape3D" type="CollisionShape3D" parent="Inspect_TombOfVaelin" unique_id=968410204]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0)
shape = SubResource("Shape_inspect_trigger")

[node name="InteractionLabel" type="Label3D" parent="Inspect_TombOfVaelin" unique_id=103684168]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.9, 0)
billboard = 1

[node name="Inspect_CryptTreasury" type="Area3D" parent="." unique_id=1055227405]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 16, 0, -3.4)
script = ExtResource("39_interactable")
interaction_text = "Examine"
interaction_title = "Royal Vault Offering"
description = "Chests and gilded urns containing ancient currency and ceremonial relics left to accompany the dead into the deep maze."

[node name="CollisionShape3D" type="CollisionShape3D" parent="Inspect_CryptTreasury" unique_id=215281689]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0)
shape = SubResource("Shape_inspect_trigger")

[node name="InteractionLabel" type="Label3D" parent="Inspect_CryptTreasury" unique_id=1999392964]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.9, 0)
billboard = 1

[node name="Inspect_SkeletalRemains" type="Area3D" parent="." unique_id=2119320738]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -16, 0, -3.2)
script = ExtResource("39_interactable")
interaction_text = "Search"
interaction_title = "Lost Adventurer"
description = "A fallen traveler trapped behind the collapsed masonry. Scratched upon the wall: 'The gateway ahead demands resolve... beware the sanctum.'"

[node name="CollisionShape3D" type="CollisionShape3D" parent="Inspect_SkeletalRemains" unique_id=1891637897]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0)
shape = SubResource("Shape_inspect_trigger")

[node name="InteractionLabel" type="Label3D" parent="Inspect_SkeletalRemains" unique_id=976085563]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.9, 0)
billboard = 1
"""

# Doors: Door_To_Level2 (South at Z=18) and Door_To_Level4 (North at Z=-21.1)
doors = f"""[node name="Door_To_Level2" type="Area3D" parent="." unique_id=872809434]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 18)
script = ExtResource("40_doorscript")
interaction_text = "Return to Ruins (Level 2)"
interaction_title = "Return Archway"
description = "Return to the puzzle hall of Level 2."
target_scene = "res://Scenes/Level/level_2.tscn"
target_spawn_id = "Spawn_From_Level3"

[node name="CollisionShape3D" type="CollisionShape3D" parent="Door_To_Level2" unique_id=1346219787]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.5, 0)
shape = SubResource("Shape_door_trigger")

[node name="InteractionLabel" type="Label3D" parent="Door_To_Level2" unique_id=1191292716]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.2, 0.5)
visible = false
billboard = 1

[node name="Door_To_Level4" type="Area3D" parent="." unique_id=1513476109]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -21.1)
script = ExtResource("40_doorscript")
interaction_text = "Enter Level 4"
interaction_title = "Sanctum Gateway"
description = "Venture deeper into the royal dungeon."
target_scene = "res://Scenes/Level/level_4.tscn"
target_spawn_id = "Spawn_From_Level3"

[node name="CollisionShape3D" type="CollisionShape3D" parent="Door_To_Level4" unique_id=1797227959]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.5, 0)
shape = SubResource("Shape_door_trigger")

[node name="InteractionLabel" type="Label3D" parent="Door_To_Level4" unique_id=384502842]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.2, 0.5)
visible = false
billboard = 1

[node name="PortalTitle" type="Label3D" parent="Door_To_Level4" unique_id=1994233778]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3.1, 0.2)
modulate = Color(0.35, 0.85, 1, 1)
text = "[ SANCTUM GATEWAY ]"
font_size = 28
outline_size = 6
billboard = 1

[node name="PortalLight" type="OmniLight3D" parent="Door_To_Level4" unique_id=942897491]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.8, 0.4)
light_color = Color(0.3, 0.75, 1, 1)
light_energy = 3.0
omni_range = 8.0
"""

# Assemble full scene
full_content = scene_header + "\n"
full_content += "\n".join(floor_tiles) + "\n"
full_content += "\n".join(walls) + "\n"
full_content += "\n".join(pillars) + "\n"
full_content += "\n".join(torches) + "\n"
full_content += props + "\n"
full_content += "\n".join(ceilings) + "\n"
full_content += traps + "\n"
full_content += "\n".join(wall_cols) + "\n"
full_content += inspectables + "\n"
full_content += doors + "\n"

with open("Scenes/Level/level_3.tscn", "w", encoding="utf-8") as f:
    f.write(full_content)

print("level_3.tscn revamped successfully!")
