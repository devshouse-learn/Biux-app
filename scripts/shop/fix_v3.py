#!/usr/bin/env python3
"""Ultra-simple: remove lines containing corrupted bytes and surrounding dead code."""
import re

fp = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(fp, 'rb') as f:
    raw = f.read()

text = raw.decode('utf-8', errors='replace')
lines = text.split('\n')
print(f"Lines before: {len(lines)}")

# Find ALL lines with the replacement character
corrupt = [i for i, l in enumerate(lines) if '\ufffd' in l]
print(f"Corrupted lines: {corrupt}")

if not corrupt:
    print("No corrupted bytes found! Checking for PROBE markers...")
    for i, l in enumerate(lines):
        if 'PROBE' in l:
            print(f"  PROBE at L{i}: {l.strip()[:60]}")
    exit(0)

# The dead code block is around these corrupted lines.
# Find contiguous block: go backwards and forwards from first corrupt line
first_corrupt = corrupt[0]
last_corrupt = corrupt[-1]

# Scan backwards: remove lines that are clearly dead code
start = first_corrupt
for i in range(first_corrupt - 1, max(0, first_corrupt - 20), -1):
    s = lines[i].strip()
    if s == '' or 'print(' in s or ('canCreateProducts' in s and 'final' not in s):
        start = i
    elif s in ['{', '}', '};', '},', ');', '),']:
        start = i
    else:
        break

# Scan forwards: remove lines until we hit good code
end = last_corrupt + 1
for i in range(last_corrupt + 1, min(len(lines), last_corrupt + 60)):
    s = lines[i].strip()
    if s == '' or 'PROBE' in s:
        end = i + 1
    elif s in ['{', '}', '};', '},', ');', '),']:
        end = i + 1
    elif ('canCreateProducts' in s and 'final' not in s) or 'print(' in s:
        end = i + 1
    elif 'return Column(' in s:
        # Check if this is the BAD Column (with = instead of :)
        next_line = lines[i+1].strip() if i+1 < len(lines) else ''
        if '=' in next_line and 'MainAxisAlignment' in next_line:
            # Bad column - include everything up to its closing
            end = i + 1
            # Find the closing of this bad block
            brace_count = 0
            for j in range(i, min(len(lines), i + 80)):
                brace_count += lines[j].count('(') - lines[j].count(')')
                brace_count += lines[j].count('[') - lines[j].count(']')
                end = j + 1
                if brace_count <= 0 and j > i:
                    break
        else:
            break
    elif 'mainAxisAlignment' in s and '=' in s and ':' not in s:
        end = i + 1
    elif 'children =' in s or 'children=' in s:
        end = i + 1
    else:
        break

print(f"\nRemoving lines {start} to {end-1} ({end-start} lines)")
print("--- Removed content ---")
for i in range(start, end):
    print(f"  L{i}: {repr(lines[i][:80])}")
print("--- End ---")

# Check what comes right after
print(f"\nLine after removal (L{end}): {repr(lines[end][:80]) if end < len(lines) else 'EOF'}")
print(f"Line before removal (L{start-1}): {repr(lines[start-1][:80]) if start > 0 else 'BOF'}")

new_lines = lines[:start] + lines[end:]
new_text = '\n'.join(new_lines)

with open(fp, 'w', encoding='utf-8') as f:
    f.write(new_text)

print(f"\nLines after: {len(new_lines)}")
print("Done! File written.")

# Verify
with open(fp, 'r', encoding='utf-8') as f:
    check = f.read()
if '\ufffd' in check:
    print("WARNING: Still has corrupted bytes!")
else:
    print("OK: No corrupted bytes remain.")
