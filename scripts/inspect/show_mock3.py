#!/usr/bin/env python3
filepath = '/Users/macmini/biux/lib/features/shop/data/datasources/mock_products.dart'
with open(filepath, 'r') as f:
    lines = f.readlines()
for i, line in enumerate(lines):
    print(f" {i+1}: {line.rstrip()}")
