#!/usr/bin/env python3
import sys

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/add_product_screen.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

# Print lines 185-200 (around image picker call in build)
print("=== Lines 185-200 (image picker in build) ===")
for j in range(184, min(200, len(lines))):
    print(f" {j+1}: {lines[j].rstrip()}")

# Print lines 339-440 (_buildImagePicker method)
print("\n=== Lines 339-440 (_buildImagePicker) ===")
for j in range(338, min(440, len(lines))):
    print(f" {j+1}: {lines[j].rstrip()}")
