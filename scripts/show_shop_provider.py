#!/usr/bin/env python3
"""Show the shop provider loadProducts method"""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/providers/shop_provider.dart'
with open(filepath, 'r') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")

# Find loadProducts method
for i, line in enumerate(lines):
    if 'loadProducts' in line and ('Future' in line or 'void' in line or 'async' in line):
        start = i
        end = min(len(lines), i + 50)
        print(f"\n=== loadProducts (line {i+1}) ===")
        for j in range(start, end):
            print(f" {j+1}: {lines[j].rstrip()}")

# Find where mock is used
print("\n=== Lines with 'mock' or 'Mock' ===")
for i, line in enumerate(lines):
    if 'mock' in line.lower() or 'Mock' in line:
        print(f" {i+1}: {lines[i].rstrip()}")

# Find firestore error handling
print("\n=== Lines with 'catch' or 'error' ===")
for i, line in enumerate(lines):
    if 'catch' in line.lower() or 'Error' in line or 'error' in line:
        print(f" {i+1}: {lines[i].rstrip()}")
