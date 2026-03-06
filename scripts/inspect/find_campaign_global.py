#!/usr/bin/env python3
"""Find campaign/megaphone icon in main shell, app bar, and navigation files"""
import os

root = '/Users/macmini/biux/lib'
keywords = ['campaign', 'notifications', 'bocina', 'megaphone', 'announcement']

for dirpath, dirnames, filenames in os.walk(root):
    for fname in filenames:
        if fname.endswith('.dart'):
            fpath = os.path.join(dirpath, fname)
            with open(fpath, 'r') as f:
                lines = f.readlines()
            for i, line in enumerate(lines):
                for kw in keywords:
                    if kw.lower() in line.lower():
                        print(f"{fpath}:{i+1}: {line.rstrip()}")
