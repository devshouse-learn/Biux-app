#!/usr/bin/env python3
filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/add_product_screen.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")

# Show the image section header area
print("\n=== Image section header (around line 189) ===")
for i, line in enumerate(lines):
    if "OBLIGATORIO" in line or "Imágenes *" in line:
        start = max(0, i-2)
        end = min(len(lines), i+15)
        for j in range(start, end):
            print(f" {j+1}: {lines[j].rstrip()}")
        break

# Show the submit validation area
print("\n=== Submit validation (around _submitProduct) ===")
for i, line in enumerate(lines):
    if "_submitProduct" in line and "Future" in line:
        for j in range(i, min(i+50, len(lines))):
            print(f" {j+1}: {lines[j].rstrip()}")
        break

# Show the image picker styling
print("\n=== Image picker styling ===")
for i, line in enumerate(lines):
    if "add_a_photo_outlined" in line or "Colors.red.shade50" in line:
        start = max(0, i-5)
        end = min(len(lines), i+20)
        for j in range(start, end):
            print(f" {j+1}: {lines[j].rstrip()}")
        print("...")
        break
