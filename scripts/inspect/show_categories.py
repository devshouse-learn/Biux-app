#!/usr/bin/env python3
"""Show _buildCategoryDropdown"""
file_path = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'
with open(file_path, 'r') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if '_buildCategoryDropdown' in line and 'Widget' in line:
        start = i
        end = min(len(lines), i + 60)
        for j in range(start, end):
            print(f"{j+1:5d}: {lines[j]}", end='')
        break
