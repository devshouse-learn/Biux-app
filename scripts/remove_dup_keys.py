#!/usr/bin/env python3
"""
Remove duplicate keys from ALL 4 language sections of app_translations.dart.

Strategy: The LATER occurrences (in the organized blocks with section comments) are kept.
The EARLIER occurrences (scattered in the main body) are removed.

For each section, we identify lines that contain duplicate keys at their FIRST occurrence,
and remove just those lines (not entire blocks, just the individual lines).
"""
import re
import sys

filepath = 'lib/core/config/app_translations.dart'

with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

print(f"Original file: {len(lines)} lines")

# Section boundaries (1-indexed line numbers)
sections = {
    '_es': (21, 2735),
    '_en': (2736, 5510),
    '_pt': (5511, 8327),
    '_fr': (8328, len(lines)),
}

# For each section, find duplicate keys and record the FIRST occurrence line (to remove)
lines_to_remove = set()

for section_name, (start_line, end_line) in sections.items():
    keys = {}  # key -> first_line_number (1-indexed)
    duplicates_first_lines = []

    for i in range(start_line - 1, min(end_line, len(lines))):
        line = lines[i]
        m = re.match(r"\s*'([^']+)'\s*:", line)
        if m:
            key = m.group(1)
            line_num = i + 1  # 1-indexed
            if key in keys:
                # This is a duplicate - mark the FIRST occurrence for removal
                duplicates_first_lines.append((key, keys[key], line_num))
            else:
                keys[key] = line_num

    print(f"\n{section_name}: {len(duplicates_first_lines)} duplicate keys")
    for key, first, dup in duplicates_first_lines:
        print(f"  Removing line {first}: '{key}' (keeping line {dup})")
        lines_to_remove.add(first - 1)  # Convert to 0-indexed
        
        # Check if the line before is a multi-line value continuation (e.g., long strings)
        # Some entries span multiple lines, need to check
        actual_line = lines[first - 1]
        # Check if this key's value continues on the next line(s)
        # A continued line doesn't start with a key pattern and isn't a comment
        check_idx = first  # next line (0-indexed = first)
        while check_idx < len(lines):
            next_line = lines[check_idx].strip()
            # If next line is another key, a comment, or closing brace, stop
            if (re.match(r"'[^']+'\s*:", next_line) or 
                next_line.startswith('//') or 
                next_line == '};' or
                next_line == '}' or
                next_line == ''):
                break
            # This line is a continuation of the value
            print(f"    Also removing continuation line {check_idx + 1}: {next_line[:60]}")
            lines_to_remove.add(check_idx)
            check_idx += 1

print(f"\nTotal lines to remove: {len(lines_to_remove)}")

# Build new file content
new_lines = [line for i, line in enumerate(lines) if i not in lines_to_remove]
print(f"New file: {len(new_lines)} lines (removed {len(lines) - len(new_lines)})")

# Verify no duplicates remain
for section_name, (start_line, end_line) in sections.items():
    # Recalculate boundaries based on removed lines
    pass  # We'll verify after writing

# Write the file
if '--dry-run' not in sys.argv:
    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    print("\nFile written successfully!")
    
    # Verify the new file
    with open(filepath, 'r', encoding='utf-8') as f:
        new_lines_check = f.readlines()
    
    # Find new section boundaries
    new_sections = {}
    for i, line in enumerate(new_lines_check):
        if 'static const Map<String, String> _es = {' in line:
            new_sections['_es_start'] = i
        elif 'static const Map<String, String> _en = {' in line:
            new_sections['_es_end'] = i
            new_sections['_en_start'] = i
        elif 'static const Map<String, String> _pt = {' in line:
            new_sections['_en_end'] = i
            new_sections['_pt_start'] = i
        elif 'static const Map<String, String> _fr = {' in line:
            new_sections['_pt_end'] = i
            new_sections['_fr_start'] = i
    new_sections['_fr_end'] = len(new_lines_check)
    
    print(f"\nNew section boundaries:")
    for k, v in new_sections.items():
        print(f"  {k}: line {v + 1}")
    
    # Check for remaining duplicates
    for sec in ['_es', '_en', '_pt', '_fr']:
        start = new_sections[f'{sec}_start']
        end = new_sections[f'{sec}_end']
        keys = {}
        remaining_dups = []
        for i in range(start, end):
            m = re.match(r"\s*'([^']+)'\s*:", new_lines_check[i])
            if m:
                key = m.group(1)
                if key in keys:
                    remaining_dups.append((key, keys[key] + 1, i + 1))
                else:
                    keys[key] = i
        if remaining_dups:
            print(f"\n  WARNING: {sec} still has {len(remaining_dups)} duplicates!")
            for k, f, d in remaining_dups:
                print(f"    '{k}' at lines {f} and {d}")
        else:
            print(f"  {sec}: No duplicates remaining ✓")
else:
    print("\n[DRY RUN] No changes written.")
