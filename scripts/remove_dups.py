"""Remove duplicate keys from the newly added translations block."""

import re

FILE = r'c:\Users\Usuario\Biux-app\Biux-app\lib\core\config\app_translations.dart'

with open(FILE, 'r', encoding='utf-8') as f:
    content = f.read()

# Keys that already existed and need to be removed from our new additions
duplicates = [
    'accessibility_appearance',
    'all_filter',
    'change_attendance_status',
    'find_amazing_products',
    'no_seller_permissions',
    'not_going_anymore',
    'products_colon',
    'put_products_here',
    'stock_issues',
    'text_size_label',
    'time_days_ago',
    'time_hours_ago',
    'time_minutes_ago',
    'time_now',
]

# Remove duplicate lines - each duplicate appears as a line like:
#     'key': 'value',
# We need to remove the SECOND occurrence (our addition) not the first (original)
for key in duplicates:
    # Pattern: find all lines with this key
    pattern = re.compile(r"^    '" + re.escape(key) + r"':.*\n", re.MULTILINE)
    matches = list(pattern.finditer(content))
    
    if len(matches) >= 2:
        # For each language section, we have 2 occurrences - remove the last one in each section
        # Strategy: find pairs and remove the second of each pair
        # Since we have 5 sections, we should have pairs in each
        pass

# Better approach: remove lines from our added blocks specifically
# Our blocks were added right after 'your_recent_stories' lines
# Let's find the positions of each language section's additions and remove duplicates from there

lines = content.split('\n')
new_lines = []
# Track which section we're in
# Our additions come after the last 'your_recent_stories' line in each section
# and before the closing '};'

# Find the line numbers of our addition blocks
# They start after 'your_recent_stories' and end at the '};' that closes the section
section_ends = []
for i, line in enumerate(lines):
    if "'your_recent_stories'" in line:
        section_ends.append(i)

# For each key, remove lines that appear AFTER a 'your_recent_stories' line
# (these are our additions)
removal_patterns = set()
for key in duplicates:
    removal_patterns.add("    '" + key + "':")

skip_next = False
for i, line in enumerate(lines):
    stripped = line.strip()
    should_remove = False
    
    # Check if this line starts with one of the duplicate key patterns
    for pat in removal_patterns:
        if line.startswith(pat) or line.lstrip().startswith("'" + pat.strip().lstrip("'")) :
            pass
    
    # Check if this line is in our added section (after a your_recent_stories line)
    # by checking if it's within 100 lines after a section_end marker
    for se in section_ends:
        if se < i <= se + 95:  # Our additions are ~92 lines
            # Check if this line contains a duplicate key
            for key in duplicates:
                if ("'" + key + "':") in line:
                    should_remove = True
                    break
            break
    
    if not should_remove:
        new_lines.append(line)

content_new = '\n'.join(new_lines)

with open(FILE, 'w', encoding='utf-8') as f:
    f.write(content_new)

print(f'Removed {len(lines) - len(new_lines)} duplicate lines')
