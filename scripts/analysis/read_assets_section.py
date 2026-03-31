#!/usr/bin/env python3
"""Lee la seccion flutter: assets: del pubspec.yaml"""
with open('/Users/macmini/biux/pubspec.yaml', 'r') as f:
    content = f.read()

# Buscar la seccion assets
lines = content.split('\n')
in_flutter = False
in_assets = False
for i, line in enumerate(lines):
    if line.strip() == 'flutter:':
        in_flutter = True
    if in_flutter and 'assets:' in line:
        in_assets = True
        start = max(0, i-1)
        end = min(len(lines), i+15)
        for j in range(start, end):
            print(f"{j+1}: {lines[j]}")
        break
