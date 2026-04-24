"""
Fix remaining const issues - find const keywords before widgets that contain l.t()
"""
import re
import os

def read_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def write_file(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_const_with_lt(content):
    """
    Remove 'const' from parent widgets that contain l.t() in their children.
    Strategy: find 'const Row(', 'const Column(', 'const InputDecoration(', etc.
    that eventually contain l.t() in their content.
    """
    # Simple approach: find 'const' followed by widget constructors,
    # and if l.t() appears before the matching closing paren, remove const
    
    lines = content.split('\n')
    changed = False
    
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.lstrip()
        
        # Check if this line has 'const' before a widget constructor
        const_match = re.search(r'\bconst\s+(Row|Column|Text|InputDecoration|ListTile|SizedBox|Icon)\s*\(', line)
        if const_match:
            # Look ahead in the next ~20 lines for l.t( before the section ends
            has_lt = False
            # Simple check: scan ahead for l.t(
            for j in range(i, min(i + 30, len(lines))):
                if 'l.t(' in lines[j]:
                    has_lt = True
                    break
                # If we hit another const or a line that clearly ends this construct, stop
                if j > i and re.match(r'\s*\)\s*[,;]', lines[j]):
                    break
            
            if has_lt:
                # Remove the 'const ' keyword from this line
                lines[i] = re.sub(r'\bconst\s+(' + const_match.group(1) + r'\s*\()', r'\1', lines[i], count=1)
                changed = True
        i += 1
    
    if changed:
        return '\n'.join(lines)
    return content

FILES = [
    'lib/features/achievements/presentation/screens/achievements_screen.dart',
    'lib/features/chat/presentation/screens/chat_screen.dart',
    'lib/features/chat/presentation/widgets/message_bubble.dart',
    'lib/features/cycling_stats/presentation/screens/cycling_stats_screen.dart',
    'lib/features/ride_tracker/presentation/screens/ride_tracker_screen.dart',
    'lib/features/road_reports/presentation/screens/road_reports_screen.dart',
    'lib/features/users/presentation/screens/public_user_profile_screen.dart',
]

def main():
    print("Fixing remaining const issues...\n")
    for f in FILES:
        if not os.path.exists(f):
            continue
        content = read_file(f)
        new_content = fix_const_with_lt(content)
        if new_content != content:
            write_file(f, new_content)
            print(f"  FIXED: {f}")
        else:
            print(f"  NO CHANGE: {f}")
    print("\nDone!")

if __name__ == '__main__':
    main()
