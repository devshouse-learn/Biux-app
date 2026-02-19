#!/usr/bin/env python3
"""Read category chips and more areas."""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

# Category chips area (around 200-400)
print("=" * 80)
print("Lines 200-400 (category chips & offers):")
print("=" * 80)
for i, line in enumerate(lines[199:399], start=200):
    print(f"L{i:4d}: {line}", end='')

print()

# Lines 1040-1120 (rest of popup menu)
print("=" * 80)
print("Lines 1040-1150 (popup menu rest):")
print("=" * 80)
for i, line in enumerate(lines[1039:1149], start=1040):
    print(f"L{i:4d}: {line}", end='')
