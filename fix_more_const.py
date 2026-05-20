import os
import re

lib_dir = r"d:\DataSetsForAI_ML_DL\TrainingSets\hiw\lib"

def fix_consts(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    
    widgets = ['BorderSide', 'RoundedRectangleBorder', 'OutlineInputBorder', 'Shadow', 'UnderlineInputBorder', 'EdgeInsetsDirectional', 'Border']
    pattern = r'const\s+(' + '|'.join(widgets) + r')\b'
    content = re.sub(pattern, r'\1', content)

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            fix_consts(os.path.join(root, f))
print('fixed more consts')
