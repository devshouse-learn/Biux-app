#!/usr/bin/env python3
"""Lee las lineas del filtro de imagenes en shop_screen_pro.dart"""
with open('/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart', 'r') as f:
    lines = f.readlines()
for i in range(2696, 2770):
    if i < len(lines):
        print(f"{i+1}: {lines[i]}", end='')
