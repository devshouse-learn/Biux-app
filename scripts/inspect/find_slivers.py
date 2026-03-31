#!/usr/bin/env python3
"""Find the main build method and show the slivers list, 
also find any widget with campaign/promo that's NOT inside:
- _buildChromeStyleAppBar (lines 102-378)
- _buildPromoBanner (starts ~1437)
- _showPromotionsBottomSheet (starts ~3308)
- PopupMenuButton area
And IS in the main slivers or visible UI
"""

file_path = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(file_path, 'r') as f:
    lines = f.readlines()

# Find the build method and show slivers
print("=== Looking for 'slivers' in build method ===")
for i, line in enumerate(lines):
    if 'slivers' in line.lower() and i < 600:
        start = max(0, i - 2)
        end = min(len(lines), i + 40)
        print(f"\nContext around line {i+1}:")
        for j in range(start, end):
            print(f"  {j+1:5d}: {lines[j]}", end='')
        print()
        break

# Find _buildFeaturedSection to see if promo is embedded there
print("\n=== _buildFeaturedSection ===")
for i, line in enumerate(lines):
    if '_buildFeaturedSection' in line and 'Widget' in line:
        start = i
        end = min(len(lines), i + 50)
        for j in range(start, end):
            print(f"  {j+1:5d}: {lines[j]}", end='')
        print()
        break

# Find _buildMinimalToolbar
print("\n=== _buildMinimalToolbar ===")
for i, line in enumerate(lines):
    if '_buildMinimalToolbar' in line and 'Widget' in line:
        start = i
        end = min(len(lines), i + 80)
        for j in range(start, end):
            print(f"  {j+1:5d}: {lines[j]}", end='')
        print()
        break

# Find _buildCategoryDropdown
print("\n=== _buildCategoryDropdown ===")
for i, line in enumerate(lines):
    if '_buildCategoryDropdown' in line and 'Widget' in line:
        start = i
        end = min(len(lines), i + 80)
        for j in range(start, end):
            print(f"  {j+1:5d}: {lines[j]}", end='')
        print()
        break
