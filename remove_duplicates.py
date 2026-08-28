#!/usr/bin/env python3
"""Remove duplicate translation blocks from app_translations.dart"""

# Read the translations file
with open('lib/core/config/app_translations.dart', 'r', encoding='utf-8') as f:
    content = f.read()
    lines = content.split('\n')

# Find line numbers for language sections and duplicates
print("Scanning for duplicate sections...")
for i, line in enumerate(lines, 1):
    if 'static const Map<String, String> _pt = {' in line:
        print(f"✓ Portuguese section starts at line {i}")
    elif 'static const Map<String, String> _fr = {' in line:
        print(f"✓ French section starts at line {i}")
    elif 'static const Map<String, String> _it = {' in line:
        print(f"✓ Italian section starts at line {i}")
    
    # Look for Account settings screen comments (duplicates in English, PT, FR)
    if "// Account settings screen" in line:
        print(f"⚠ Duplicate 'Account settings screen' at line {i}")
    
    # Look for Privacy & security comment in Italian (after line 20000)
    if "// Privacy & security" in line and i > 20000:
        print(f"⚠ Duplicate 'Privacy & security' at line {i}")

print(f"\nTotal lines: {len(lines)}")
