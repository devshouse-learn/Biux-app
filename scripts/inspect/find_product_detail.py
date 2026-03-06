#!/usr/bin/env python3
"""Find product detail route and screen."""

import os

# Search router for product detail route
router_path = '/Users/macmini/biux/lib/core/config/router/app_router.dart'
with open(router_path, 'r') as f:
    content = f.read()
    lines = content.split('\n')

print("=" * 80)
print("ROUTER - shop related routes:")
print("=" * 80)
for i, line in enumerate(lines, 1):
    if 'shop' in line.lower() or 'product' in line.lower():
        start = max(0, i-3)
        end = min(len(lines), i+3)
        for j in range(start, end):
            print(f"L{j+1:4d}: {lines[j]}")
        print("---")

# Find product detail screen
print("\n" + "=" * 80)
print("Searching for product detail screen files:")
print("=" * 80)
shop_screens = '/Users/macmini/biux/lib/features/shop/presentation/screens'
if os.path.exists(shop_screens):
    for f in os.listdir(shop_screens):
        print(f"  {f}")

# Read shop_screen_pro.dart current state - build method area
print("\n" + "=" * 80)
print("Current shop_screen_pro.dart build method (L70-140):")
print("=" * 80)
with open('/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart', 'r') as f:
    lines = f.readlines()
    print(f"Total lines: {len(lines)}")
    for i, line in enumerate(lines[69:139], start=70):
        print(f"L{i:4d}: {line}", end='')
