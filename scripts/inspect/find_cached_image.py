#!/usr/bin/env python3
"""Show the product card image section with errorWidget"""
filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'
with open(filepath, 'r') as f:
    lines = f.readlines()

# Find CachedNetworkImage in product card
print("=== CachedNetworkImage in product cards ===")
for i, line in enumerate(lines):
    if 'CachedNetworkImage' in line:
        start = max(0, i-2)
        end = min(len(lines), i+20)
        print(f"\n--- At line {i+1} ---")
        for j in range(start, end):
            print(f" {j+1}: {lines[j].rstrip()}")
