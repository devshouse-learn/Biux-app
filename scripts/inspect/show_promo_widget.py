#!/usr/bin/env python3
"""Show current state of promotions_widget.dart"""
file_path = '/Users/macmini/biux/lib/features/shop/presentation/widgets/promotions_widget.dart'
with open(file_path, 'r') as f:
    lines = f.readlines()
print(f"Total lines: {len(lines)}\n")
for i, line in enumerate(lines):
    print(f"{i+1:5d}: {line}", end='')
