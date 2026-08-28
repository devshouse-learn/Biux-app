#!/usr/bin/env python3
"""Remove all duplicate translation blocks from app_translations.dart"""
import re

# Read the file
with open('lib/core/config/app_translations.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Strategy: Find and remove entire duplicate blocks
# Duplicate blocks are identified by specific markers

# 1. English duplicate block: starts after first 'deactivated': 'Disabled', 
#    and ends before Portuguese section starts

# Find English section end (before Portuguese)
english_dup_start = content.find("    'deactivated': 'Disabled',\n\n    // Profile image picker\n    'change_profile_photo': 'Change profile photo',\n    'use_camera': 'Use camera',\n    'choose_existing_photo': 'Choose existing photo',\n    'use_default_avatar': 'Use default avatar',\n    'whatsapp_number':")

if english_dup_start == -1:
    print("Could not find English duplicate block start")
else:
    print(f"Found English duplicate block start at position {english_dup_start}")
    
    # Find the end of this duplicate block (look for the closing }; followed by Portuguese marker)
    search_start = english_dup_start + 100  # Skip past the start marker
    pt_start = content.find("static const Map<String, String> _pt = {", search_start)
    
    if pt_start == -1:
        print("Could not find Portuguese section start")
    else:
        # Go back to find the closing brace and semicolon before Portuguese
        closing_brace = content.rfind("  };", english_dup_start, pt_start)
        print(f"Portuguese section starts at position {pt_start}")
        print(f"Closing brace found at position {closing_brace}")
        
        if closing_brace != -1:
            # Calculate lines to show what will be removed
            removed_text = content[english_dup_start:closing_brace + 5]
            line_count = removed_text.count('\n')
            print(f"Will remove approximately {line_count} lines from English section")
