#!/usr/bin/env python3
"""Read the Chrome style AppBar and FAB area."""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

# Build method with FAB
print("BUILD METHOD + FAB (L70-140):")
print("=" * 80)
for i, line in enumerate(lines[69:139], start=70):
    print(f"L{i:4d}: {line}", end='')

# Chrome style AppBar
print("\n" + "=" * 80)
print("_buildChromeStyleAppBar (L139-280):")
print("=" * 80)
for i, line in enumerate(lines[138:279], start=139):
    print(f"L{i:4d}: {line}", end='')
