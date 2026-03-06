#!/usr/bin/env python3
filepath = '/Users/macmini/biux/lib/features/shop/data/datasources/product_remote_datasource.dart'
with open(filepath, 'r') as f:
    lines = f.readlines()
print(f"Total: {len(lines)} lines")
for i, line in enumerate(lines):
    print(f" {i+1}: {line.rstrip()}")
