import re, glob

print("=== CHECKING LEVEL DEFAULT SPAWNS ===")
for lvl in range(9):
    path = f"Scenes/Level/level_{lvl}.tscn"
    try:
        with open(path, "r", encoding="utf-8") as f:
            text = f.read()
        spawns = re.findall(r'\[node name="([^"]*Spawn[^"]*)"', text)
        print(f"Level {lvl} ({path}): {spawns}")
    except Exception as e:
        print(f"Level {lvl}: {e}")
