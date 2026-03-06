#!/usr/bin/env python3
"""Read product_detail_screen build method."""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/product_detail_screen.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

# Show L145-170 (goBack method)
print("=" * 80)
print("_goBack method (L145-160):")
print("=" * 80)
for i, line in enumerate(lines[144:165], start=145):
    print(f"L{i:4d}: {line}", end='')

# Show L460-530 (build method with Scaffold)
print("\n" + "=" * 80)
print("Build method - Scaffold area (L458-535):")
print("=" * 80)
for i, line in enumerate(lines[457:534], start=458):
    print(f"L{i:4d}: {line}", end='')
