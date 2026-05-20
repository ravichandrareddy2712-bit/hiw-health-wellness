import os
import re

lib_dir = r"d:\DataSetsForAI_ML_DL\TrainingSets\hiw\lib"

def refactor_file(filepath):
    if "main.dart" in filepath or "pubspec.yaml" in filepath:
        return
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    def add_w(match):
        val = match.group(1)
        if val == '0' or val == '0.0': return f"width: {val}"
        return f"width: {val}.w"
    
    def add_h(match):
        val = match.group(1)
        if val == '0' or val == '0.0': return f"height: {val}"
        return f"height: {val}.h"
        
    def add_sp(match):
        val = match.group(1)
        return f"fontSize: {val}.sp"
        
    def add_r_circ(match):
        val = match.group(1)
        if val == '0' or val == '0.0': return f"Radius.circular({val})"
        return f"Radius.circular({val}.r)"

    def add_r_all(match):
        val = match.group(1)
        if val == '0' or val == '0.0': return f"EdgeInsets.all({val})"
        return f"EdgeInsets.all({val}.r)"

    content = re.sub(r'width:\s*(\d+(?:\.\d+)?)(?![a-zA-Z\.])', add_w, content)
    content = re.sub(r'height:\s*(\d+(?:\.\d+)?)(?![a-zA-Z\.])', add_h, content)
    content = re.sub(r'fontSize:\s*(\d+(?:\.\d+)?)(?![a-zA-Z\.])', add_sp, content)
    content = re.sub(r'Radius\.circular\(\s*(\d+(?:\.\d+)?)\s*\)(?![a-zA-Z\.])', add_r_circ, content)
    content = re.sub(r'EdgeInsets\.all\(\s*(\d+(?:\.\d+)?)\s*\)(?![a-zA-Z\.])', add_r_all, content)
    
    def fix_symmetric(match):
        inner = match.group(1)
        inner = re.sub(r'horizontal:\s*(\d+(?:\.\d+)?)(?![a-zA-Z\.])', r'horizontal: \1.w', inner)
        inner = re.sub(r'vertical:\s*(\d+(?:\.\d+)?)(?![a-zA-Z\.])', r'vertical: \1.h', inner)
        inner = inner.replace('0.0.w', '0.0').replace('0.0.h', '0.0').replace('0.w', '0').replace('0.h', '0')
        return f"EdgeInsets.symmetric({inner})"
    
    content = re.sub(r'EdgeInsets\.symmetric\((.*?)\)', fix_symmetric, content)

    def fix_only(match):
        inner = match.group(1)
        inner = re.sub(r'top:\s*(\d+(?:\.\d+)?)(?![a-zA-Z\.])', r'top: \1.h', inner)
        inner = re.sub(r'bottom:\s*(\d+(?:\.\d+)?)(?![a-zA-Z\.])', r'bottom: \1.h', inner)
        inner = re.sub(r'left:\s*(\d+(?:\.\d+)?)(?![a-zA-Z\.])', r'left: \1.w', inner)
        inner = re.sub(r'right:\s*(\d+(?:\.\d+)?)(?![a-zA-Z\.])', r'right: \1.w', inner)
        inner = inner.replace('0.0.w', '0.0').replace('0.0.h', '0.0').replace('0.w', '0').replace('0.h', '0')
        return f"EdgeInsets.only({inner})"

    content = re.sub(r'EdgeInsets\.only\((.*?)\)', fix_only, content)
    
    def add_r_gen(match):
        name = match.group(1)
        val = match.group(2)
        if val == '0' or val == '0.0': return f"{name}: {val}"
        return f"{name}: {val}.r"
    
    content = re.sub(r'(blurRadius|spreadRadius):\s*(\d+(?:\.\d+)?)(?![a-zA-Z\.])', add_r_gen, content)

    # Some widgets use top:, left: absolute positioning
    def fix_pos(match):
        name = match.group(1)
        val = match.group(2)
        if val == '0' or val == '0.0': return f"{name}: {val}"
        if name in ['left', 'right']: return f"{name}: {val}.w"
        if name in ['top', 'bottom']: return f"{name}: {val}.h"
        return match.group(0)
        
    # Careful not to conflict with EdgeInsets properties by ensuring these are standalone arguments like in Positioned or Container margins? But margin/padding use EdgeInsets. So it's fine for Positioned(top: 10). Wait, already handled via EdgeInsets.only! If we just replace `top: 10` globally, it might conflict. Let's ONLY replace Positioned.
    def fix_positioned(match):
        inner = match.group(1)
        inner = re.sub(r'top:\s*(\d+(?:\.\d+)?)(?![a-zA-Z\.])', r'top: \1.h', inner)
        inner = re.sub(r'bottom:\s*(\d+(?:\.\d+)?)(?![a-zA-Z\.])', r'bottom: \1.h', inner)
        inner = re.sub(r'left:\s*(\d+(?:\.\d+)?)(?![a-zA-Z\.])', r'left: \1.w', inner)
        inner = re.sub(r'right:\s*(\d+(?:\.\d+)?)(?![a-zA-Z\.])', r'right: \1.w', inner)
        inner = inner.replace('0.0.w', '0.0').replace('0.0.h', '0.0').replace('0.w', '0').replace('0.h', '0')
        return f"Positioned({inner})"
        
    content = re.sub(r'Positioned\((.*?)\)', fix_positioned, content)
    
    if content != original:
        import_stmt = "import 'package:flutter_screenutil/flutter_screenutil.dart';"
        if import_stmt not in content:
            if 'import ' in content:
                content = content.replace('import ', import_stmt + '\nimport ', 1)
            else:
                content = import_stmt + '\n' + content

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            refactor_file(os.path.join(root, f))
print('done')
