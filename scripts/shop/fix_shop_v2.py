#!/usr/bin/env python3
"""
Definitive fix v2 for shop_screen_pro.dart
Removes ALL remaining dead code lines containing corrupted UTF-8 bytes,
PROBE markers, orphaned print( calls, and stale canCreateProducts references.
"""

file_path = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(file_path, 'rb') as f:
    raw = f.read()

content = raw.decode('utf-8', errors='replace')
lines = content.split('\n')

print(f"Total lines before: {len(lines)}")

# Strategy: remove any line that contains:
# 1. The replacement char \ufffd (corrupted byte)
# 2. 'PROBE_FOUND' or 'PROBE' marker text
# 3. Lines that are part of the dead code residue
#
# We need to be surgical - only remove lines between the FAB code and
# the _buildChromeStyleAppBar method.

# Find key landmarks
fab_return_line = None  # "return Column(" - the GOOD one from our inserted code
appbar_line = None      # "_buildChromeStyleAppBar"

for i, line in enumerate(lines):
    if '_buildChromeStyleAppBar' in line and 'Widget' in line:
        appbar_line = i
        break

# Find the comment above _buildChromeStyleAppBar
appbar_comment = appbar_line
if appbar_line:
    for i in range(appbar_line - 1, max(0, appbar_line - 5), -1):
        stripped = lines[i].strip()
        if stripped.startswith('///') or stripped == '':
            appbar_comment = i
        else:
            break

print(f"_buildChromeStyleAppBar at line {appbar_line}")
print(f"Comment starts at line {appbar_comment}")

# Find lines to remove: any line containing corrupted bytes or PROBE markers
lines_to_remove = set()
for i in range(len(lines)):
    line = lines[i]
    if '\ufffd' in line:
        lines_to_remove.add(i)
        print(f"  Corrupted byte at L{i}: {repr(line[:80])}")
    if 'PROBE_FOUND' in line or 'PROBE' in line and 'dead code' in line:
        lines_to_remove.add(i)
        print(f"  PROBE marker at L{i}: {repr(line[:80])}")

# Now find the dead code residue block around the corrupted lines
# Look for the 'if (canCreateProducts)' and 'print(' lines near the corrupted byte
if lines_to_remove:
    corrupt_line = min(lines_to_remove)
    
    # Scan backwards from corrupted byte to find start of dead block
    dead_start = corrupt_line
    for i in range(corrupt_line - 1, max(0, corrupt_line - 20), -1):
        stripped = lines[i].strip()
        # These are all part of the dead code residue
        if ('canCreateProducts' in stripped and 'final' not in stripped and 
            'if' in stripped and i > 100):
            dead_start = i
        elif stripped == '' and i == corrupt_line - 1:
            dead_start = i
        elif 'print(' in stripped and i > 100 and i < corrupt_line + 3:
            dead_start = i
        elif stripped.startswith('//') and 'dead code' not in stripped.lower():
            break
        else:
            # Check if this looks like orphaned code (no valid Dart structure)
            if stripped in ['}', '{', '};', '},', ');', ''] and i > corrupt_line - 5:
                dead_start = i
            else:
                break
    
    # Scan forwards from corrupted byte to find end of dead block
    dead_end = max(lines_to_remove) + 1
    for i in range(max(lines_to_remove) + 1, min(len(lines), max(lines_to_remove) + 30)):
        stripped = lines[i].strip()
        # Check if this line is dead code residue
        if stripped in ['', '}', '{', '};', '},', ');', '// PROBE2_FOUND']:
            dead_end = i + 1
        elif 'canCreateProducts' in stripped and 'final' not in stripped:
            dead_end = i + 1
        elif 'print(' in stripped and i < corrupt_line + 10:
            dead_end = i + 1
        elif 'PROBE' in stripped:
            dead_end = i + 1
        elif 'return Column(' in stripped and 'mainAxisAlignment =' in (lines[i+1] if i+1 < len(lines) else ''):
            # This is a dead code Column with = instead of :
            # Find where it ends
            dead_end = i + 1
            for j in range(i + 1, min(len(lines), i + 80)):
                dead_end = j + 1
                if lines[j].strip().startswith('/// ') and 'AppBar' in lines[j]:
                    dead_end = j  # Don't include the AppBar comment
                    break
                if '_buildChromeStyleAppBar' in lines[j]:
                    dead_end = j  # Don't include the method
                    break
        else:
            break
    
    # Also check for orphaned closing brackets after our FAB code
    # The error showed }, ), at L191, L192  
    # Look after the Column closing for extra }, ),
    for i in range(100, appbar_comment if appbar_comment else len(lines)):
        stripped = lines[i].strip()
        # Find the end of our inserted FAB code (the );  },  ), sequence)
        if stripped == '),' and i > 100:
            # Check if the next lines are orphaned }, ),
            j = i + 1
            while j < len(lines) and j < i + 10:
                s = lines[j].strip()
                if s in ['', '}', '{', '};', '},', ');', '),']:
                    if j not in range(dead_start, dead_end):
                        # Check if this is between FAB code and dead code
                        pass
                else:
                    break
                j += 1

    # Ensure we don't remove too much or too little
    # The dead block should be between the FAB code end and _buildChromeStyleAppBar
    print(f"\nDead code residue: lines {dead_start} to {dead_end - 1}")
    print(f"\n--- Lines being removed ---")
    for i in range(dead_start, dead_end):
        print(f"  L{i}: {repr(lines[i][:100])}")
    
    # Remove the dead code
    new_lines = lines[:dead_start] + lines[dead_end:]
    
    print(f"\nLines before: {len(lines)}")
    print(f"Lines after: {len(new_lines)}")
    print(f"Removed: {dead_end - dead_start} lines")
    
    # Write clean file
    new_content = '\n'.join(new_lines)
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print("\nFile written successfully!")
    
    # Verify no more corrupted bytes
    with open(file_path, 'r', encoding='utf-8') as f:
        verify = f.read()
    if '\ufffd' in verify:
        print("WARNING: Still has replacement characters!")
    else:
        print("VERIFIED: No more corrupted bytes!")

else:
    print("\nNo corrupted bytes found. Checking for other issues...")
    # Show lines 130-200 for manual inspection
    for i in range(130, min(200, len(lines))):
        print(f"L{i}: {repr(lines[i][:100])}")
