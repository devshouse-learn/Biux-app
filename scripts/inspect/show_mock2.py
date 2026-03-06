#!/usr/bin/env python3
"""Show current mock_products.dart"""
filepath = '/Users/macmini/biux/lib/features/shop/data/datasources/mock_products.dart'
with open(filepath, 'r') as f:
    content = f.read()
print(content)
