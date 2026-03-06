#!/usr/bin/env python3
with open('/Users/macmini/biux/firebase.json', 'r') as f:
    content = f.read()
print(repr(content[:500]))
