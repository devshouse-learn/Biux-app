#!/usr/bin/env python3
"""
Script to remove the corrupted _buildBenefitCardCORRUPTED method
from shop_screen_pro.dart.

Strategy: Find the line with '// ZZZMARKER1', then find the line 
with '_buildBenefitCard(' (the real one, NOT CORRUPTED), and delete
everything from ZZZMARKER1 through the line before _buildBenefitCard.
"""

import sys

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

print(f"Total lines before cleanup: {len(lines)}")

# Find ZZZMARKER1 line
marker1_idx = None
for i, line in enumerate(lines):
    if '// ZZZMARKER1' in line:
        marker1_idx = i
        print(f"Found ZZZMARKER1 at line {i+1}: {line.rstrip()}")
        break

if marker1_idx is None:
    print("ERROR: Could not find // ZZZMARKER1")
    sys.exit(1)

# Find the real _buildBenefitCard (NOT CORRUPTED)
real_method_idx = None
for i, line in enumerate(lines):
    if i <= marker1_idx:
        continue
    stripped = line.strip()
    if 'Widget _buildBenefitCard(' in stripped and 'CORRUPTED' not in stripped:
        real_method_idx = i
        print(f"Found real _buildBenefitCard at line {i+1}: {line.rstrip()}")
        break

if real_method_idx is None:
    print("ERROR: Could not find real _buildBenefitCard")
    sys.exit(1)

# Delete from marker1_idx to real_method_idx (exclusive)
delete_count = real_method_idx - marker1_idx
print(f"Will delete {delete_count} lines (lines {marker1_idx+1} to {real_method_idx})")

# Show first and last few lines being deleted
print("\nFirst 5 lines to delete:")
for i in range(marker1_idx, min(marker1_idx + 5, real_method_idx)):
    print(f"  {i+1}: {lines[i].rstrip()}")

print("\nLast 5 lines to delete:")
for i in range(max(marker1_idx, real_method_idx - 5), real_method_idx):
    print(f"  {i+1}: {lines[i].rstrip()}")

# Confirm
if '--dry-run' in sys.argv:
    print("\nDRY RUN - no changes made")
    sys.exit(0)

# Perform deletion
new_lines = lines[:marker1_idx] + lines[real_method_idx:]
print(f"\nTotal lines after cleanup: {len(new_lines)}")

with open(filepath, 'w') as f:
    f.writelines(new_lines)

print("File written successfully!")
