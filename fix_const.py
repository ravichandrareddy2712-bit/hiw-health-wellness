import os
import re

lib_dir = r"d:\DataSetsForAI_ML_DL\TrainingSets\hiw\lib"

def fix_consts(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    
    # Remove const before common widgets
    widgets = ['EdgeInsets', 'SizedBox', 'Text', 'TextSpan', 'TextStyle', 'Icon', 'BorderRadius', 'Radius', 'Padding', 'BoxShadow', 'BoxDecoration', 'Positioned', 'PremiumGlassCard', 'GlassCard', 'Center', 'Align', 'Expanded', 'Flexible', 'Column', 'Row', 'Stack', 'Container', 'FractionallySizedBox', 'Spacer', 'Divider', 'VerticalDivider', 'CircleAvatar', 'ClipRRect']
    
    pattern = r'const\s+(' + '|'.join(widgets) + r')\b'
    content = re.sub(pattern, r'\1', content)
    
    # Remove const before children lists
    content = re.sub(r'children:\s*const\s*\[', r'children: [', content)
    content = re.sub(r'const\s*<Widget>\s*\[', r'<Widget>[', content)
    
    # In many places, `const [` is used to wrap widgets. Let's heuristically remove it if it contains widgets but that's hard. 
    # Let's just remove `const [` globally? Actually, if we just remove `const [` it affects `const ['Breakfast', 'Lunch']`. 
    # Let's only remove `const [` if it has a newline and a capital letter (Widget) inside.
    def replace_const_list(match):
        return match.group(0).replace('const [', '[')

    # This removes const [ followed by whitespace and a capital letter
    content = re.sub(r'const\s*\[\s*[A-Z]', replace_const_list, content)

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            fix_consts(os.path.join(root, f))
print('fixed consts')
