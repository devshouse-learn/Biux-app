#!/usr/bin/env python3
"""Lee lineas 2685-2740 del archivo para ver conflictos restantes"""
with open('/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart', 'r') as f:
    lines = f.readlines()
for i in range(2684, 2740):
    if i < len(lines):
        print(f"{i+1}: {lines[i]}", end='')
