#!/usr/bin/env python3
"""Show ProductEntity and mainImage logic"""

# Shop product entity
filepath1 = '/Users/macmini/biux/lib/features/shop/domain/entities/product_entity.dart'
with open(filepath1, 'r') as f:
    lines = f.readlines()

print(f"=== ProductEntity (shop) - {len(lines)} lines ===")
for i, line in enumerate(lines):
    print(f" {i+1}: {line.rstrip()}")

print("\n" + "="*60)

# Check current filter
filepath2 = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'
with open(filepath2, 'r') as f:
    lines2 = f.readlines()

print("\n=== Current validProducts filter ===")
for i, line in enumerate(lines2):
    if 'validProducts' in line and 'where' in line:
        start = max(0, i-2)
        end = min(len(lines2), i+25)
        for j in range(start, end):
            print(f" {j+1}: {lines2[j].rstrip()}")
        break

print("\n=== Featured section filter ===")
for i, line in enumerate(lines2):
    if 'p.images.isEmpty' in line:
        start = max(0, i-5)
        end = min(len(lines2), i+10)
        for j in range(start, end):
            print(f" {j+1}: {lines2[j].rstrip()}")
        print()
