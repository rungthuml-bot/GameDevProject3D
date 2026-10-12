import re

with open("Scenes/Level/level_1.tscn", "r", encoding="utf-8") as f:
    text = f.read()

nodes = re.findall(r'\[node name="([^"]+)"(?: parent="([^"]+)")?', text)
print(f"Total nodes: {len(nodes)}")
parents = set(p for n, p in nodes if p)
print("Unique parents:", sorted(list(parents)))
for n, p in nodes:
    if p in [".", None, ""]:
        print(f"Top level node: {n}")
