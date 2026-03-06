#!/usr/bin/env python3
"""Busca donde se renderiza la imagen del producto en shop_screen_pro.dart"""
import re

with open('/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart', 'r') as f:
    lines = f.readlines()

# Buscar donde se usa mainImage, Image.network, CachedNetworkImage, etc.
keywords = ['mainImage', 'Image.network', 'CachedNetworkImage', 'NetworkImage', 'product.images', 'imageUrl']
for i, line in enumerate(lines):
    for kw in keywords:
        if kw.lower() in line.lower():
            # Imprimir contexto: 2 lineas antes y 2 despues
            start = max(0, i - 2)
            end = min(len(lines), i + 3)
            print(f"--- Encontrado '{kw}' en linea {i+1} ---")
            for j in range(start, end):
                marker = ">>>" if j == i else "   "
                print(f"{marker} {j+1}: {lines[j]}", end='')
            print()
