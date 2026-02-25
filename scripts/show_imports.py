#!/usr/bin/env python3
"""Show first 20 lines of shop_screen_pro.dart"""
file_path = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'
with open(file_path, 'r') as f:
    lines = f.readlines()
for i in range(min(20, len(lines))):
    print(f"{i+1:4d}: {lines[i]}", end='')
