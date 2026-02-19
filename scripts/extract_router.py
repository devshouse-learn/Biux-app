#!/usr/bin/env python3
"""Extract router lines 840-890 and imports."""
path = '/Users/macmini/biux/lib/core/config/router/app_router.dart'
with open(path, 'r') as f:
    lines = f.readlines()

output = '/Users/macmini/biux/scripts/router_extract.txt'
with open(output, 'w') as out:
    out.write(f"Total lines: {len(lines)}\n\n")
    
    out.write("=== IMPORTS (lines 1-35) ===\n")
    for i in range(min(35, len(lines))):
        out.write(f"L{i+1:4d}: {lines[i]}")
    
    out.write("\n\n=== LINES 840-890 ===\n")
    for i in range(839, min(890, len(lines))):
        out.write(f"L{i+1:4d}: {lines[i]}")
    
    out.write("\n\n=== SEARCH: shop/:id, publicBike, productDetail ===\n")
    for i, line in enumerate(lines):
        if any(k in line for k in ['shop/:id', 'shop/:', 'productDetail', 'publicBike', 'product_detail', 'add_product', 'addProduct']):
            out.write(f"L{i+1:4d}: {line}")
    
    out.write("\nDone.\n")

print(f"Written to {output}")
