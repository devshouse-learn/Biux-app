#!/usr/bin/env python3
"""Lee las 3 secciones de CachedNetworkImage en shop_screen_pro.dart"""
with open('/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart', 'r') as f:
    lines = f.readlines()

sections = [
    (985, 1020, "SECCION 1 - Featured (linea 993)"),
    (2300, 2345, "SECCION 2 - Grid (linea 2309)"),
    (2572, 2610, "SECCION 3 - List item (linea 2580)"),
]

for start, end, title in sections:
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")
    for i in range(start, min(end, len(lines))):
        print(f"{i+1}: {lines[i]}", end='')
