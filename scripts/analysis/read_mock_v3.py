#!/usr/bin/env python3
with open('/Users/macmini/biux/lib/features/shop/data/datasources/mock_products.dart', 'r') as f:
    lines = f.readlines()
for i, line in enumerate(lines, 1):
    print(f"{i}: {line}", end='')
