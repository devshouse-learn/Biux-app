"""Remove duplicate keys from app_translations.dart.

For each language map, keeps the FIRST occurrence of each key
and removes subsequent duplicates (including multiline values).
"""
import re
import sys

FILE = 'lib/core/config/app_translations.dart'

with open(FILE, 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')
total_original = len(lines)

# Find map boundaries
map_starts = []
for i, line in enumerate(lines):
    if 'const Map<String, String>' in line and '{' in line:
        map_starts.append(i)

map_ends = []
for start in map_starts:
    depth = 0
    for i in range(start, len(lines)):
        depth += lines[i].count('{') - lines[i].count('}')
        if depth == 0:
            map_ends.append(i)
            break

print(f'Found {len(map_starts)} language maps')

key_re = re.compile(r"^\s+'([^']+)'\s*:")

lines_to_remove = set()

for idx, (start, end) in enumerate(zip(map_starts, map_ends)):
    seen = {}
    i = start
    while i <= end:
        m = key_re.match(lines[i])
        if m:
            key = m.group(1)
            # Determine how many lines this entry spans
            entry_lines = [i]
            # Check if value continues on next line(s)
            j = i + 1
            while j <= end:
                line_j = lines[j]
                # A continuation line: indented more, not a new key, not a comment, not closing brace
                if (line_j.startswith('        ') and
                    not key_re.match(line_j) and
                    not line_j.strip().startswith('//') and
                    not line_j.strip() == '' and
                    not line_j.strip().startswith('}')):
                    entry_lines.append(j)
                    j += 1
                else:
                    break

            if key in seen:
                # Mark duplicate for removal
                for line_idx in entry_lines:
                    lines_to_remove.add(line_idx)
            else:
                seen[key] = i

            i = entry_lines[-1] + 1
        else:
            i += 1

    print(f'  Map {idx}: {len(seen)} unique keys, found {sum(1 for l in range(start, end+1) if l in lines_to_remove)} duplicate lines')

print(f'\nTotal lines to remove: {len(lines_to_remove)}')

# Build new content
new_lines = [lines[i] for i in range(len(lines)) if i not in lines_to_remove]

with open(FILE, 'w', encoding='utf-8') as f:
    f.write('\n'.join(new_lines))

print(f'Done: {total_original} -> {len(new_lines)} lines')
