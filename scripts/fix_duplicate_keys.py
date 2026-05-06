"""
Script to remove duplicate keys from app_translations.dart.
For each const map section, keeps the first occurrence of each key
and removes subsequent duplicates.
"""
import re
import sys

def fix_duplicates(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # Pattern to match a map key-value line like:  'key': 'value',
    # or multi-line values
    key_pattern = re.compile(r"^\s+'([^']+)':\s*")

    # Find section boundaries for each language map
    # Each section starts with "static const Map<String, String> _XX = {"
    # and ends with "};"
    sections = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if re.match(r"\s*static const Map<String, String> _\w+ = \{", line):
            start = i
            # Find the closing '};'
            brace_count = 0
            j = i
            while j < len(lines):
                brace_count += lines[j].count('{') - lines[j].count('}')
                if brace_count == 0:
                    sections.append((start, j))
                    break
                j += 1
            i = j + 1
        else:
            i += 1

    print(f"Found {len(sections)} map sections")
    
    total_removed = 0
    # Process sections in reverse order so line numbers don't shift
    for start, end in reversed(sections):
        seen_keys = set()
        lines_to_remove = []
        i = start + 1  # Skip the opening line
        while i < end:
            line = lines[i]
            match = key_pattern.match(line)
            if match:
                key = match.group(1)
                if key in seen_keys:
                    # This is a duplicate - mark for removal
                    # Check if value spans multiple lines (no closing ', at end)
                    lines_to_remove.append(i)
                    # Check for multi-line values
                    stripped = line.rstrip()
                    if not (stripped.endswith("',") or stripped.endswith("',")):
                        # Multi-line value - remove continuation lines too
                        j = i + 1
                        while j < end and not key_pattern.match(lines[j]) and not lines[j].strip().startswith('}'):
                            lines_to_remove.append(j)
                            j += 1
                else:
                    seen_keys.add(key)
                    # Skip multi-line values for non-duplicates
                    stripped = line.rstrip()
                    if not (stripped.endswith("',") or stripped.endswith("',")):
                        j = i + 1
                        while j < end and not key_pattern.match(lines[j]) and not lines[j].strip().startswith('}'):
                            j += 1
                        i = j
                        continue
            i += 1
        
        # Remove lines in reverse order
        for idx in sorted(lines_to_remove, reverse=True):
            del lines[idx]
        
        removed_count = len(lines_to_remove)
        total_removed += removed_count
        if removed_count > 0:
            print(f"  Section at line {start+1}: removed {removed_count} duplicate lines")

    print(f"\nTotal lines removed: {total_removed}")

    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print("File saved successfully.")

if __name__ == '__main__':
    filepath = r'c:\Users\Usuario\Biux-app\Biux-app\lib\core\config\app_translations.dart'
    fix_duplicates(filepath)
