#!/usr/bin/env python3
"""Find how products are navigated to from shop_screen_pro.dart"""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

print("Lines with context.push or context.go to product:")
print("=" * 80)
for i, line in enumerate(lines, start=1):
    if ('context.push' in line or 'context.go' in line) and ('shop/' in line or 'product' in line.lower()):
        # Show 3 lines before and after
        start = max(0, i-4)
        end = min(len(lines), i+3)
        for j in range(start, end):
            marker = " >>>" if j+1 == i else "    "
            print(f"L{j+1:4d}{marker}: {lines[j]}", end='')
        print("---")

# Also check the router to see if /shop is inside a ShellRoute
print("\n" + "=" * 80)
print("Router - ShellRoute structure:")
print("=" * 80)
router_path = '/Users/macmini/biux/lib/core/config/router/app_router.dart'
with open(router_path, 'r') as f:
    rlines = f.readlines()

for i, line in enumerate(rlines, start=1):
    if 'ShellRoute' in line or 'shell' in line.lower() or 'MainShell' in line:
        start = max(0, i-3)
        end = min(len(rlines), i+5)
        for j in range(start, end):
            print(f"L{j+1:4d}: {rlines[j]}", end='')
        print("---")

# Show area around /shop route definition  
print("\n" + "=" * 80)
print("Router around /shop routes (L650-785):")
print("=" * 80)
for i, line in enumerate(rlines[649:784], start=650):
    print(f"L{i:4d}: {line}", end='')
