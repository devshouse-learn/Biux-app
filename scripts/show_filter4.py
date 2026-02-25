#!/usr/bin/env python3
filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'
with open(filepath, 'r') as f:
    lines = f.readlines()
# Just print lines 2700-2760
for j in range(2699, min(2760, len(lines))):
    print(f" {j+1}: {lines[j].rstrip()}")
