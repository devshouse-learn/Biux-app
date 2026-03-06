#!/usr/bin/env python3
"""Read imports and state variables."""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

# Show imports (first 25 lines)
print("IMPORTS (L1-25):")
print("=" * 80)
for i, line in enumerate(lines[0:25], start=1):
    print(f"L{i:4d}: {line}", end='')

# Show state variables (L28-72)
print("\n" + "=" * 80)
print("STATE CLASS & VARIABLES (L28-72):")
print("=" * 80)
for i, line in enumerate(lines[27:71], start=28):
    print(f"L{i:4d}: {line}", end='')

# Show _buildOffersBar continuation (L464-570)
print("\n" + "=" * 80)
print("_buildOffersBar continuation (L464-570):")
print("=" * 80)
for i, line in enumerate(lines[463:569], start=464):
    print(f"L{i:4d}: {line}", end='')

# Show the _showPermissionRequestDialog
print("\n" + "=" * 80)
print("_showPermissionRequestDialog area (L2750-2762):")
print("=" * 80)
for i, line in enumerate(lines[2749:2761], start=2750):
    print(f"L{i:4d}: {line}", end='')
