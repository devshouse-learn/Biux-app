#!/usr/bin/env python3
"""Show context around suspicious promo references"""

file_path = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(file_path, 'r') as f:
    lines = f.readlines()

# Lines to inspect (0-indexed): 483, 737, 3343, 3371
targets = [483, 737, 3343, 3371]

for target in targets:
    start = max(0, target - 10)
    end = min(len(lines), target + 10)
    print(f"\n{'='*60}")
    print(f"Context around line {target}:")
    print(f"{'='*60}")
    for i in range(start, end):
        marker = ">>>" if i == target - 1 else "   "
        print(f"{marker} {i+1:5d}: {lines[i]}", end='')
    print()
