"""
Fix round 2: For State classes, add a getter for 'l' so it's accessible
everywhere. For non-build contexts, add local l definitions.
Also fix remaining const issues.
"""
import re
import os

def read_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def write_file(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_state_classes(content):
    """
    For State classes, replace the build-method-level 'final l = ...' with 
    a class-level getter, so l is accessible in all methods.
    """
    # Find State class definitions
    # Pattern: class _XxxState extends State<Xxx> {
    state_pattern = r'(class\s+_?\w+State\s+extends\s+State<[^>]+>\s*(?:with\s+[^{]+)?\{)'
    
    matches = list(re.finditer(state_pattern, content))
    
    if matches:
        # Remove any build-method-level l definition
        content = content.replace(
            "    final l = Provider.of<LocaleNotifier>(context);\n    final l = Provider.of<LocaleNotifier>(context);",
            "    final l = Provider.of<LocaleNotifier>(context);"
        )
        
        for match in reversed(matches):
            class_header = match.group(1)
            insert_pos = match.end()
            
            # Check if getter already exists in this class
            # Find the end of this class (next class definition or end of file)
            next_class = re.search(r'\nclass\s+', content[insert_pos:])
            class_end = insert_pos + next_class.start() if next_class else len(content)
            class_body = content[insert_pos:class_end]
            
            if 'LocaleNotifier get l' not in class_body:
                getter = '\n  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);\n'
                content = content[:insert_pos] + getter + content[insert_pos:]
                
                # Remove the build-level l = ... if it exists in this class
                # (since the getter replaces it)
                build_l_pattern = r'\n\s*final l = Provider\.of<LocaleNotifier>\(context\);'
                # Only remove within this class body
                class_end_updated = insert_pos + len(getter) + (class_end - insert_pos)
                class_body_updated = content[insert_pos + len(getter):class_end_updated]
                class_body_fixed = re.sub(build_l_pattern, '', class_body_updated, count=0)
                content = content[:insert_pos + len(getter)] + class_body_fixed + content[class_end_updated:]
    
    return content

def fix_stateless_widgets(content):
    """For StatelessWidget build methods, ensure l is defined at build scope."""
    # Check if it's a StatelessWidget
    if 'extends StatelessWidget' in content:
        # Make sure l is in the build method
        build_pattern = r'(Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{)'
        if re.search(build_pattern, content) and 'l.t(' in content:
            def add_l(match):
                return match.group(1) + "\n    final l = Provider.of<LocaleNotifier>(context);"
            
            # Only add if not already there
            if 'final l = Provider.of<LocaleNotifier>(context)' not in content:
                content = re.sub(build_pattern, add_l, content)
    return content

def fix_error_view(filepath):
    """Special handling for error_view.dart which uses static helper methods."""
    content = read_file(filepath)
    
    # error_view likely has factory methods or static methods that return widgets
    # The l.t() calls need context. If it's a StatelessWidget, the build method fix works.
    # If it uses static methods, we need to pass context or add l locally.
    
    # Let's check the structure
    if 'static' in content and 'l.t(' in content:
        # For static methods, we need to define l with context
        # Pattern: static Widget something(... BuildContext context, ...) {
        # or similar
        pass
    
    content = fix_state_classes(content)
    content = fix_stateless_widgets(content)
    write_file(filepath, content)

def fix_service_files(filepath):
    """Fix service files where l is used in methods with context param."""
    content = read_file(filepath)
    
    # For methods that receive BuildContext, add l at the start
    # Pattern: void methodName(BuildContext context, ...) {
    method_pattern = r'(\w+\s+\w+\s*\([^)]*BuildContext\s+\w+[^)]*\)\s*(?:async\s*)?\{)'
    
    def add_l_to_method(match):
        method_header = match.group(1)
        # Extract context param name
        ctx_match = re.search(r'BuildContext\s+(\w+)', method_header)
        if ctx_match:
            ctx_name = ctx_match.group(1)
            return method_header + f"\n    final l = Provider.of<LocaleNotifier>({ctx_name});"
        return method_header
    
    if 'l.t(' in content and 'extends State' not in content:
        content = re.sub(method_pattern, add_l_to_method, content)
    
    write_file(filepath, content)

def fix_remaining_const(filepath):
    """Remove const before any expression using l.t()."""
    content = read_file(filepath)
    original = content
    
    # Remove const before Text(l.t(...))
    content = re.sub(r'\bconst\s+(Text\s*\(\s*l\.t\()', r'\1', content)
    # Remove const before SnackBar with l.t
    content = re.sub(r'\bconst\s+(SnackBar\s*\([^)]*l\.t\()', r'\1', content)
    # Remove const that wraps widgets containing l.t 
    # More general: const SomeWidget(... l.t(...) ...) 
    # This is tricky, so let's be conservative
    
    if content != original:
        write_file(filepath, content)
        return True
    return False

def main():
    print("=== Fix Round 2 ===\n")
    
    # All problematic files
    files = [
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
        'lib/features/rides/presentation/screens/list_rides/ride_list_screen.dart',
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
        'lib/features/users/presentation/screens/public_user_profile_screen.dart',
        'lib/features/weather/presentation/screens/weather_screen.dart',
        'lib/shared/services/permission_service.dart',
        'lib/shared/widgets/error_view.dart',
        'lib/features/shop/presentation/screens/cart_screen.dart',
        'lib/features/ride_recommendations/presentation/screens/my_recommendations_screen.dart',
        'lib/features/accidents/presentation/screens/accident_report_screen.dart',
        'lib/features/accidents/presentation/screens/accidents_list_screen.dart',
        'lib/features/accidents/presentation/screens/accident_detail_screen.dart',
        'lib/features/settings/presentation/screens/permissions_screen.dart',
    ]
    
    for filepath in files:
        if not os.path.exists(filepath):
            continue
        
        content = read_file(filepath)
        original = content
        
        # For State classes: add getter
        if 'extends State<' in content and 'l.t(' in content:
            content = fix_state_classes(content)
        elif 'extends StatelessWidget' in content and 'l.t(' in content:
            content = fix_stateless_widgets(content)
        
        # For special non-widget files
        if 'extends State' not in content and 'extends StatelessWidget' not in content:
            if 'l.t(' in content:
                # Check if there are methods with BuildContext param
                pattern = r'((?:void|Future|Widget|static\s+\w+)\s+\w+\s*\([^)]*BuildContext\s+(\w+)[^)]*\)\s*(?:async\s*)?\{)'
                def add_l_method(match):
                    ctx_name = match.group(2)
                    return match.group(1) + f"\n    final l = Provider.of<LocaleNotifier>({ctx_name});"
                content = re.sub(pattern, add_l_method, content)
        
        # Fix remaining const issues everywhere
        content = re.sub(r'\bconst\s+(Text\s*\(\s*l\.t\()', r'\1', content)
        content = re.sub(r'\bconst\s+(Text\s*\(\s*\'\$\{l\.t)', r'\1', content)
        
        if content != original:
            write_file(filepath, content)
            print(f"  FIXED: {filepath}")
        else:
            print(f"  NO CHANGE: {filepath}")
    
    print("\nDone!")

if __name__ == '__main__':
    main()
