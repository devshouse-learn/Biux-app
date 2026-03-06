#!/usr/bin/env python3
"""
Script to remove the dead code block (lines 136-211, 0-indexed 135-210)
from shop_screen_pro.dart which contains corrupted UTF-8 bytes and
a parasitic Column method declaration.
"""
import sys

file_path = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

# Read with error handling for corrupted bytes
with open(file_path, 'rb') as f:
    raw = f.read()

# Decode with replacement for corrupted bytes
content = raw.decode('utf-8', errors='replace')
lines = content.split('\n')

print(f"Total lines: {len(lines)}")

# Show lines around the dead code block for verification
print("\n--- Lines 130-215 (0-indexed) ---")
for i in range(130, min(216, len(lines))):
    line_repr = repr(lines[i])
    if len(line_repr) > 120:
        line_repr = line_repr[:120] + '...'
    print(f"L{i}: {line_repr}")

# Find the exact boundaries
# Start: after the last good line before dead code (should be around L134)
# End: just before _buildChromeStyleAppBar (should be around L212)

# Look for _buildChromeStyleAppBar
appbar_line = None
for i, line in enumerate(lines):
    if '_buildChromeStyleAppBar' in line and 'Widget' in line:
        appbar_line = i
        break

# Look for the comment above _buildChromeStyleAppBar
comment_line = None
if appbar_line:
    for i in range(appbar_line - 1, max(0, appbar_line - 5), -1):
        if '///' in lines[i] or lines[i].strip() == '':
            comment_line = i
        else:
            break

print(f"\n_buildChromeStyleAppBar found at line {appbar_line}")
print(f"Comment/blank starts at line {comment_line}")

# Find where the dead code starts - look for the print( with corrupted byte
dead_start = None
for i in range(130, 145):
    if '\ufffd' in lines[i] or 'PROBE' in lines[i] or 'canCreateProducts' in lines[i]:
        if dead_start is None:
            dead_start = i
        
print(f"Dead code starts at line {dead_start}")

# The dead code block is from dead_start to (comment_line or appbar_line - 1)
dead_end = (comment_line if comment_line else appbar_line) if appbar_line else None
print(f"Dead code ends before line {dead_end}")

if dead_start is not None and dead_end is not None:
    print(f"\nWill remove lines {dead_start} to {dead_end - 1} (inclusive)")
    print(f"That's {dead_end - dead_start} lines to remove")
    
    # Create new content without the dead code
    new_lines = lines[:dead_start] + lines[dead_end:]
    
    print(f"\nOriginal: {len(lines)} lines")
    print(f"New: {len(new_lines)} lines")
    
    # Write back
    new_content = '\n'.join(new_lines)
    # Write as UTF-8, replacing any remaining bad chars
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print("\nFile written successfully!")
else:
    print("\nCould not determine dead code boundaries. Manual intervention needed.")
    print("Showing suspicious lines:")
    for i in range(130, 215):
        if i < len(lines):
            if '\ufffd' in lines[i]:
                print(f"  CORRUPTED at L{i}: {repr(lines[i][:80])}")
