#!/usr/bin/env python3
"""
Script to fix shop_screen_pro.dart by removing dead code block
and inserting proper closing brackets.
"""

import re

FILE_PATH = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

# Read the file with error handling for corrupted bytes
with open(FILE_PATH, 'r', errors='replace') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")

# Find the line with heroTag: 'filters' (unique anchor in the good FAB code)
filters_line = None
for i, line in enumerate(lines):
    if "heroTag: 'filters'" in line:
        filters_line = i
        print(f"Found heroTag: 'filters' at line {i+1}: {line.rstrip()}")
        break

if filters_line is None:
    print("ERROR: Could not find heroTag: 'filters'")
    exit(1)

# Find the ], that closes the children list (should be a few lines after filters)
children_close_line = None
for i in range(filters_line, min(filters_line + 15, len(lines))):
    stripped = lines[i].strip()
    if stripped == '],':
        children_close_line = i
        print(f"Found ], at line {i+1}: {lines[i].rstrip()}")
        break

if children_close_line is None:
    print("ERROR: Could not find ], after filters FAB")
    exit(1)

# Find the /// AppBar comment line (with possible markers)
appbar_line = None
for i, line in enumerate(lines):
    if 'AppBar' in line and 'limpio estilo Chrome Web Store' in line:
        appbar_line = i
        print(f"Found AppBar comment at line {i+1}: {line.rstrip()}")
        break

if appbar_line is None:
    print("ERROR: Could not find AppBar comment")
    exit(1)

# Find _buildChromeStyleAppBar method declaration
method_line = None
for i, line in enumerate(lines):
    if '_buildChromeStyleAppBar' in line and 'Widget' in line:
        method_line = i
        print(f"Found _buildChromeStyleAppBar at line {i+1}: {line.rstrip()}")
        break

if method_line is None:
    print("ERROR: Could not find _buildChromeStyleAppBar method")
    exit(1)

# Now remove everything from children_close_line+1 to appbar_line-1
# and replace with proper closing brackets
print(f"\nWill delete lines {children_close_line+2} to {appbar_line} (inclusive)")
print(f"That's {appbar_line - children_close_line - 1} lines of dead code")

# Build the replacement: proper closing brackets
closing_brackets = [
    '            ],\n',           # close children list (already exists at children_close_line)
    '          );\n',             # close Column
    '        },\n',              # close builder function body  
    '      ),\n',                # close Consumer
    '    );\n',                  # close Scaffold return
    '  }\n',                     # close build method
    '\n',                        # empty line
]

# The children_close_line already has ],
# So we keep lines[0:children_close_line+1] (including the ],)
# Then add closing brackets
# Then keep lines from appbar_line onwards

# But first, clean up the appbar comment line (remove */ and markers)
appbar_comment = lines[appbar_line]
# Remove */ prefix if present
appbar_comment = re.sub(r'^\s*\*/\s*', '  ', appbar_comment)
# Remove markers like _ANCHOR_END_FOUND_CHECK
appbar_comment = appbar_comment.replace('_ANCHOR_END_FOUND_CHECK', '')
appbar_comment = appbar_comment.replace('AppBar_ANCHOR_END_FOUND', 'AppBar')
appbar_comment = appbar_comment.replace('AppBar_ANCHOR_END', 'AppBar')
# Clean up double spaces
appbar_comment = re.sub(r'  +', ' ', appbar_comment.strip())
appbar_comment = '  /// ' + appbar_comment.lstrip('/ ').strip() + '\n'
print(f"Cleaned AppBar comment: {appbar_comment.rstrip()}")

# Also fix the method name if it has _PROBE suffix
if method_line is not None:
    lines[method_line] = lines[method_line].replace('_buildChromeStyleAppBar_PROBE', '_buildChromeStyleAppBar')

# Also fix FIRST_COLUMN_MARKER and ERR_CHECK markers  
for i in range(len(lines)):
    lines[i] = lines[i].replace('/*FIRST_COLUMN_MARKER*/ //ERR_CHECK', '')
    lines[i] = lines[i].replace('/*FIRST_COLUMN_MARKER*/', '')
    lines[i] = lines[i].replace('//ERR_CHECK', '')

# Also check if crossAxisAlignment: CrossAxisAlignment.end is causing issues
# Column DOES have crossAxisAlignment, but let's keep it for now

# Build new file
new_lines = []
# Keep everything up to and including children_close_line
new_lines.extend(lines[:children_close_line + 1])

# Add proper closing brackets (without the ],  since it's already there)
new_lines.append('          );\n')             # close Column
new_lines.append('        },\n')              # close builder function body  
new_lines.append('      ),\n')                # close Consumer
new_lines.append('    );\n')                  # close Scaffold return
new_lines.append('  }\n')                     # close build method
new_lines.append('\n')                        # empty line

# Add cleaned AppBar comment
new_lines.append(appbar_comment)

# Add everything from method_line onwards (the actual method)
new_lines.extend(lines[method_line:])

# Write the file
with open(FILE_PATH, 'w') as f:
    f.writelines(new_lines)

print(f"\nDone! New file has {len(new_lines)} lines (was {len(lines)})")
print("Removed dead code block and added proper closing brackets.")
print(f"Lines removed: {appbar_line - children_close_line - 1}")
