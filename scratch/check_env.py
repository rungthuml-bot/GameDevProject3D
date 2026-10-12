import os, re

for lvl in ['level_1.tscn', 'level_2.tscn', 'level_3.tscn', 'level_5.tscn']:
    path = os.path.join(r'c:\Users\ACER\Downloads\GameDevProject3D-map-3-4-rebuild\Scenes\Level', lvl)
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        print('===', lvl, '===')
        m = re.search(r'\[sub_resource type="Environment" id="([^"]+)"\](.*?)(?=\n\[|\Z)', content, re.DOTALL)
        if m:
            print(m.group(0))
        m_light = re.search(r'\[node name="DirectionalLight3D"[^\]]*\](.*?)(?=\n\[|\Z)', content, re.DOTALL)
        if m_light:
            print(m_light.group(0))
