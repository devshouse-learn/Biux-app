"""
Script to migrate hardcoded Spanish strings to l.t() translation calls.
Only replaces strings that are actual UI text (not emojis, not data, not already translated).
"""
import re
import os

base = r'C:\Users\Usuario\Biux-app\Biux-app'

# Define replacements per file: (file_path, list of (old, new) pairs)
# We use Provider.of<LocaleNotifier>(context, listen: false).t('key') for files
# that don't have a local `l` variable in scope.

replacements = {
    # === CHAT ===
    'lib/features/chat/presentation/screens/chat_screen.dart': [
        ("Text('Cargando...', style: TextStyle(fontSize: 14))", 
         "Text(Provider.of<LocaleNotifier>(context, listen: false).t('loading'), style: const TextStyle(fontSize: 14))"),
    ],
    'lib/features/chat/presentation/widgets/chat_input.dart': [
        ("'Error al enviar audio: $e'", 
         "'${Provider.of<LocaleNotifier>(context, listen: false).t('error_sending_audio')}: $e'"),
    ],
    # === EXPERIENCES ===
    'lib/features/experiences/presentation/screens/create_experience_screen.dart': [
        ("SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)",
         "SnackBar(content: Text('${Provider.of<LocaleNotifier>(context, listen: false).t('error_generic')}: $e'), backgroundColor: Colors.red)"),
    ],
    'lib/features/experiences/presentation/screens/experiences_list_screen.dart': [
        ("content: Text('Error al repostear: $e')",
         "content: Text('${Provider.of<LocaleNotifier>(context, listen: false).t('error_reposting')}: $e')"),
    ],
    'lib/features/experiences/presentation/screens/experience_story_viewer.dart': [
        ("content: Text('Error al repostear: $e')",
         "content: Text('${Provider.of<LocaleNotifier>(context, listen: false).t('error_reposting')}: $e')"),
    ],
    # === SOCIAL ===
    'lib/features/social/presentation/widgets/notifications_list.dart': [
        ("child: Text('Denegar', style: TextStyle(fontSize: 13))",
         "child: Text(Provider.of<LocaleNotifier>(context, listen: false).t('deny'), style: const TextStyle(fontSize: 13))"),
    ],
    'lib/features/social/presentation/widgets/report_content_dialog.dart': [
        ("content: Text('Error enviando reporte')",
         "content: Text(Provider.of<LocaleNotifier>(context, listen: false).t('error_sending_report'))"),
    ],
    # === SHOP ===
    'lib/features/shop/presentation/screens/stolen_bikes_screen.dart': [
        ("content: Text('Completa todos los campos obligatorios')",
         "content: Text(Provider.of<LocaleNotifier>(context, listen: false).t('fill_required_fields'))"),
        ("content: Text('Selecciona la fecha del robo')",
         "content: Text(Provider.of<LocaleNotifier>(context, listen: false).t('select_theft_date'))"),
    ],
    # === SAFETY ===
    'lib/features/safety/presentation/screens/emergency_screen.dart': [
        ("content: Text('${nameC.text.trim()} agregado')",
         "content: Text('${nameC.text.trim()} ${Provider.of<LocaleNotifier>(context, listen: false).t('contact_added')}')"),
    ],
    'lib/features/safety/presentation/screens/admin_alerts_screen.dart': [
        ("content: Text('No hay alertas en este momento')",
         "content: Text(Provider.of<LocaleNotifier>(context, listen: false).t('no_alerts_now'))"),
        ("label: const Text('Actualizar alertas')",
         "label: Text(Provider.of<LocaleNotifier>(context, listen: false).t('refresh_alerts'))"),
    ],
    # === ROAD REPORTS ===
    'lib/features/road_reports/presentation/screens/road_reports_screen.dart': [
        ("content: Text('Error ubicación: $e')",
         "content: Text('${Provider.of<LocaleNotifier>(context, listen: false).t('error_location')}: $e')"),
    ],
    # === ACHIEVEMENTS ===
    'lib/features/achievements/presentation/screens/achievements_screen.dart': [
        ("Text('👥 Social - Únete a grupos', style: TextStyle(fontSize: 13))",
         "Text('👥 ${Provider.of<LocaleNotifier>(context, listen: false).t('social_join_groups')}', style: const TextStyle(fontSize: 13))"),
        ("Text('⭐ Especiales - Retos únicos', style: TextStyle(fontSize: 13))",
         "Text('⭐ ${Provider.of<LocaleNotifier>(context, listen: false).t('special_unique_challenges')}', style: const TextStyle(fontSize: 13))"),
    ],
    # === AGE VERIFICATION ===
    'lib/features/age_verification/presentation/screens/identity_verification_screen.dart': [
        ("const SnackBar(content: Text('Agrega la parte frontal del documento'))",
         "SnackBar(content: Text(Provider.of<LocaleNotifier>(context, listen: false).t('add_front_document')))"),
        ("SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)",
         "SnackBar(content: Text('${Provider.of<LocaleNotifier>(context, listen: false).t('error_generic')}: $e'), backgroundColor: Colors.red)"),
    ],
    'lib/features/age_verification/presentation/screens/parental_consent_screen.dart': [
        ("SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)",
         "SnackBar(content: Text('${Provider.of<LocaleNotifier>(context, listen: false).t('error_generic')}: $e'), backgroundColor: Colors.red)"),
    ],
    # === AUTH ===
    'lib/features/authentication/presentation/screens/create_user/create_user_screen.dart': [
        ("Text('Acceso restringido')",
         "Text(Provider.of<LocaleNotifier>(context, listen: false).t('restricted_access'))"),
    ],
    # === USERS ===
    'lib/features/users/presentation/screens/profile_screen.dart': [
        ("content: Text('Error: Usuario inválido')",
         "content: Text(l.t('error_invalid_user'))"),
    ],
    'lib/features/users/presentation/widgets/profile_highlights.dart': [
        ("title: Text('Renombrar destacado')",
         "title: Text(Provider.of<LocaleNotifier>(context, listen: false).t('rename_highlight'))"),
        ("content: Text('No tienes historias para destacar')",
         "content: Text(Provider.of<LocaleNotifier>(context, listen: false).t('no_stories_to_highlight'))"),
        ("content: Text('Error cargando historias')",
         "content: Text(Provider.of<LocaleNotifier>(context, listen: false).t('error_loading_stories'))"),
    ],
    'lib/features/users/presentation/screens/report_user_screen.dart': [
        ("title: const Text('Tambien bloquear a este usuario')",
         "title: Text(Provider.of<LocaleNotifier>(context, listen: false).t('also_block_user'))"),
    ],
    # === SETTINGS ===
    'lib/features/settings/presentation/screens/biometric_settings_screen.dart': [
        # This one is tricky - it uses $_biometricLabel variable
        # We'll replace just the 'Activar' part
    ],
    # === RIDES ===
    'lib/features/rides/presentation/widgets/ride_attendance_button.dart': [
        ("child: const Text('No')", 
         "child: const Text('No')"),  # 'No' is the same in EN/ES - skip
    ],
}

# Also need to handle the road_reports confirm_delete_report dialog
# which spans multiple lines - handle separately

count = 0
errors = []

for rel_path, pairs in replacements.items():
    full_path = os.path.join(base, rel_path.replace('/', '\\'))
    if not os.path.exists(full_path):
        errors.append(f"NOT FOUND: {rel_path}")
        continue
    
    with open(full_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    for old, new in pairs:
        if old == new:  # skip no-ops
            continue
        if old in content:
            content = content.replace(old, new, 1)  # only first occurrence
            count += 1
        else:
            errors.append(f"NOT MATCHED in {rel_path}: {old[:60]}")
    
    if content != original:
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(content)

print(f"Replacements made: {count}")
if errors:
    print(f"\nErrors ({len(errors)}):")
    for e in errors:
        print(f"  {e}")
