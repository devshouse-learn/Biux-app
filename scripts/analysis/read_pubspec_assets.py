#!/usr/bin/env python3
"""Lee la seccion assets del pubspec.yaml"""
with open('/Users/macmini/biux/pubspec.yaml', 'r') as f:
    lines = f.readlines()
for i, line in enumerate(lines):
    if 'assets' in line.lower() or 'img' in line.lower():
        start = max(0, i-1)
        end = min(len(lines), i+5)
        for j in range(start, end):
            print(f"{j+1}: {lines[j]}", end='')
        print("---")
