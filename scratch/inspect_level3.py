import re

with open("Scenes/Level/level_3.tscn", "r", encoding="utf-8") as f:
    text = f.read()

nodes = re.findall(r'\[node name="([^"]+)"(?:\s+type="([^"]+)")?(?:\s+parent="([^"]+)")?', text)
print(f"Total nodes in level_3: {len(nodes)}")

for kw in ["player", "door", "spawn", "enemy", "trap", "interact", "hud", "world", "light", "chest"]:
    matches = [(n, t, p) for n, t, p in nodes if kw in n.lower() or (t and kw in t.lower())]
    print(f"\n--- Matches for '{kw}' ({len(matches)}) ---")
    for m in matches[:10]:
        print(f"  {m[0]:25} type={m[1]} parent={m[2]}")
