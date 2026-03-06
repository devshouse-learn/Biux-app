#!/usr/bin/env python3
"""Show current _isRealProductImage method"""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'
with open(filepath, 'r') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if '_isRealProductImage' in line and 'static bool' in line:
        end = i + 70
        for j in range(i, min(end, len(lines))):
            print(f" {j+1}: {lines[j].rstrip()}")
            if j > i and lines[j].strip() == '}' and not any(c in lines[j+1] if j+1 < len(lines) else True for c in [' ']):
                break
        break
