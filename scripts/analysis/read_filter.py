#!/usr/bin/env python3
with open('/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart', 'r') as f:
    lines = f.readlines()
for i in range(2696, min(2761, len(lines))):
    print(f"{i+1:4d}: {lines[i]}", end='')
