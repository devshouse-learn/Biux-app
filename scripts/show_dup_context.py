#!/usr/bin/env python3
"""Show context around the first (earlier) occurrence of each duplicate key in _es section."""
import re

with open('lib/core/config/app_translations.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Duplicate keys with their FIRST occurrence line numbers (the ones to remove)
first_lines = {
    'time_ago_minutes': 1083,
    'time_ago_hours': 1082,
    'time_ago_days': 1081,
    'take_photo': 158,
    'select_from_gallery': 159,
    'report_tab': 582,
    'report_accident': 2050,
    'resolved': 1522,
    'sending': 1587,
    'send_report': 486,
    'list_tab': 580,
    'next': 1172,
    'search_hint': 629,
    'no_results_found': 591,
    'no_followers_yet': 194,
    'not_following_anyone': 195,
    'edit_profile': 166,
    'edit_username': 209,
    'error_updating_profile': 210,
    'cover_photo': 1901,
    'route': 2043,
    'order_number_prefix': 1633,
    'products_label': 1384,
    'filter_all': 630,
    'new_notification': 450,
    'create_ride': 223,
    'meeting_point': 288,
    'ride_created_success': 302,
    'publish': 462,
    'edit_group': 346,
    'group_created_success': 379,
    'cancel': 25,
    'retry': 197,
    'members': 337,
}

# Sort by line number
sorted_lines = sorted(first_lines.items(), key=lambda x: x[1])

for key, line_num in sorted_lines:
    idx = line_num - 1  # 0-based
    print(f"\n--- Key: '{key}' at line {line_num} ---")
    # Show the exact line content
    print(f"  LINE {line_num}: {lines[idx].rstrip()}")
    # Show 1 line before and after for context
    if idx > 0:
        print(f"  LINE {line_num-1}: {lines[idx-1].rstrip()}")
    if idx < len(lines) - 1:
        print(f"  LINE {line_num+1}: {lines[idx+1].rstrip()}")
