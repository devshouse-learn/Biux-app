#!/usr/bin/env python3
filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'
with open(filepath, 'r') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if '_isRealProductImage' in line and 'static bool' in line:
        for j in range(i, min(i+60, len(lines))):
            print(f" {j+1}: {lines[j].rstrip()}")
            if j > i+2 and lines[j].strip() == '}' and (j+1 >= len(lines) or not lines[j+1].strip().startswith('}')):
                # Check if next non-empty line is a new method
                if j+1 < len(lines) and (lines[j+1].strip() == '' or 'static' in lines[j+1] or '///' in lines[j+1]):
                    break
        break
