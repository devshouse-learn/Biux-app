#!/usr/bin/env python3
"""Find lines with embedded single quotes in translation values."""

with open('lib/core/config/app_translations.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines, 1):
    s = line.strip()
    # Look for translation entries
    if s.startswith("'") and "': '" in s:
        idx = s.find("': '")
        val_start = idx + 4
        val = s[val_start:]
        if val.endswith("',"):
            val = val[:-2]
        elif val.endswith("'"):
            val = val[:-1]
        # Check for embedded quotes
        if "'" in val:
            print(f"L{i}: {s[:100]}")
