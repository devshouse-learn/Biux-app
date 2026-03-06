#!/usr/bin/env python3
"""Read specific line ranges from files for debugging."""

# Read shop_screen_pro.dart lines 60-190
print("=" * 80)
print("shop_screen_pro.dart lines 60-190 (1-indexed):")
print("=" * 80)
with open('/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart', 'r') as f:
    lines = f.readlines()
    for i, line in enumerate(lines[59:189], start=60):
        print(f"L{i:4d}: {line}", end='')

print("\n")
print("=" * 80)
print("color_tokens.dart full content:")
print("=" * 80)
with open('/Users/macmini/biux/lib/core/design_system/color_tokens.dart', 'r') as f:
    content = f.read()
    print(content)
