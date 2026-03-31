#!/usr/bin/env python3
"""Analyze router structure deeply for the shell issue."""

router_path = '/Users/macmini/biux/lib/core/config/router/app_router.dart'

with open(router_path, 'r') as f:
    lines = f.readlines()

# Show the full ShellRoute structure with indentation to understand nesting
print("=" * 80)
print("FULL ROUTER STRUCTURE (showing route paths and nesting):")
print("=" * 80)

indent = 0
for i, line in enumerate(lines, 1):
    stripped = line.strip()
    if 'ShellRoute' in stripped:
        print(f"L{i:4d}: {'  ' * indent}SHELL_ROUTE")
        indent += 1
    elif "path:" in stripped and "'/'" in stripped or "path:" in stripped and "'/" in stripped:
        # Extract the path
        import re
        match = re.search(r"path:\s*['\"]([^'\"]+)['\"]", stripped)
        if match:
            print(f"L{i:4d}: {'  ' * indent}PATH: {match.group(1)}")
    elif 'GoRoute(' in stripped:
        pass  # will show path on next relevant line
    elif stripped == '],':
        if indent > 0:
            indent -= 1

# Now specifically show the product detail route and what's around it
print("\n" + "=" * 80)
print("Router L770-780 (product detail route):")
print("=" * 80)
for i, line in enumerate(lines[769:779], start=770):
    print(f"L{i:4d}: {line}", end='')

# Show how shop_screen_pro navigates to products - check all push/go calls
print("\n" + "=" * 80)
print("product_detail_screen.dart - full build method area:")
print("=" * 80)

pd_path = '/Users/macmini/biux/lib/features/shop/presentation/screens/product_detail_screen.dart'
with open(pd_path, 'r') as f:
    pd_lines = f.readlines()

# Show the error scaffold and loading scaffold (they may not have proper back navigation)
for i, line in enumerate(pd_lines[461:500], start=462):
    print(f"L{i:4d}: {line}", end='')

# Check if there's a WillPopScope or PopScope
print("\n" + "=" * 80)
print("Searching for PopScope/WillPopScope in product_detail_screen:")
print("=" * 80)
found = False
for i, line in enumerate(pd_lines, start=1):
    if 'PopScope' in line or 'WillPopScope' in line or 'onPopInvoked' in line:
        print(f"L{i:4d}: {line}", end='')
        found = True
if not found:
    print("NOT FOUND")

# Check the error and loading scaffolds for AppBar leading button
print("\n" + "=" * 80)
print("Error scaffold AppBar (L465-468):")
print("=" * 80)
for i, line in enumerate(pd_lines[464:470], start=465):
    print(f"L{i:4d}: {line}", end='')

print("\n" + "=" * 80)
print("Loading scaffold AppBar (L491-496):")
print("=" * 80)
for i, line in enumerate(pd_lines[490:497], start=491):
    print(f"L{i:4d}: {line}", end='')

# Check main_shell.dart to understand shell behavior
print("\n" + "=" * 80)
print("MainShell widget:")
print("=" * 80)
shell_path = '/Users/macmini/biux/lib/shared/widgets/main_shell.dart'
with open(shell_path, 'r') as f:
    shell_lines = f.readlines()
print(f"Total lines: {len(shell_lines)}")
for i, line in enumerate(shell_lines[0:80], start=1):
    print(f"L{i:4d}: {line}", end='')
