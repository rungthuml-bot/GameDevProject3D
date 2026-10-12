import re

for lvl in range(9):
    path = f"Scenes/Level/level_{lvl}.tscn"
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    spawns = re.findall(r'\[node name="([^"]+)" type="Marker3D"', text)
    print(f"level_{lvl}.tscn Marker3Ds: {spawns}")
