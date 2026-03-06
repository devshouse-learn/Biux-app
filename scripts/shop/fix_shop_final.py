#!/usr/bin/env python3
"""
Definitive fix v2 for shop_screen_pro.dart
Removes ALL remaining dead code residue including corrupted UTF-8 bytes.
"""

file_path = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

# Read raw bytes to handle corrupted UTF-8
with open(file_path, 'rb') as f:
    raw = f.read()

# Decode with error replacement for corrupted bytes
content = raw.decode('utf-8', errors='replace')
lines = content.split('\n')

print(f"Total lines in file: {len(lines)}")

# Find _buildChromeStyleAppBar line
appbar_idx = None
for i, line in enumerate(lines):
    if '_buildChromeStyleAppBar' in line and 'Widget' in line:
        appbar_idx = i
        break

print(f"_buildChromeStyleAppBar at line {appbar_idx}")

# Find the doc comment above it
comment_idx = appbar_idx
for i in range(appbar_idx - 1, max(0, appbar_idx - 5), -1):
    stripped = lines[i].strip()
    if stripped.startswith('///') or stripped == '':
        comment_idx = i
    else:
        break

print(f"Comment/blank before AppBar starts at line {comment_idx}")

# Find where the dead code starts
# Look for the first 'canCreateProducts' or corrupted byte after line ~100
dead_start = None
for i in range(100, min(150, len(lines))):
    line = lines[i]
    if '\ufffd' in line:
        # Found corrupted byte - dead code is around here
        # Look backwards for the start
        for j in range(i, max(95, i-15), -1):
            stripped = lines[j].strip()
            if stripped == '' or 'canCreateProducts' in stripped or 'print(' in stripped or 'return Column(' in stripped:
                dead_start = j
            elif stripped.startswith('//'):
                dead_start = j
            else:
                dead_start = j + 1
                break
        break

# If no corrupted byte found, look for the parasitic Column method
if dead_start is None:
    for i in range(105, 160):
        if 'return Column(' in lines[i] and 'mainAxisAlignment =' in (lines[i+1] if i+1 < len(lines) else ''):
            dead_start = i
            break

# Also find the second canCreateProducts block
if dead_start is None:
    for i in range(130, 160):
        if 'canCreateProducts' in lines[i] and i > 108:
            dead_start = i - 2  # Include context before
            break

print(f"Dead code starts at line {dead_start}")

# Verify by printing the lines
if dead_start:
    print(f"\n--- Dead code block (lines {dead_start} to {comment_idx - 1}) ---")
    for i in range(max(dead_start - 3, 0), min(comment_idx + 2, len(lines))):
        marker = ">>>" if dead_start <= i < comment_idx else "   "
        line_repr = repr(lines[i])
        if len(line_repr) > 100:
            line_repr = line_repr[:100] + '...'
        print(f"{marker} L{i}: {line_repr}")

# The replacement FAB code (correct Dart)
fab_replacement = '''            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canCreateProducts) ...[
                  FloatingActionButton(
                    heroTag: 'add_product',
                    onPressed: () {
                      final currentUser = userProvider.user;
                      if (currentUser?.isAdmin == true ||
                          currentUser?.canSellProducts == true) {
                        context.go('/shop/admin');
                      } else {
                        _showPermissionRequestDialog(context);
                      }
                    },
                    backgroundColor: ColorTokens.blackPearl,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                ],
                FloatingActionButton.small(
                  heroTag: 'filters',
                  onPressed: () =>
                      setState(() => _showFilters = !_showFilters),
                  backgroundColor: _showFilters
                      ? Colors.red.shade400
                      : ColorTokens.blackPearl.withOpacity(0.8),
                  child: Icon(
                    _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'scroll_top',
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                  },
                  backgroundColor:
                      ColorTokens.blackPearl.withOpacity(0.8),
                  child: const Icon(Icons.arrow_upward,
                      color: Colors.white, size: 20),
                ),
              ],
            );
          },
        ),
'''

if dead_start is not None and comment_idx is not None:
    # Replace dead code with clean FAB code
    new_lines = lines[:dead_start] + fab_replacement.split('\n') + lines[comment_idx:]
    
    new_content = '\n'.join(new_lines)
    
    # Write back as clean UTF-8
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    new_line_count = len(new_lines)
    removed = comment_idx - dead_start
    added = len(fab_replacement.split('\n'))
    print(f"\nSUCCESS!")
    print(f"  Removed {removed} dead code lines ({dead_start} to {comment_idx - 1})")
    print(f"  Inserted {added} lines of clean FAB code")
    print(f"  New file has {new_line_count} lines (was {len(lines)})")
else:
    print("\nFAILED: Could not determine dead code boundaries")
    print("Manual inspection needed. Showing lines 105-160:")
    for i in range(105, min(160, len(lines))):
        line_repr = repr(lines[i])
        if len(line_repr) > 120:
            line_repr = line_repr[:120] + '...'
        print(f"L{i}: {line_repr}")
