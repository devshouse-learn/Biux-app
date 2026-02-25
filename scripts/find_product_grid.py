#!/usr/bin/env python3
"""Find product grid and image validation logic"""
file_path = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'
with open(file_path, 'r') as f:
    lines = f.readlines()

# Find _buildProductsGrid
print("=== _buildProductsGrid ===")
for i, line in enumerate(lines):
    if '_buildProductsGrid' in line and 'Widget' in line:
        for j in range(i, min(len(lines), i + 80)):
            print(f"{j+1:5d}: {lines[j]}", end='')
        break

# Find product card builder
print("\n\n=== _buildProductCard ===")
for i, line in enumerate(lines):
    if '_buildProductCard' in line and 'Widget' in line:
        for j in range(i, min(len(lines), i + 60)):
            print(f"{j+1:5d}: {lines[j]}", end='')
        break

# Find where products are filtered
print("\n\n=== filteredProducts / where / images ===")
for i, line in enumerate(lines):
    if 'filteredProducts' in line or ('images' in line and 'where' in line.lower()):
        print(f"{i+1:5d}: {lines[i]}", end='')
