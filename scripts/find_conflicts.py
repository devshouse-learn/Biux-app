#!/usr/bin/env python3
"""Encuentra los marcadores de conflicto en shop_screen_pro.dart"""
with open('/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart', 'r') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if '<<<<<<<' in line or '=======' in line or '>>>>>>>' in line:
        start = max(0, i - 3)
        end = min(len(lines), i + 4)
        print(f"--- Conflicto en linea {i+1} ---")
        for j in range(start, end):
            print(f"{j+1}: {lines[j]}", end='')
        print()
