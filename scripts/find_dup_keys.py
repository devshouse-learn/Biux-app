#!/usr/bin/env python3
import re

with open('lib/core/config/app_translations.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

sections = {
    '_es': (20, 2735),
    '_en': (2735, 5510),
    '_pt': (5510, 8327),
    '_fr': (8327, len(lines)),
}

for section_name, (start, end) in sections.items():
    keys = {}
    duplicates = []
    for i in range(start, min(end, len(lines))):
        line = lines[i]
        m = re.match(r"\s*'([^']+)'\s*:", line)
        if m:
            key = m.group(1)
            line_num = i + 1
            if key in keys:
                duplicates.append((key, keys[key], line_num))
            else:
                keys[key] = line_num

    if duplicates:
        print(f"\n=== {section_name} section: {len(duplicates)} duplicate keys ===")
        for key, first, dup in duplicates:
            print(f'  "{key}" -> first at line {first}, duplicate at line {dup}')
    else:
        print(f"\n=== {section_name} section: NO duplicates ===")
