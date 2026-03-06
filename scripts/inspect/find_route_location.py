#!/usr/bin/env python3
"""Find the product detail route outside shell to add add-product route nearby."""

router_path = '/Users/macmini/biux/lib/core/config/router/app_router.dart'
with open(router_path, 'r') as f:
    lines = f.readlines()

# Find the productDetail route outside shell
for i, line in enumerate(lines, start=1):
    if 'productDetail' in line:
        start = max(0, i-5)
        end = min(len(lines), i+10)
        for j in range(start, end):
            print(f"L{j+1:4d}: {lines[j]}", end='')
        print("---")

# Also check imports for AddProductScreen
print("\nSearching for add_product import:")
for i, line in enumerate(lines, start=1):
    if 'add_product' in line.lower():
        print(f"L{i:4d}: {line}", end='')
