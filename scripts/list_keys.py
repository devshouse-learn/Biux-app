#!/usr/bin/env python3
"""Extract existing translation keys"""
import re

with open('lib/core/config/app_translations.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find _es section
es_match = re.search(r"static const Map<String, String> _es = \{", content)
if not es_match:
    print("ERROR: _es section not found")
    exit(1)

# Find closing of _es
depth = 0
start = es_match.start()
for i in range(start, len(content)):
    if content[i] == '{':
        depth += 1
    elif content[i] == '}':
        depth -= 1
        if depth == 0:
            es_end = i + 1
            break

es_section = content[start:es_end]
keys = re.findall(r"'([a-z_0-9]+)'\s*:", es_section)
print(f'Total existing keys: {len(keys)}')
for k in sorted(keys):
    print(k)
