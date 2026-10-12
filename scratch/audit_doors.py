import os, re

levels_dir = r'Scenes/Level'
scenes = ['map_0.tscn'] + [f'level_{i}.tscn' for i in range(1, 9)]

nodes_by_scene = {}
doors_by_scene = {}

for s in scenes:
    path = os.path.join(levels_dir, s)
    if not os.path.exists(path):
        print(f'MISSING: {s}')
        continue
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # find all node names
    node_names = set(re.findall(r'\[node name="([^"]+)"', content))
    nodes_by_scene[s] = node_names
    
    # find door blocks
    doors = []
    door_blocks = re.findall(r'\[node name="(Door[^"]*)"[^\]]*\](.*?)(?=\n\[node|\Z)', content, re.DOTALL)
    for dname, dbody in door_blocks:
        target_scene_m = re.search(r'target_scene = "([^"]+)"', dbody)
        target_spawn_m = re.search(r'target_spawn_id = "([^"]+)"', dbody)
        ts = target_scene_m.group(1) if target_scene_m else ''
        tsp = target_spawn_m.group(1) if target_spawn_m else ''
        doors.append((dname, ts, tsp))
    doors_by_scene[s] = doors

print('=== ALL DOORS AUDIT ===')
total_doors = 0
all_valid = True

for s in scenes:
    print(f'Level: {s}')
    for dname, ts, tsp in doors_by_scene[s]:
        total_doors += 1
        ts_basename = os.path.basename(ts)
        valid_scene = ts_basename in nodes_by_scene
        valid_spawn = valid_scene and (tsp in nodes_by_scene[ts_basename])
        status = 'OK' if (valid_scene and valid_spawn) else 'FAIL'
        if status == 'FAIL':
            all_valid = False
        print(f'  [{status}] {dname} -> {ts_basename} ({tsp}) (scene_exists={valid_scene}, spawn_exists={valid_spawn})')

print(f'\nTotal doors audited: {total_doors}')
print(f'All door targets valid: {all_valid}')
