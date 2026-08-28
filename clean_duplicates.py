import re
from pathlib import Path

file_path = Path('lib/core/config/app_translations.dart')
content = file_path.read_text('utf-8')

# Split the file into sections
lines = content.split('\n')

# Find where each language map starts
language_start_lines = {}

for i, line in enumerate(lines):
    if "static const Map<String, String> _es =" in line:
        language_start_lines['es'] = i
    elif "static const Map<String, String> _en =" in line:
        language_start_lines['en'] = i
    elif "static const Map<String, String> _pt =" in line:
        language_start_lines['pt'] = i
    elif "static const Map<String, String> _fr =" in line:
        language_start_lines['fr'] = i
    elif "static const Map<String, String> _it =" in line:
        language_start_lines['it'] = i

print(f"Language sections start at:")
for lang, line_no in sorted(language_start_lines.items(), key=lambda x: x[1]):
    print(f"  {lang}: line {line_no + 1}")

# Determine the end of each language section
def find_section_end(start_line, lines):
    """Find where a language section ends"""
    brace_count = 0
    found_opening = False
    
    for i in range(start_line, len(lines)):
        line = lines[i]
        for char in line:
            if char == '{':
                brace_count += 1
                found_opening = True
            elif char == '}':
                brace_count -= 1
                if found_opening and brace_count == 0:
                    return i
    return len(lines) - 1

language_ranges = {}
for lang, start_line in sorted(language_start_lines.items(), key=lambda x: x[1]):
    end_line = find_section_end(start_line, lines)
    language_ranges[lang] = (start_line, end_line)
    print(f"{lang} section: lines {start_line + 1} to {end_line + 1}")

# Process each language section to remove duplicates
def remove_duplicates_in_section(section_lines):
    """Remove duplicate keys in a language section"""
    seen_keys = set()
    lines_to_keep = []
    skip_next_lines = False
    
    i = 0
    while i < len(section_lines):
        line = section_lines[i]
        
        # Check if this line contains a key-value pair
        key_match = re.match(r"\s*'([^']+)':\s*", line)
        
        if key_match:
            key = key_match.group(1)
            
            # Collect the full entry (may span multiple lines for multiline strings)
            entry_lines = [line]
            i += 1
            
            # Handle multiline string values (continue until we find the closing quote and comma)
            while i < len(section_lines):
                next_line = section_lines[i]
                entry_lines.append(next_line)
                # Check if this line ends the entry (has trailing comma or is followed by new key)
                if re.search(r",\s*$", next_line) or re.match(r"\s*'[^']+':\s*", next_line):
                    if re.match(r"\s*'[^']+':\s*", next_line):
                        # We've read one line too many
                        entry_lines.pop()
                        i -= 1
                    break
                i += 1
            
            if key not in seen_keys:
                seen_keys.add(key)
                lines_to_keep.extend(entry_lines)
            else:
                print(f"  Removing duplicate key: {key}")
            
            i += 1
        else:
            # Not a key line, keep it (comments, braces, etc)
            lines_to_keep.append(line)
            i += 1
    
    return lines_to_keep

# Process each language section
new_lines = lines.copy()

for lang in sorted(language_ranges.keys(), key=lambda x: language_ranges[x][0], reverse=True):
    start, end = language_ranges[lang]
    print(f"\nProcessing {lang.upper()} section (lines {start+1}-{end+1})...")
    
    section_to_clean = new_lines[start:end+1]
    cleaned = remove_duplicates_in_section(section_to_clean)
    
    # Replace the section
    new_lines[start:end+1] = cleaned
    print(f"  After cleanup: {len(cleaned)} lines (was {end - start + 1})")

# Write the file back
output_content = '\n'.join(new_lines)
file_path.write_text(output_content, 'utf-8')

print(f"\nFile cleaned and saved!")
print(f"Final line count: {len(new_lines)}")
print(f"File ends with: {repr(output_content[-50:])}")
