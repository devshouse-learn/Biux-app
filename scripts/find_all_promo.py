#!/usr/bin/env python3
"""Find all references to promotions/campaign/promo in shop_screen_pro.dart"""

file_path = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

keywords = ['campaign', 'promoci', 'promo', 'Promocion', 'comunidad', '_buildPromoBanner', '_showPromotionsBottomSheet']

with open(file_path, 'r') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}\n")

for keyword in keywords:
    print(f"=== '{keyword}' ===")
    for i, line in enumerate(lines):
        if keyword.lower() in line.lower():
            print(f"  {i+1:5d}: {line.rstrip()}")
    print()
