#!/usr/bin/env python3
"""Lee lineas 2770-2780 de shop_screen_pro.dart para ver donde insertar el helper"""
with open('/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart', 'r') as f:
    lines = f.readlines()
for i in range(2768, 2785):
    if i < len(lines):
        print(f"{i+1}: {lines[i]}", end='')
