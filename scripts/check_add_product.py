#!/usr/bin/env python3
"""Check current state of shop files."""
import os

# Check shop_screen_pro.dart current build method
filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'
with open(filepath, 'r') as f:
    lines = f.readlines()
print(f"shop_screen_pro.dart: {len(lines)} lines")

# Show current AppBar menu area
print("\n" + "=" * 80)
print("Current build method + AppBar (L70-100):")
print("=" * 80)
for i, line in enumerate(lines[69:99], start=70):
    print(f"L{i:4d}: {line}", end='')

# Check if add-product screen exists
screens_dir = '/Users/macmini/biux/lib/features/shop/presentation/screens'
print("\n" + "=" * 80)
print("Shop screens:")
print("=" * 80)
for f in sorted(os.listdir(screens_dir)):
    print(f"  {f}")

# Check router for add-product route
router_path = '/Users/macmini/biux/lib/core/config/router/app_router.dart'
with open(router_path, 'r') as f:
    rlines = f.readlines()
print("\n" + "=" * 80)
print("Router - searching for add-product:")
print("=" * 80)
for i, line in enumerate(rlines, start=1):
    if 'add-product' in line or 'add_product' in line or 'addProduct' in line or 'AddProduct' in line:
        start = max(0, i-3)
        end = min(len(rlines), i+5)
        for j in range(start, end):
            print(f"L{j+1:4d}: {rlines[j]}", end='')
        print("---")

# Check category entity for product categories
print("\n" + "=" * 80)
print("Category entity:")
print("=" * 80)
cat_path = '/Users/macmini/biux/lib/features/shop/domain/entities/category_entity.dart'
with open(cat_path, 'r') as f:
    print(f.read())

# Check product entity
print("\n" + "=" * 80)
print("Product entity (first 80 lines):")
print("=" * 80)
prod_path = '/Users/macmini/biux/lib/features/shop/domain/entities/product_entity.dart'
with open(prod_path, 'r') as f:
    plines = f.readlines()
for i, line in enumerate(plines[0:80], start=1):
    print(f"L{i:4d}: {line}", end='')

# Check ShopProvider for addProduct method
print("\n" + "=" * 80)
print("ShopProvider - searching for addProduct/createProduct:")
print("=" * 80)
prov_path = '/Users/macmini/biux/lib/features/shop/presentation/providers/shop_provider.dart'
with open(prov_path, 'r') as f:
    prov_lines = f.readlines()
for i, line in enumerate(prov_lines, start=1):
    if 'addProduct' in line or 'createProduct' in line or 'Future' in line:
        print(f"L{i:4d}: {line}", end='')
