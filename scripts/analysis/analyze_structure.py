#!/usr/bin/env python3
"""Analyze shop_screen_pro.dart structure after dead code removal."""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")
print()

# Show lines 130-145 (area after the fix)
print("=" * 80)
print("Lines 130-150 (after dead code removal):")
print("=" * 80)
for i, line in enumerate(lines[129:149], start=130):
    print(f"L{i:4d}: {line}", end='')

print()

# Show lines around 2755-2815 (BikePatternPainter and extension area)
print("=" * 80)
print("Lines 2755-2820 (BikePatternPainter & extension area):")
print("=" * 80)
for i, line in enumerate(lines[2754:2819], start=2755):
    print(f"L{i:4d}: {line}", end='')

print()

# Count braces to check balance
brace_count = 0
for i, line in enumerate(lines, start=1):
    stripped = line.split('//')[0]  # Remove single-line comments
    brace_count += stripped.count('{') - stripped.count('}')

print(f"\nBrace balance: {brace_count} (should be 0)")

# Find where the class _ShopScreenProState ends
print()
print("=" * 80)
print("Last 20 lines of the file:")
print("=" * 80)
for i, line in enumerate(lines[-20:], start=len(lines)-19):
    print(f"L{i:4d}: {line}", end='')
