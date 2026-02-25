#!/usr/bin/env python3
"""Extract key sections from add_product_screen.dart"""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/add_product_screen.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")
print()

# Find key methods/sections
keywords = [
    '_submitProduct', '_saveProduct', '_publishProduct', '_createProduct',
    'submit', 'save', 'publish', 'create',
    '_images', '_selectedImages', 'imageUrls', 'images',
    '_pickImage', '_selectImage', 'ImagePicker',
    'validator', 'validate', '_formKey',
    'ElevatedButton', 'TextButton', 'Publicar', 'Crear', 'Guardar',
]

print("=== Key lines ===")
for i, line in enumerate(lines):
    stripped = line.strip()
    for kw in keywords:
        if kw in stripped and not stripped.startswith('//') and not stripped.startswith('*'):
            print(f" {i+1}: {line.rstrip()}")
            break

# Print the submit/save method
print("\n=== Looking for submit/save/publish/create methods ===")
for i, line in enumerate(lines):
    stripped = line.strip()
    if any(x in stripped for x in ['_submitProduct', '_saveProduct', '_publishProduct', '_createProduct', 'void _submit', 'Future<void> _save', 'Future<void> _submit', 'Future<void> _publish', 'Future<void> _create']):
        # Print 80 lines from here
        print(f"\n--- Found at line {i+1} ---")
        for j in range(i, min(i+80, len(lines))):
            print(f" {j+1}: {lines[j].rstrip()}")

# Print image picker section
print("\n=== Looking for image picker methods ===")
for i, line in enumerate(lines):
    stripped = line.strip()
    if any(x in stripped for x in ['_pickImage', '_selectImage', '_addImage', 'void _pick', 'Future<void> _pick']):
        if 'void' in stripped or 'Future' in stripped:
            print(f"\n--- Found at line {i+1} ---")
            for j in range(i, min(i+40, len(lines))):
                print(f" {j+1}: {lines[j].rstrip()}")

# Print state variables (first 80 lines of the state class)
print("\n=== State variables (lines 20-100) ===")
for j in range(19, min(100, len(lines))):
    print(f" {j+1}: {lines[j].rstrip()}")

# Print the build method start and form
print("\n=== Looking for build method ===")
for i, line in enumerate(lines):
    stripped = line.strip()
    if 'Widget build(BuildContext' in stripped:
        print(f"\n--- Found at line {i+1} ---")
        for j in range(i, min(i+50, len(lines))):
            print(f" {j+1}: {lines[j].rstrip()}")
        break

# Find the actual submit button
print("\n=== Looking for submit button area ===")
for i, line in enumerate(lines):
    if 'Publicar' in line or 'Crear Producto' in line or 'Guardar' in line or 'Agregar Producto' in line:
        if 'Text(' in line or 'child:' in lines[i-1].strip() if i > 0 else False:
            start = max(0, i-5)
            end = min(len(lines), i+10)
            print(f"\n--- Around line {i+1} ---")
            for j in range(start, end):
                print(f" {j+1}: {lines[j].rstrip()}")
