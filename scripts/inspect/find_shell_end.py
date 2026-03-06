#!/usr/bin/env python3
"""Find exact closing of ShellRoute routes array."""

router_path = '/Users/macmini/biux/lib/core/config/router/app_router.dart'

with open(router_path, 'r') as f:
    lines = f.readlines()

# Show lines around the end of ShellRoute (around L840-860)
print("Router L835-870 (end of ShellRoute):")
print("=" * 80)
for i, line in enumerate(lines[834:869], start=835):
    print(f"L{i:4d}: {line}", end='')

# Also show what's right after (external routes)
print("\n" + "=" * 80)
print("Router L850-870 (after ShellRoute):")
print("=" * 80)
for i, line in enumerate(lines[849:869], start=850):
    print(f"L{i:4d}: {line}", end='')
