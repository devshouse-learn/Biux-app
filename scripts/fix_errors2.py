#!/usr/bin/env python3
"""Fix round 2: handle remaining undefined 'l' and const errors"""
import re
import glob

# =============================================================================
# FIX undefined 'l' in specific files  
# These are cases where l.t() is used outside build() or in static contexts
# =============================================================================

files_with_l_issues = [
    'lib/features/age_verification/presentation/widgets/birth_date_picker.dart',
    'lib/features/chat/presentation/widgets/message_bubble.dart',
    'lib/features/ride_recommendations/presentation/screens/my_recommendations_screen.dart',
    'lib/features/safety/presentation/screens/blocked_users_screen.dart',
    'lib/features/settings/presentation/screens/privacy_settings_screen.dart',
    'lib/features/shop/presentation/screens/admin_shop_screen.dart',
    'lib/features/shop/presentation/screens/shop_screen_pro.dart',
    'lib/features/shop/presentation/widgets/promotions_widget.dart',
    'lib/features/social/presentation/widgets/report_content_dialog.dart',
]

# For each file, check where l is used and ensure it's defined
for fpath in files_with_l_issues:
    fpath = fpath.replace('/', '\\')
    try:
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        fpath = fpath.replace('\\', '/')
        try:
            with open(fpath, 'r', encoding='utf-8') as f:
                content = f.read()
        except:
            print(f"  ⚠️ Cannot open: {fpath}")
            continue
    
    original = content
    lines = content.split('\n')
    
    # Find all lines with l.t( that DON'T have l defined in scope
    # Check: does the class have LocaleNotifier get l?
    has_getter = 'LocaleNotifier get l' in content
    has_final_l = 'final l = ' in content or 'final l =' in content
    
    if not has_getter and not has_final_l:
        # Check what kind of class this is
        if 'extends State<' in content:
            # Add getter
            match = re.search(r'(class \w+ extends State<\w+>(?:\s+with\s+[\w,\s<>]+)?\s*\{)', content)
            if match:
                insert_pos = match.end()
                getter = '\n  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);\n'
                content = content[:insert_pos] + getter + content[insert_pos:]
                print(f"  Added getter to State class in {fpath}")
        elif 'extends StatelessWidget' in content:
            build_match = re.search(r'(Widget build\(BuildContext context\)\s*\{)', content)
            if build_match:
                insert_pos = build_match.end()
                l_def = '\n    final l = Provider.of<LocaleNotifier>(context);\n'
                content = content[:insert_pos] + l_def + content[insert_pos:]
                print(f"  Added final l in build() in {fpath}")
        else:
            # Check for class-level static const that uses l.t()
            # These need to be reverted or handled differently
            pass
    
    # Special handling: if l.t() is used at class level (outside methods),
    # such as in a static list definition, we need to revert those
    # Find l.t() at class level (indentation 2 or 4 spaces, not inside a method)
    
    # Check for l.t() in static/const contexts
    lt_in_const = False
    for i, line in enumerate(lines):
        stripped = line.strip()
        # If this is a field-level or top-level definition using l.t()
        if "l.t('" in stripped and ('static ' in stripped or 'final ' in stripped or 'const ' in stripped):
            if 'build(' not in content[max(0, content.find(stripped)-500):content.find(stripped)]:
                lt_in_const = True
    
    if content != original:
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(content)

# =============================================================================
# Special fixes for specific files
# =============================================================================

# report_content_dialog.dart - l.t() at class level in a list definition
fpath = 'lib/features/social/presentation/widgets/report_content_dialog.dart'
try:
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
    # Find lines 12-15 area where l.t() is used at top level
    # These are probably in a static list - need to revert
    KEY_TO_ES = {
        'spam_advertising': 'Spam o publicidad',
        'false_info': 'Información falsa',
    }
    for key, val in KEY_TO_ES.items():
        content = content.replace(f"l.t('{key}')", f"'{val}'")
    with open(fpath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"  Reverted class-level l.t() in {fpath}")
except Exception as e:
    print(f"  Error: {e}")

# promotions_widget.dart - l.t('cyclist_label') at line 50, probably in a variable init
fpath = 'lib/features/shop/presentation/widgets/promotions_widget.dart'
try:
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
    # Revert l.t() used outside build methods (field-level)
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if 'l.t(' in line:
            # Check indent - if it's at field level (low indent, outside a method)
            indent = len(line) - len(line.lstrip())
            # Check if we're inside a method by looking backwards
            in_method = False
            for j in range(i-1, max(i-50, -1), -1):
                s = lines[j].strip()
                if s.startswith('Widget build(') or s.startswith('void ') or s.startswith('Future<') or s.endswith(') {'):
                    if '{' in s:
                        in_method = True
                        break
                if s.startswith('class '):
                    break
            
            if not in_method:
                # Revert this l.t() call
                for key, val in {'cyclist_label': 'Ciclista', 'user_default': 'Usuario'}.items():
                    if f"l.t('{key}')" in line:
                        lines[i] = line.replace(f"l.t('{key}')", f"'{val}'")
    
    content = '\n'.join(lines)
    with open(fpath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"  Fixed field-level l.t() in {fpath}")
except Exception as e:
    print(f"  Error: {e}")

# =============================================================================
# Aggressive const removal - find ALL const that have l.t() descendants
# =============================================================================
all_files = glob.glob('lib/**/*.dart', recursive=True)
total_const_fixes = 0

for fpath in all_files:
    try:
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        continue
    
    if 'l.t(' not in content:
        continue
    
    original = content
    lines = content.split('\n')
    
    # For each l.t() line, find ALL const keywords above until we reach method-level scope
    lt_lines = [i for i, line in enumerate(lines) if 'l.t(' in line]
    
    # Also find all const lines
    const_lines = set()
    for i, line in enumerate(lines):
        stripped = line.strip()
        if 'const ' in stripped and ('(' in stripped or '[' in stripped):
            const_lines.add(i)
    
    # For each const line, check if any l.t() exists between it and the matching close
    lines_to_fix = set()
    for cl in const_lines:
        # Check if any l.t() line is "below" this const and within its scope
        stripped = lines[cl].strip()
        # Count parens to find scope
        depth = 0
        start_counting = False
        end_line = cl
        full_text = ''
        for i in range(cl, min(cl + 100, len(lines))):
            for ch in lines[i]:
                if ch == '(' or ch == '[':
                    depth += 1
                    start_counting = True
                elif ch == ')' or ch == ']':
                    depth -= 1
                    if start_counting and depth == 0:
                        end_line = i
                        break
            if start_counting and depth == 0:
                break
        
        # Check if any l.t() exists between cl and end_line
        for lt in lt_lines:
            if cl <= lt <= end_line:
                lines_to_fix.add(cl)
                break
    
    for cl in lines_to_fix:
        if 'const ' in lines[cl]:
            lines[cl] = lines[cl].replace('const ', '', 1)
            total_const_fixes += 1
    
    new_content = '\n'.join(lines)
    if new_content != original:
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(new_content)

print(f"\n✅ Aggressive const fix: removed {total_const_fixes} const keywords")
print("🎯 Run 'flutter analyze' to check remaining errors.")
