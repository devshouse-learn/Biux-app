#!/usr/bin/env python3
"""Show main_shell.dart around the campaign icon"""

file_path = '/Users/macmini/biux/lib/shared/widgets/main_shell.dart'

with open(file_path, 'r') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}\n")
for i, line in enumerate(lines):
    print(f"{i+1:4d}: {line}", end='')
