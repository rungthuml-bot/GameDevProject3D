import re

for lvl in range(9):
    path = f"Scenes/Level/level_{lvl}.tscn"
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    nodes = re.findall(r'\[node name="([^"]+)"', text)
    spawns = [n for n in nodes if "spawn" in n.lower()]
    player_m = [n for n in nodes if "player" in n.lower()]
    print(f"=== Level {lvl} ===")
    print(f"  Spawns: {spawns}")
    print(f"  Player nodes: {player_m}")
