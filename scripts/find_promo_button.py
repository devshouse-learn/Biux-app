#!/usr/bin/env python3
"""Find the promotions button in the AppBar by reading lines 100-380"""

file_path = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(file_path, 'r') as f:
    lines = f.readlines()

# Print lines 100-380 with line numbers
for i in range(100, min(380, len(lines))):
    print(f"{i+1:4d}: {lines[i]}", end='')
