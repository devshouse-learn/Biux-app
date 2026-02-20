#!/usr/bin/env python3
"""
Script to remove the remaining dead code block (lines with corrupted UTF-8 bytes)
from shop_screen_pro.dart.
"""

FILE_PATH = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

# Read the file with error handling for corrupted bytes
with open(FILE_PATH, 'r', errors='replace') as f:
    lines = f.readlines()

print(f"Total lines before: {len(lines)}")

# Find the dead code markers
lines_to_remove = []
for i, line in enumerate(lines):
    # Find lines with our markers or corrupted content
    if 'PROBE_FOUND' in line or 'PROBE2' in line or 'CORRUPTION_LINE_MARKER' in line:
        lines_to_remove.append(i)
        print(f"  Marker found at line {i+1}: {repr(line.rstrip()[:80])}")
    # Find the corrupted byte (replacement character)
    if '\ufffd' in line:
        if i not in lines_to_remove:
            lines_to_remove.append(i)
        print(f"  Corrupted byte at line {i+1}: {repr(line.rstrip()[:80])}")

# Also find the dead code block: if(canCreateProducts) { print( pattern
# We need to find the block between the children ], and the /// AppBar comment

# Find children ], (end of Column children list - the one with heroTag: 'filters')
filters_line = None
for i, line in enumerate(lines):
    if "heroTag: 'filters'" in line:
        filters_line = i
        print(f"\nheroTag: 'filters' at line {i+1}")
        break

# Find ], after filters (children close)
children_close = None
if filters_line:
    for i in range(filters_line, min(filters_line + 15, len(lines))):
        if lines[i].strip() == '],':
            children_close = i
            print(f"children ], at line {i+1}")
            break

# Find /// AppBar comment
appbar_line = None
for i, line in enumerate(lines):
    if 'AppBar limpio estilo Chrome Web Store' in line:
        appbar_line = i
        print(f"/// AppBar at line {i+1}")
        break

# Find Widget _buildChromeStyleAppBar
method_line = None
for i, line in enumerate(lines):
    if 'Widget _buildChromeStyleAppBar()' in line:
        method_line = i
        print(f"_buildChromeStyleAppBar at line {i+1}")
        break

if children_close is None or appbar_line is None:
    print("ERROR: Could not find anchors")
    exit(1)

# Now let's look at what's between children_close and appbar_line
print(f"\n--- Lines between children ], (L{children_close+1}) and /// AppBar (L{appbar_line+1}) ---")
for i in range(children_close, appbar_line + 1):
    print(f"  L{i+1}: {repr(lines[i].rstrip()[:100])}")

# Strategy: Keep lines from children_close that are valid closing brackets
# Remove everything else (dead code) until appbar_line
# Expected closing sequence after ],: 
#   );    <- close Column
#   },    <- close builder
#   ),    <- close Consumer  
#   );    <- close Scaffold return
#   }     <- close build method

# Check what closing brackets already exist
valid_closings = []
dead_code_start = None
for i in range(children_close + 1, appbar_line):
    stripped = lines[i].strip()
    if stripped in [');', '},', '),', ');', '}', ''] and dead_code_start is None:
        valid_closings.append(i)
        print(f"  Valid closing at L{i+1}: {stripped}")
    else:
        if dead_code_start is None and stripped != '':
            dead_code_start = i
            print(f"  Dead code starts at L{i+1}: {stripped[:60]}")

if dead_code_start is None:
    dead_code_start = appbar_line
    
print(f"\nDead code range: L{dead_code_start+1} to L{appbar_line}")
print(f"Lines to delete: {appbar_line - dead_code_start}")

# Check if we have enough closing brackets
# We need: );  },  ),  );  }  (5 closings)
expected_closings = [');', '},', '),', ');', '}']
print(f"\nExisting closings: {len(valid_closings)}")
print(f"Expected closings: {len(expected_closings)}")

# Build new file
new_lines = []
# Keep everything up to and including children_close
new_lines.extend(lines[:children_close + 1])

# Add the existing valid closing brackets
for idx in valid_closings:
    new_lines.append(lines[idx])

# Check if we need more closings
existing_stripped = [lines[idx].strip() for idx in valid_closings]
print(f"Existing closing brackets: {existing_stripped}")

# If we don't have the right closings, add them
if len(valid_closings) < 5:
    needed = expected_closings[len(valid_closings):]
    print(f"Adding missing closings: {needed}")
    indent_levels = [10, 8, 6, 4, 2]  # spaces for each level
    for j, closing in enumerate(needed):
        idx = len(valid_closings) + j
        if idx < len(indent_levels):
            spaces = ' ' * indent_levels[idx]
        else:
            spaces = '  '
        new_lines.append(f'{spaces}{closing}\n')

# Add empty line
new_lines.append('\n')

# Add everything from appbar_line onwards
new_lines.extend(lines[appbar_line:])

# Write the file
with open(FILE_PATH, 'w') as f:
    f.writelines(new_lines)

print(f"\nDone! New file has {len(new_lines)} lines (was {len(lines)})")
removed = len(lines) - len(new_lines)
print(f"Net lines removed: {removed}")
