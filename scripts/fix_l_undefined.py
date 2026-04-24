"""
Fix all 'l' undefined errors by injecting the locale variable 
into each file's build method or top-level context.
Also fix 'const' issues where l.t() is used.
"""
import re
import os

def read_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def write_file(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def add_provider_import(content):
    """Add Provider import if not present."""
    if "import 'package:provider/provider.dart'" not in content:
        lines = content.split('\n')
        last_import = 0
        for i, line in enumerate(lines):
            if line.startswith('import '):
                last_import = i
        lines.insert(last_import + 1, "import 'package:provider/provider.dart';")
        content = '\n'.join(lines)
    return content

def inject_l_in_build(content):
    """
    Find build() methods or Widget build() and inject l = Provider.of<LocaleNotifier>(context)
    if not already present. Also handle State classes.
    """
    # Pattern: Widget build(BuildContext context) {
    # We need to add right after the opening brace
    
    # Find all build methods
    pattern = r'(Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{)'
    
    def replacer(match):
        build_line = match.group(1)
        return build_line + "\n    final l = Provider.of<LocaleNotifier>(context);"
    
    # Only add if l is not already defined in that method
    # Check if 'final l = Provider' already exists near build methods
    if 'final l = Provider.of<LocaleNotifier>(context)' not in content and 'l.t(' in content:
        # Check if there's a build method
        if re.search(pattern, content):
            content = re.sub(pattern, replacer, content)
    
    return content

def inject_l_in_specific_methods(content):
    """
    For files where l.t() is used outside build() (like in helper methods, 
    dialogs, callbacks), we need to add l where needed.
    """
    # For simple cases, the build method injection handles it.
    # For callbacks/closures that reference l, they should inherit from build scope.
    return content

def fix_file(filepath):
    """Fix a single file: add imports, inject l, fix const issues."""
    if not os.path.exists(filepath):
        print(f"  SKIP: {filepath}")
        return
    
    content = read_file(filepath)
    original = content
    
    # 1. Ensure imports
    if 'locale_notifier.dart' not in content:
        lines = content.split('\n')
        last_import = 0
        for i, line in enumerate(lines):
            if line.startswith('import '):
                last_import = i
        lines.insert(last_import + 1, "import 'package:biux/core/design_system/locale_notifier.dart';")
        content = '\n'.join(lines)
    
    content = add_provider_import(content)
    
    # 2. Inject l in build methods (if not already present)
    content = inject_l_in_build(content)
    
    # 3. Fix const issues - remove const before expressions using l.t()
    # const Text(l.t(...)) -> Text(l.t(...))
    # const SnackBar(content: Text(l.t(...))) is also invalid
    content = re.sub(r'const\s+(Text\s*\(\s*l\.t\()', r'\1', content)
    content = re.sub(r'const\s+(SnackBar\s*\(\s*content:\s*Text\s*\(\s*l\.t\()', r'\1', content)
    
    if content != original:
        write_file(filepath, content)
        print(f"  FIXED: {filepath}")
    else:
        print(f"  NO CHANGE: {filepath}")

# Files that need fixing
FILES = [
    'lib/core/services/app_update_service.dart',
    'lib/features/achievements/presentation/screens/achievements_screen.dart',
    'lib/features/age_verification/presentation/screens/identity_verification_screen.dart',
    'lib/features/age_verification/presentation/screens/parental_consent_screen.dart',
    'lib/features/chat/presentation/screens/chat_list_screen.dart',
    'lib/features/chat/presentation/screens/chat_screen.dart',
    'lib/features/chat/presentation/screens/chat_settings_screen.dart',
    'lib/features/chat/presentation/screens/location_picker_screen.dart',
    'lib/features/chat/presentation/widgets/chat_input.dart',
    'lib/features/chat/presentation/widgets/message_bubble.dart',
    'lib/features/chat/presentation/widgets/poll_creation_sheet.dart',
    'lib/features/cycling_stats/presentation/screens/cycling_stats_screen.dart',
    'lib/features/education/presentation/screens/education_screen.dart',
    'lib/features/emergency/presentation/screens/emergency_screen.dart',
    'lib/features/experiences/presentation/screens/create_experience_screen.dart',
    'lib/features/experiences/presentation/screens/experiences_list_screen.dart',
    'lib/features/experiences/presentation/widgets/experience_story_viewer.dart',
    'lib/features/experiences/presentation/widgets/profile_highlights.dart',
    'lib/features/experiences/presentation/widgets/video_preview_dialog.dart',
    'lib/features/groups/presentation/screens/my_groups/my_groups_screen.dart',
    'lib/features/maps/presentation/screens/danger_zones_screen.dart',
    'lib/features/ride_recommendations/presentation/widgets/send_recommendation_sheet.dart',
    'lib/features/ride_tracker/presentation/screens/ride_tracker_screen.dart',
    'lib/features/rides/presentation/widgets/ride_attendance_button.dart',
    'lib/features/road_reports/presentation/screens/road_reports_screen.dart',
    'lib/features/safety/presentation/screens/active_sessions_screen.dart',
    'lib/features/safety/presentation/screens/biometric_settings_screen.dart',
    'lib/features/safety/presentation/screens/report_user_screen.dart',
    'lib/features/safety/presentation/screens/two_factor_screen.dart',
    'lib/features/shop/presentation/screens/bike_qr_screen.dart',
    'lib/features/shop/presentation/screens/stolen_bikes_screen.dart',
    'lib/features/social/presentation/screens/post_detail_screen.dart',
    'lib/features/social/presentation/widgets/report_content_dialog.dart',
    'lib/features/users/presentation/screens/accessibility_settings_screen.dart',
    'lib/features/users/presentation/screens/activity_hub_screen.dart',
    'lib/features/users/presentation/screens/activity_posts_screen.dart',
    'lib/features/users/presentation/screens/activity_screen_time_screen.dart',
    'lib/features/users/presentation/screens/activity_stories_screen.dart',
    'lib/features/users/presentation/screens/profile_screen.dart',
    'lib/features/users/presentation/screens/user_profile_screen.dart',
    'lib/features/weather/presentation/screens/weather_screen.dart',
    'lib/shared/services/permission_service.dart',
    'lib/shared/widgets/error_view.dart',
    'lib/features/shop/presentation/screens/cart_screen.dart',
    'lib/features/shop/presentation/screens/seller_dashboard_screen.dart',
    'lib/features/ride_recommendations/presentation/screens/my_recommendations_screen.dart',
    'lib/features/accidents/presentation/screens/accident_report_screen.dart',
    'lib/features/accidents/presentation/screens/accidents_list_screen.dart',
    'lib/features/accidents/presentation/screens/accident_detail_screen.dart',
    'lib/features/settings/presentation/screens/permissions_screen.dart',
]

def main():
    print("Fixing undefined 'l' and const issues...\n")
    for f in FILES:
        fix_file(f)
    print("\nDone!")

if __name__ == '__main__':
    main()
