# -*- coding: utf-8 -*-
"""Migrate hardcoded Spanish strings to translation calls."""
import os

base = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
L = "Provider.of<LocaleNotifier>(context, listen: false)"

# Each entry: (spanish_text_to_find, translation_key)
# The script finds 'spanish_text' and replaces with Provider.of...t('key')
files_replacements = {
    r'lib\features\chat\presentation\screens\chat_screen.dart': [
        ("'Cargando...'", f"{L}.t('loading')"),
    ],
    r'lib\features\chat\presentation\widgets\chat_input.dart': [
        ("'Error al enviar audio: $e'", f"'${{{L}.t(\"error_sending_audio\")}}: $e'"),
    ],
    r'lib\features\experiences\presentation\screens\create_experience_screen.dart': [
        ("Text('Error: $e')", f"Text('${{{L}.t(\"error_generic\")}}: $e')"),
    ],
    r'lib\features\experiences\presentation\screens\experiences_list_screen.dart': [
        ("Text('Error al repostear: $e')", f"Text('${{{L}.t(\"error_reposting\")}}: $e')"),
    ],
    r'lib\features\experiences\presentation\widgets\experience_story_viewer.dart': [
        ("Text('Error al repostear: $e')", f"Text('${{{L}.t(\"error_reposting\")}}: $e')"),
    ],
    r'lib\features\social\presentation\widgets\notifications_list.dart': [
        ("'Denegar'", f"{L}.t('deny')"),
    ],
    r'lib\features\social\presentation\widgets\report_content_dialog.dart': [
        ("'Error enviando reporte'", f"{L}.t('error_sending_report')"),
    ],
    r'lib\features\shop\presentation\screens\stolen_bikes_screen.dart': [
        ("'Completa todos los campos obligatorios'", f"{L}.t('fill_required_fields')"),
        ("'Selecciona la fecha del robo'", f"{L}.t('select_theft_date')"),
    ],
    r'lib\features\emergency\presentation\screens\emergency_screen.dart': [
        ("'${nameC.text.trim()} agregado'", f"'${{nameC.text.trim()}} ${{{L}.t(\"contact_added\")}}'"),
    ],
    r'lib\features\shop\presentation\screens\admin_alerts_screen.dart': [
        ("'No hay alertas en este momento'", f"{L}.t('no_alerts_now')"),
        ("'Actualizar alertas'", f"{L}.t('refresh_alerts')"),
    ],
    r'lib\features\road_reports\presentation\screens\road_reports_screen.dart': [
        # Will handle via specific search since accent might differ
    ],
    r'lib\features\achievements\presentation\screens\achievements_screen.dart': [
        # Emojis + text
    ],
    r'lib\features\age_verification\presentation\screens\identity_verification_screen.dart': [
        ("'Agrega la parte frontal del documento'", f"{L}.t('add_front_document')"),
    ],
    r'lib\features\authentication\presentation\screens\create_user\create_user_screen.dart': [
        ("'Acceso restringido'", f"{L}.t('restricted_access')"),
    ],
    r'lib\features\experiences\presentation\widgets\profile_highlights.dart': [
        ("'Renombrar destacado'", f"{L}.t('rename_highlight')"),
        ("'No tienes historias para destacar'", f"{L}.t('no_stories_to_highlight')"),
        ("'Error cargando historias'", f"{L}.t('error_loading_stories')"),
    ],
    r'lib\features\safety\presentation\screens\report_user_screen.dart': [
        ("'Tambien bloquear a este usuario'", f"{L}.t('also_block_user')"),
    ],
}

count = 0
errors = []

for rel_path, pairs in files_replacements.items():
    path = os.path.join(base, rel_path)
    if not os.path.exists(path):
        errors.append(f"NOT FOUND: {rel_path}")
        continue
    if not pairs:
        continue

    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    orig = content
    for old, new in pairs:
        if old in content:
            content = content.replace(old, new, 1)
            count += 1
        else:
            errors.append(f"NOT MATCHED [{os.path.basename(path)}]: {old[:60]}")

    if content != orig:
        # Remove 'const' before SnackBar/Text that now has runtime calls
        import re
        # Fix: const SnackBar(...Provider.of...) -> SnackBar(...)
        content = re.sub(r'const (SnackBar\([^)]*Provider\.of)', r'\1', content)
        content = re.sub(r"const (Text\([^)]*Provider\.of)", r'\1', content)
        
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)

print(f"Replaced: {count}")
if errors:
    print(f"\nErrors ({len(errors)}):")
    for e in errors:
        print(f"  {e}")
