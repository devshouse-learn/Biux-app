#!/usr/bin/env python3
"""
Nuclear option: Read file as bytes, find and remove ALL lines 
between line 136 (0-indexed) and the line containing 'mainAxisAlignment:' 
that follows the corrupted byte.
"""
fp = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(fp, 'rb') as f:
    raw_bytes = f.read()

# Split by newline bytes
byte_lines = raw_bytes.split(b'\n')
print(f"Total byte-lines: {len(byte_lines)}")

# Find lines with non-UTF8 bytes (the corrupted byte 0xF0 without continuation)
bad_lines = []
for i, bl in enumerate(byte_lines):
    try:
        bl.decode('utf-8')
    except UnicodeDecodeError:
        bad_lines.append(i)
        print(f"BAD UTF-8 at line {i}: {bl[:60]}")

if not bad_lines:
    print("No bad UTF-8 lines found!")
    # Check for replacement char
    text = raw_bytes.decode('utf-8')
    if '\ufffd' in text:
        lines = text.split('\n')
        for i, l in enumerate(lines):
            if '\ufffd' in l:
                bad_lines.append(i)
                print(f"Replacement char at line {i}: {l[:60]}")

if not bad_lines:
    print("File is clean!")
    exit(0)

first_bad = bad_lines[0]
last_bad = bad_lines[-1]

# Find start of dead block (scan backwards)
start = first_bad
for i in range(first_bad - 1, max(0, first_bad - 10), -1):
    line_text = byte_lines[i].decode('utf-8', errors='replace').strip()
    if line_text == '' or 'canCreateProducts' in line_text or 'print(' in line_text:
        start = i
    elif line_text in ['{', '}', '};', '},', ');']:
        start = i
    else:
        break

# Find end of dead block (scan forwards)
end = last_bad + 1
for i in range(last_bad + 1, min(len(byte_lines), last_bad + 10)):
    line_text = byte_lines[i].decode('utf-8', errors='replace').strip()
    if line_text == '' or 'PROBE' in line_text or 'canCreateProducts' in line_text:
        end = i + 1
    elif line_text in ['{', '}', '};', '},', ');']:
        end = i + 1
    else:
        break

print(f"\nWill remove lines {start} to {end-1}")
for i in range(start, end):
    print(f"  DEL L{i}: {byte_lines[i][:80]}")

# Show context
if start > 0:
    print(f"\nBefore (L{start-1}): {byte_lines[start-1][:80]}")
print(f"After  (L{end}):   {byte_lines[end][:80]}")

# Remove and write
new_byte_lines = byte_lines[:start] + byte_lines[end:]
new_content = b'\n'.join(new_byte_lines)

with open(fp, 'wb') as f:
    f.write(new_content)

print(f"\nDone! Removed {end - start} lines. New total: {len(new_byte_lines)}")

# Final verify
try:
    new_content.decode('utf-8')
    print("VERIFIED: File is valid UTF-8!")
except UnicodeDecodeError as e:
    print(f"WARNING: Still has bad bytes: {e}")
