#!/usr/bin/env python3
"""Show _buildPromoBanner and _showPromotionsBottomSheet"""

file_path = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(file_path, 'r') as f:
    lines = f.readlines()

# Show _buildPromoBanner (starts ~1437)
print("=== _buildPromoBanner ===")
for i in range(1434, min(1930, len(lines))):
    print(f"{i+1:5d}: {lines[i]}", end='')

print("\n\n=== _showPromotionsBottomSheet ===")
for i in range(3305, min(3370, len(lines))):
    print(f"{i+1:5d}: {lines[i]}", end='')
