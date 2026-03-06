#!/usr/bin/env python3
"""Read product_detail_screen.dart"""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/product_detail_screen.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")
print()

# Show first 120 lines (imports, class, build method)
for i, line in enumerate(lines[0:120], start=1):
    print(f"L{i:4d}: {line}", end='')

print("\n\n... searching for Scaffold, AppBar, backgroundColor ...")
for i, line in enumerate(lines, start=1):
    low = line.lower()
    if any(x in low for x in ['scaffold', 'appbar', 'backgroundcolor', 'pop', 'navigator', 'context.go', 'context.pop', 'willpopscope', 'popscope', 'leading']):
        print(f"L{i:4d}: {line}", end='')
