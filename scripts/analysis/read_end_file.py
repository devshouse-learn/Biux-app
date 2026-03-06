#!/usr/bin/env python3
"""Busca la linea final del archivo shop_screen_pro.dart"""
with open('/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart', 'r') as f:
    lines = f.readlines()

total = len(lines)
print(f"Total lineas: {total}")
print()
# Mostrar ultimas 20 lineas
for i in range(max(0, total-20), total):
    print(f"{i+1}: {lines[i]}", end='')
