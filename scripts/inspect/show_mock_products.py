#!/usr/bin/env python3
"""Show mock products to see their image URLs"""

filepath = '/Users/macmini/biux/lib/features/shop/data/datasources/mock_products.dart'
with open(filepath, 'r') as f:
    lines = f.readlines()

print(f"=== mock_products.dart ({len(lines)} lines) ===")
for i, line in enumerate(lines):
    print(f" {i+1}: {line.rstrip()}")
