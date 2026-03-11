"""
Script to remove duplicate keys from app_translations.dart.
For each const map (_es, _en, _pt, _fr), keeps the FIRST occurrence
of each key and removes subsequent duplicate entries.
Also fixes the broken line 413 (`: 'Crear Rodada',` without a key name).
"""
import re
import sys

FILE = r"lib\core\config\app_translations.dart"

with open(FILE, "r", encoding="utf-8") as f:
    lines = f.readlines()

print(f"Original file: {len(lines)} lines")

# ── Phase 1: Fix the broken line that has no key (just `: 'value',`) ──
# Pattern: a line that starts with whitespace, then has `: 'some value',`
# but no key before the colon
broken_pattern = re.compile(r"^\s+:\s*'[^']*',?\s*$")
fixed_lines = []
removed_broken = 0
for i, line in enumerate(lines):
    if broken_pattern.match(line):
        print(f"  Removing broken line {i+1}: {line.rstrip()}")
        removed_broken += 1
    else:
        fixed_lines.append(line)

print(f"Removed {removed_broken} broken lines")

# ── Phase 2: Detect map boundaries and remove duplicate keys ──
# We need to identify each of the 4 const maps and process them independently.
# Strategy: track when we're inside a map, extract keys, skip duplicates.

# Pattern to match a map entry key: '  'some_key': ...'
key_pattern = re.compile(r"^\s+'([^']+)'\s*:")

# Pattern to detect start of each map section
map_start_pattern = re.compile(r"^\s*static\s+const\s+Map<String,\s*String>\s+_\w+\s*=\s*\{")

# Pattern to detect end of a map (line with just `};`)
map_end_pattern = re.compile(r"^\s*\};\s*$")

output_lines = []
in_map = False
seen_keys = set()
removed_dupes = 0
# Track multi-line values: if a line doesn't end with `,` or `{` etc, 
# the value continues on the next line(s)
skip_continuation = False
i = 0
while i < len(fixed_lines):
    line = fixed_lines[i]
    
    # Check if we're starting a new map
    if map_start_pattern.match(line):
        in_map = True
        seen_keys = set()
        output_lines.append(line)
        i += 1
        continue
    
    # Check if we're ending a map
    if in_map and map_end_pattern.match(line):
        in_map = False
        seen_keys = set()
        output_lines.append(line)
        i += 1
        continue
    
    if skip_continuation:
        # We're skipping continuation lines of a duplicate entry
        # Check if this line ends the value (ends with comma, possibly with comment)
        stripped = line.rstrip()
        if stripped.endswith(",") or stripped.endswith("',") or stripped.endswith("\","):
            skip_continuation = False
        i += 1
        continue
    
    if in_map:
        key_match = key_pattern.match(line)
        if key_match:
            key = key_match.group(1)
            if key in seen_keys:
                # Duplicate! Skip this line and any continuation lines
                removed_dupes += 1
                # Check if value continues on next line(s)
                stripped = line.rstrip()
                # A line like `'key': 'value',` is complete
                # A line like `'key':` or `'key': 'long value` continues
                # Check if line ends with a comma after a closing quote
                if not (stripped.endswith("',") or stripped.endswith('",') or stripped.endswith("),")):
                    # Multi-line value - need to skip continuation lines
                    skip_continuation = True
                i += 1
                continue
            else:
                seen_keys.add(key)
    
    output_lines.append(line)
    i += 1

print(f"Removed {removed_dupes} duplicate key entries")
print(f"Output file: {len(output_lines)} lines")

with open(FILE, "w", encoding="utf-8") as f:
    f.writelines(output_lines)

print("Done! File cleaned successfully.")
