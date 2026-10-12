import re

with open("Scenes/Level/level_1.tscn", "r", encoding="utf-8") as f:
    text = f.read()

nodes = re.findall(r'\[node name="([^"]+)"(?:\s+type="([^"]+)")?(?:\s+parent="([^"]+)")?', text)
for name, ntype, parent in nodes[:25]:
    print(f"{name:25} type={ntype:15} parent={parent}")
