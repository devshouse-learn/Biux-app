#!/usr/bin/env python3
"""Show lines around 2709 (_clearFilters) for context"""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

print("=== Lines 2700-2730 ===")
for j in range(2699, min(2730, len(lines))):
    print(f" {j+1}: {lines[j].rstrip()}")
