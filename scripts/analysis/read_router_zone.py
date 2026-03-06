#!/usr/bin/env python3
"""Read router lines around the product detail route outside shell."""

router_path = '/Users/macmini/biux/lib/core/config/router/app_router.dart'
with open(router_path, 'r') as f:
    lines = f.readlines()

# Find relevant sections
for i, line in enumerate(lines):
    ln = i + 1
    stripped = line.strip()
    if any(k in line for k in ['productDetail', 'shop/:id', '/shop/', 'ShellRoute', 'GoRoute', 'add_product', 'product_detail']):
        if ln > 840 and ln < 920:
            print(f"L{ln:4d}: {line}", end='')

print("\n\n=== LINES 845-910 ===")
for i in range(844, min(910, len(lines))):
    print(f"L{i+1:4d}: {lines[i]}", end='')

print(f"\n\nTotal lines: {len(lines)}")

# Check imports section (first 50 lines)
print("\n=== IMPORTS (first 40 lines) ===")
for i in range(min(40, len(lines))):
    print(f"L{i+1:4d}: {lines[i]}", end='')
