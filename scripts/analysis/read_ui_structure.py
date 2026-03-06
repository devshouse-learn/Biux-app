#!/usr/bin/env python3
"""Read key sections of shop_screen_pro.dart for UI restructuring."""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")

# Show the build method and Scaffold structure (lines 72-140)
print("\n" + "=" * 80)
print("BUILD METHOD & SCAFFOLD (L72-140):")
print("=" * 80)
for i, line in enumerate(lines[71:139], start=72):
    print(f"L{i:4d}: {line}", end='')

# Show category chips method
print("\n" + "=" * 80)
print("SEARCHING for _buildCategoryChips:")
print("=" * 80)
for i, line in enumerate(lines, start=1):
    if '_buildCategoryChips' in line and 'Widget' in line:
        start = max(0, i-2)
        end = min(len(lines), i+80)
        for j, l in enumerate(lines[start:end], start=start+1):
            print(f"L{j:4d}: {l}", end='')
        break

# Show offers bar
print("\n" + "=" * 80)
print("SEARCHING for _buildOffersBar:")
print("=" * 80)
for i, line in enumerate(lines, start=1):
    if '_buildOffersBar' in line and 'Widget' in line:
        start = max(0, i-2)
        end = min(len(lines), i+80)
        for j, l in enumerate(lines[start:end], start=start+1):
            print(f"L{j:4d}: {l}", end='')
        break

# Show ShopInfoWidget
print("\n" + "=" * 80)
print("SEARCHING for ShopInfoWidget:")
print("=" * 80)
for i, line in enumerate(lines, start=1):
    if 'ShopInfoWidget' in line:
        print(f"L{i:4d}: {line}", end='')

# Show ShopAdminDashboardWidget
print("\n" + "=" * 80)
print("SEARCHING for ShopAdminDashboardWidget:")
print("=" * 80)
for i, line in enumerate(lines, start=1):
    if 'ShopAdminDashboardWidget' in line:
        print(f"L{i:4d}: {line}", end='')

# Show FAB area
print("\n" + "=" * 80)
print("FAB AREA (L106-133):")
print("=" * 80)
for i, line in enumerate(lines[105:132], start=106):
    print(f"L{i:4d}: {line}", end='')

# Show _showFlashOffersDialog and related methods
print("\n" + "=" * 80)
print("SEARCHING for Flash/Group/Premium/Shipping dialog methods:")
print("=" * 80)
for i, line in enumerate(lines, start=1):
    if any(x in line for x in ['_showFlashOffersDialog', '_showGroupDiscountsDialog', '_showPremiumProductsDialog', '_showShippingDiscountsDialog']):
        print(f"L{i:4d}: {line}", end='')

# Show _buildMinimalToolbar
print("\n" + "=" * 80)
print("SEARCHING for _buildMinimalToolbar:")
print("=" * 80)
for i, line in enumerate(lines, start=1):
    if '_buildMinimalToolbar' in line and 'Widget' in line:
        start = max(0, i-2)
        end = min(len(lines), i+60)
        for j, l in enumerate(lines[start:end], start=start+1):
            print(f"L{j:4d}: {l}", end='')
        break
