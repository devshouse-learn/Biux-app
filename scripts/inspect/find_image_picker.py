#!/usr/bin/env python3
"""Extract _buildImagePicker method from add_product_screen.dart"""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/add_product_screen.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

# Find _buildImagePicker and print it
for i, line in enumerate(lines):
    if '_buildImagePicker()' in line and 'Widget' in line:
        # Print until we find the closing of the method
        brace_count = 0
        started = False
        for j in range(i, min(i+100, len(lines))):
            print(f" {j+1}: {lines[j].rstrip()}")
            for ch in lines[j]:
                if ch == '{':
                    brace_count += 1
                    started = True
                elif ch == '}':
                    brace_count -= 1
            if started and brace_count == 0:
                break
        break

# Also show the section header for images area in build method (around line 192)
print("\n=== Around line 192 (image picker in build) ===")
for j in range(185, 200):
    print(f" {j+1}: {lines[j].rstrip()}")
