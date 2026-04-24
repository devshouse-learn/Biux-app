#!/usr/bin/env python3
"""Fix compilation errors after mega_translate.py"""
import re
import os
import glob

# =============================================================================
# FIX 1: Correct import path for locale_notifier
# =============================================================================
WRONG_IMPORT = "import 'package:biux/core/config/locale_notifier.dart';"
CORRECT_IMPORT = "import 'package:biux/core/design_system/locale_notifier.dart';"

all_files = glob.glob('lib/**/*.dart', recursive=True)
fix1_count = 0
for fpath in all_files:
    try:
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        continue
    if WRONG_IMPORT in content:
        content = content.replace(WRONG_IMPORT, CORRECT_IMPORT)
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(content)
        fix1_count += 1

print(f"✅ Fix 1: Corrected import path in {fix1_count} files")

# =============================================================================
# FIX 2: Add missing imports where LocaleNotifier is used but not imported
# =============================================================================
fix2_count = 0
for fpath in all_files:
    try:
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        continue
    
    if 'LocaleNotifier' in content and CORRECT_IMPORT not in content:
        # Add import
        lines = content.split('\n')
        import_lines = [i for i, line in enumerate(lines) if line.strip().startswith('import ')]
        if import_lines:
            last_import = import_lines[-1]
            lines.insert(last_import + 1, CORRECT_IMPORT)
            if "import 'package:provider/provider.dart';" not in content:
                lines.insert(last_import + 2, "import 'package:provider/provider.dart';")
            content = '\n'.join(lines)
            with open(fpath, 'w', encoding='utf-8') as f:
                f.write(content)
            fix2_count += 1

print(f"✅ Fix 2: Added missing imports in {fix2_count} files")

# =============================================================================
# FIX 3: Fix undefined 'l' - add getter to State classes or local var
# =============================================================================
fix3_count = 0
for fpath in all_files:
    try:
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        continue
    
    if 'l.t(' not in content:
        continue
    
    original = content
    
    # For State classes without the getter
    if 'extends State<' in content and 'LocaleNotifier get l' not in content:
        # Add getter after class declaration
        pattern = r'(class \w+ extends State<\w+>(?:\s+with\s+[\w,\s<>]+)?\s*\{)'
        match = re.search(pattern, content)
        if match:
            insert_pos = match.end()
            getter = '\n  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);\n'
            content = content[:insert_pos] + getter + content[insert_pos:]
            fix3_count += 1
    
    # For StatelessWidget without l definition
    if 'extends StatelessWidget' in content and 'final l =' not in content and 'LocaleNotifier get l' not in content:
        build_match = re.search(r'(Widget build\(BuildContext context\)\s*\{)', content)
        if build_match:
            insert_pos = build_match.end()
            l_def = '\n    final l = Provider.of<LocaleNotifier>(context);\n'
            content = content[:insert_pos] + l_def + content[insert_pos:]
            fix3_count += 1
    
    # For ChangeNotifier/Provider classes - l needs context passed in
    # These are trickier - l.t() should NOT be used in providers directly
    # For providers, we need to handle differently - skip for now
    
    if content != original:
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(content)

print(f"✅ Fix 3: Added 'l' definition in {fix3_count} files")

# =============================================================================
# FIX 4: Remove const from widgets containing l.t()
# =============================================================================
fix4_count = 0
for fpath in all_files:
    try:
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        continue
    
    if 'l.t(' not in content:
        continue
    
    original = content
    lines = content.split('\n')
    
    # Strategy: find all lines with l.t() and remove const from ancestor widgets
    lt_lines = [i for i, line in enumerate(lines) if 'l.t(' in line]
    
    for lt_line in lt_lines:
        # Look backwards up to 30 lines for const keywords
        for j in range(lt_line - 1, max(lt_line - 30, -1), -1):
            stripped = lines[j].strip()
            
            # Check for const on a widget
            if re.match(r'const\s+\w+\s*\(', stripped):
                lines[j] = lines[j].replace('const ', '', 1)
                fix4_count += 1
                break
            elif re.search(r':\s*const\s+\w+\s*\(', stripped):
                lines[j] = lines[j].replace('const ', '', 1)
                fix4_count += 1
                break
            elif stripped.startswith('const ') and '(' in stripped:
                lines[j] = lines[j].replace('const ', '', 1)
                fix4_count += 1
                break
            
            # Stop conditions
            if stripped.endswith(';') and j != lt_line:
                break
            if stripped.startswith('return ') and j != lt_line:
                break
            if stripped.startswith('class ') or stripped.startswith('void ') or stripped.startswith('Widget '):
                break
    
    new_content = '\n'.join(lines)
    if new_content != original:
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(new_content)

print(f"✅ Fix 4: Removed {fix4_count} const keywords")

# =============================================================================
# FIX 5: Revert l.t() in ChangeNotifier providers (no BuildContext)
# =============================================================================
# Map of key -> Spanish text for reverting
KEY_TO_SPANISH = {
    'cancel': 'Cancelar', 'save': 'Guardar', 'delete': 'Eliminar',
    'edit': 'Editar', 'confirm': 'Confirmar', 'accept': 'Aceptar',
    'close': 'Cerrar', 'loading': 'Cargando...', 'share': 'Compartir',
    'retry': 'Reintentar', 'update': 'Actualizar', 'block': 'Bloquear',
    'select': 'Seleccionar', 'publish': 'Publicar', 'discard': 'Descartar',
    'exit': 'Salir', 'continue_action': 'Continuar',
    'user_default': 'Usuario', 'cyclist_label': 'Ciclista',
    'name_label': 'Nombre', 'username_label': 'Nombre de usuario',
    'profile_photo': 'Foto de perfil', 'no_name': 'Sin nombre',
    'followers': 'Seguidores', 'following': 'Siguiendo', 'follow': 'Seguir',
    'report_action': 'Reportar', 'description': 'Descripción',
    'distance': 'Distancia', 'duration': 'Duración',
    'statistics': 'Estadísticas', 'publication': 'Publicación',
    'story_label': 'Historia', 'comments_label': 'Comentarios',
    'likes_label': 'Me gusta', 'user_blocked': 'Usuario bloqueado',
    'ride_cancelled': 'Rodada cancelada', 'ride_deleted': 'Rodada eliminada',
    'location_disabled': 'El servicio de ubicación está deshabilitado. Actívalo en configuración.',
    'location_permission_denied': 'Permisos de ubicación denegados',
    'location_permission_permanent': 'Permisos de ubicación denegados permanentemente. Ve a configuración para habilitarlos.',
    'history_updated': 'Historial actualizado',
    'request_accepted': 'Solicitud aceptada', 'request_denied': 'Solicitud denegada',
    'error_accepting_request': 'Error al aceptar la solicitud',
    'error_denying_request': 'Error al denegar la solicitud',
    'settings': 'Configuración',
    'permissions': 'Permisos',
    'error_sending': 'Error al enviar',
    'no_rides_yet': 'Sin rodadas aún',
}

fix5_count = 0
provider_files = glob.glob('lib/**/providers/*.dart', recursive=True)

for fpath in provider_files:
    try:
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        continue
    
    if 'l.t(' not in content:
        continue
    
    # Check if this is a ChangeNotifier without proper l getter
    has_context = 'BuildContext' in content or 'LocaleNotifier get l' in content
    is_provider = 'extends ChangeNotifier' in content or 'with ChangeNotifier' in content
    
    if is_provider and not has_context:
        # Revert all l.t() calls back to Spanish strings
        original = content
        for key, spanish in KEY_TO_SPANISH.items():
            content = content.replace(f"l.t('{key}')", f"'{spanish}'")
        
        # Remove LocaleNotifier getter if added
        content = content.replace('  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);\n', '')
        
        # Remove imports if no longer needed
        if 'LocaleNotifier' not in content and 'l.t(' not in content:
            content = content.replace("import 'package:biux/core/design_system/locale_notifier.dart';\n", '')
        
        if content != original:
            with open(fpath, 'w', encoding='utf-8') as f:
                f.write(content)
            fix5_count += 1
            print(f"  Reverted provider: {fpath}")
    
print(f"✅ Fix 5: Reverted l.t() in {fix5_count} provider files")

print("\n🎯 Run 'flutter analyze' to check remaining errors.")
