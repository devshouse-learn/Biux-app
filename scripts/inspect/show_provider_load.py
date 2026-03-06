#!/usr/bin/env python3
filepath = '/Users/macmini/biux/lib/features/shop/presentation/providers/shop_provider.dart'
with open(filepath, 'r') as f:
    lines = f.readlines()

print(f"Total: {len(lines)} lines")

# Find loadProducts and mock usage
for i, line in enumerate(lines):
    low = line.lower()
    if 'mock' in low or 'loadproducts' in low or 'catch' in line or 'firestore' in low:
        if not line.strip().startswith('//') and not line.strip().startswith('*'):
            print(f" {i+1}: {lines[i].rstrip()}")

# Show loadProducts method completely
print("\n=== loadProducts method ===")
for i, line in enumerate(lines):
    if 'loadProducts' in line and ('Future' in line or 'void' in line):
        for j in range(i, min(i+60, len(lines))):
            print(f" {j+1}: {lines[j].rstrip()}")
        break
