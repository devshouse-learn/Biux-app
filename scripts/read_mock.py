#!/usr/bin/env python3
with open('/Users/macmini/biux/lib/features/shop/data/datasources/mock_products.dart', 'r') as f:
    for i, line in enumerate(f, 1):
        print(f"{i:3d}: {line}", end='')
