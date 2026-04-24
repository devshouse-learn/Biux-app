"""
Batch replace hardcoded Spanish strings with l.t() calls across all screen files.
This script does precise text replacements in each file.
"""
import re
import os

BASE = 'lib'

def read_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def write_file(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def ensure_locale_import(content, filepath):
    """Add LocaleNotifier import if not present."""
    if 'locale_notifier.dart' in content:
        return content
    # Find last import line
    lines = content.split('\n')
    last_import = 0
    for i, line in enumerate(lines):
        if line.startswith('import '):
            last_import = i
    lines.insert(last_import + 1, "import 'package:biux/core/design_system/locale_notifier.dart';")
    return '\n'.join(lines)

def process_file(filepath, replacements):
    """Process a file making a list of replacements."""
    full = os.path.join(BASE, filepath) if not filepath.startswith('lib') else filepath
    if not os.path.exists(full):
        print(f"  SKIP (not found): {full}")
        return 0
    content = read_file(full)
    count = 0
    for old, new in replacements:
        if old in content:
            content = content.replace(old, new, 1)
            count += 1
        else:
            # Try with more flexible matching
            pass
    if count > 0:
        write_file(full, content)
    print(f"  {filepath}: {count} replacements")
    return count


def main():
    total = 0

    # ═══════════════════════════════════════════════════════════
    # APP DRAWER
    # ═══════════════════════════════════════════════════════════
    print("\n=== APP DRAWER ===")
    f = 'lib/shared/widgets/app_drawer.dart'
    content = read_file(f)
    
    # First, we need to add 'l' variable in the build method
    # The build method needs access to l = Provider.of<LocaleNotifier>(context)
    # The drawer uses _item() helper which takes strings, and _sec() for section titles
    # We need to pass l to these or get it in build context
    
    # Add l variable at start of build method
    content = content.replace(
        "  @override\n  Widget build(BuildContext context) {\n    return Drawer(",
        "  @override\n  Widget build(BuildContext context) {\n    final l = Provider.of<LocaleNotifier>(context);\n    return Drawer("
    )
    
    # Section titles
    content = content.replace("_sec('CICLISMO')", "_sec(l.t('cycling').toUpperCase())")
    content = content.replace("_sec('COMUNIDAD')", "_sec(l.t('community').toUpperCase())")
    content = content.replace("_sec('SEGURIDAD')", "_sec(l.t('safety_section').toUpperCase())")
    content = content.replace("_sec('APRENDIZAJE')", "_sec(l.t('learning').toUpperCase())")
    
    # Menu items
    content = content.replace(
        "'Grabar Rodada',\n                  'GPS tracking en tiempo real',",
        "l.t('record_ride'),\n                  l.t('gps_realtime_tracking'),"
    )
    content = content.replace(
        "'Mis Rodadas',\n                  'Historial de tus rides grabados',",
        "l.t('my_rides'),\n                  l.t('ride_history'),"
    )
    content = content.replace(
        "'Mis Estadisticas',\n                  'Km, velocidad, nivel y ranking',",
        "l.t('my_stats'),\n                  l.t('stats_subtitle'),"
    )
    content = content.replace(
        "'Logros',\n                  'Medallas y desafios desbloqueados',",
        "l.t('achievements_title'),\n                  l.t('achievements_subtitle'),"
    )
    content = content.replace(
        "'Negocios y Eventos',\n                  'Publicidad y eventos con registro',",
        "l.t('business_events'),\n                  l.t('business_events_subtitle'),"
    )
    content = content.replace(
        "'Emergencia SOS',\n                  'Boton de panico y contactos',",
        "l.t('emergency_sos'),\n                  l.t('panic_button_contacts'),"
    )
    content = content.replace(
        "'Reportes Viales',\n                  'Baches, obras y peligros en ruta',",
        "l.t('road_reports'),\n                  l.t('road_reports_subtitle'),"
    )
    content = content.replace(
        "'Reportar Accidente',\n                  'Reporta un incidente vial',",
        "l.t('report_accident'),\n                  l.t('report_incident'),"
    )
    content = content.replace(
        "'Bicicletas Robadas',\n                  'Base de datos publica',",
        "l.t('stolen_bikes'),\n                  l.t('public_database'),"
    )
    content = content.replace(
        "'Dashboard Alertas',\n                      'Intentos venta bicis robadas',",
        "l.t('alerts_dashboard'),\n                      l.t('alerts_dashboard_subtitle'),"
    )
    content = content.replace(
        "'Educacion Vial',\n                  'Seguridad, mecanica y consejos',",
        "l.t('road_education'),\n                  l.t('education_subtitle'),"
    )
    content = content.replace(
        "'Clima',\n                  'Condiciones para rodar hoy',",
        "l.t('weather_title'),\n                  l.t('weather_subtitle'),"
    )
    
    # SOS button text
    content = content.replace(
        "? 'Activando SOS...'\n                                        : 'Emergencia SOS'",
        "? l.t('activating_sos')\n                                        : l.t('emergency_sos')"
    )
    content = content.replace(
        "? 'Suelta para cancelar'\n                                        : 'Mantén presionado 3s'",
        "? l.t('release_to_cancel')\n                                        : l.t('hold_3s')"
    )
    
    # Footer logout
    content = content.replace(
        "                  title: Text(\n                    'Cerrar Sesion',",
        "                  title: Text(\n                    l.t('close_session_drawer'),"
    )
    
    # Logout dialog - need to pass l
    content = content.replace(
        "void _logoutDialog(BuildContext context) {\n    showDialog(",
        "void _logoutDialog(BuildContext context) {\n    final l = Provider.of<LocaleNotifier>(context, listen: false);\n    showDialog("
    )
    content = content.replace("const Text('Cerrar Sesion')", "Text(l.t('close_session_drawer'))")
    content = content.replace(
        "content: const Text('Estas seguro que deseas cerrar sesion?')",
        "content: Text(l.t('confirm_close_session'))"
    )
    content = content.replace("child: const Text('Cancelar')", "child: Text(l.t('cancel'))")
    
    write_file(f, content)
    print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # ERROR VIEW
    # ═══════════════════════════════════════════════════════════
    print("\n=== ERROR VIEW ===")
    f = 'lib/shared/widgets/error_view.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Sin conexión'", "l.t('no_connection')"),
            ("'Verifica tu conexión a internet e intenta nuevamente.'", "l.t('check_connection')"),
            ("'No encontrado'", "l.t('not_found')"),
            ("'El contenido que buscas no está disponible.'", "l.t('content_not_available')"),
            ("'Sin permisos'", "l.t('no_permissions')"),
            ("'No tienes permisos para acceder a este contenido.'", "l.t('no_permissions_msg')"),
            ("'Error del servidor'", "l.t('server_error')"),
            ("'Hubo un problema con el servidor. Intenta más tarde.'", "l.t('server_error_msg')"),
            ("'Sin contenido'", "l.t('no_content')"),
            ("'No hay nada que mostrar aquí por ahora.'", "l.t('nothing_to_show')"),
            ("'Algo salió mal'", "l.t('something_went_wrong')"),
            ("'Ocurrió un error inesperado. Intenta nuevamente.'", "l.t('unexpected_error')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # CHAT SCREEN
    # ═══════════════════════════════════════════════════════════
    print("\n=== CHAT SCREENS ===")
    f = 'lib/features/chat/presentation/screens/chat_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("label: 'Galería'", "label: l.t('gallery')"),
            ("label: 'Cámara'", "label: l.t('camera')"),
            ("label: 'Audio'", "label: l.t('audio')"),
            ("label: 'Ubicación'", "label: l.t('location_label')"),
            ("label: 'Encuesta'", "label: l.t('poll')"),
            ("const Text(\n                          'Ubicación precisa'", "Text(\n                          l.t('precise_location')"),
            ("const Text(\n                          'Se comparte tu ubicación exacta'", "Text(\n                          l.t('share_exact_location')"),
            ("const Text(\n                          'Ubicación aproximada'", "Text(\n                          l.t('approximate_location')"),
            ("const Text(\n                          'Se comparte un área general'", "Text(\n                          l.t('share_general_area')"),
            ("'Obteniendo ubicación...'", "l.t('getting_location')"),
            ("const Text('No se pudo obtener la ubicación')", "Text(l.t('could_not_get_location'))"),
            ("const Text('Usuario bloqueado')", "Text(l.t('user_blocked'))"),
            ("const Text('Usuario desbloqueado')", "Text(l.t('user_unblocked'))"),
            ("'Buscar mensajes...'", "l.t('search_messages')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # Chat input
    f = 'lib/features/chat/presentation/widgets/chat_input.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Escribe un mensaje...'", "l.t('write_message')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # Message bubble
    f = 'lib/features/chat/presentation/widgets/message_bubble.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Escribe el nuevo mensaje...'", "l.t('write_new_message')"),
            ("'Eliminar para mí'", "l.t('delete_for_me')"),
            ("'Eliminar para todos'", "l.t('delete_for_all')"),
            ("const Text('No se puede reproducir el audio')", "Text(l.t('cannot_play_audio'))"),
            ("const Text('Ubicación'", "Text(l.t('location_label')"),
            ("const Text('Eliminar mensaje'", "Text(l.t('delete_message')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # Poll creation
    f = 'lib/features/chat/presentation/widgets/poll_creation_sheet.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("const Text('Escribe una pregunta')", "Text(l.t('write_question'))"),
            ("const Text('Agrega al menos 2 opciones')", "Text(l.t('add_at_least_2_options'))"),
            ("'Crear encuesta'", "l.t('create_poll')"),
            ("'Escribe tu pregunta...'", "l.t('write_your_question')"),
            ("const Text('Agregar opción')", "Text(l.t('add_option'))"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # Chat list screen
    f = 'lib/features/chat/presentation/screens/chat_list_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Buscar conversación...'", "l.t('search_conversation')"),
            ("'Filtrar por nombre...'", "l.t('filter_by_name')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # Location picker
    f = 'lib/features/chat/presentation/screens/location_picker_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("const Text('Seleccionar ubicación')", "Text(l.t('select_location'))")
        write_file(f, content)
        print(f"  {f}: updated")

    # Chat settings
    f = 'lib/features/chat/presentation/screens/chat_settings_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Personalización'", "l.t('customization')"),
            ("'Copia de seguridad'", "l.t('backup')"),
            ("const Text('Función en desarrollo')", "Text(l.t('feature_in_development'))"),
            ("'Privacidad'", "l.t('privacy')"),
            ("'Vista previa del texto'", "l.t('text_preview')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # PROFILE SCREENS
    # ═══════════════════════════════════════════════════════════
    print("\n=== PROFILE SCREENS ===")
    f = 'lib/features/users/presentation/screens/profile_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Editar publicación'", "l.t('edit_post')"),
            ("'Eliminar publicación'", "l.t('delete_post')"),
            ("'Publicación eliminada'", "l.t('post_deleted')"),
            ("const Text('Sin seguidores aún')", "Text(l.t('no_followers_yet'))"),
            ("'Error: Usuario inválido'", "l.t('invalid_user_error')"),
            ("const Text('No sigue a nadie aún')", "Text(l.t('not_following_anyone'))"),
            ("'Editar Perfil'", "l.t('edit_profile')"),
            ("'Tu nombre completo'", "l.t('your_full_name')"),
            ("'tu_nombre_usuario'", "l.t('your_username')"),
            ("'Cuéntales sobre ti'", "l.t('tell_about_you')"),
            ("'Nueva Publicación'", "l.t('new_post')"),
            ("'Editar perfil'", "l.t('edit_profile')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/users/presentation/screens/user_profile_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Nueva Publicación'", "l.t('new_post')"),
            ("'Editar perfil'", "l.t('edit_profile')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/users/presentation/screens/public_user_profile_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("'Código QR'", "l.t('qr_code')")
        write_file(f, content)
        print(f"  {f}: updated")

    # Activity screens
    f = 'lib/features/users/presentation/screens/activity_hub_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("title: 'Likes'", "title: l.t('likes')"),
            ("title: 'Comentarios'", "title: l.t('comments_label')"),
            ("title: 'Publicaciones'", "title: l.t('posts')"),
            ("title: 'Historias'", "title: l.t('stories')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/users/presentation/screens/activity_stories_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("'Mis Historias'", "l.t('my_stories')")
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/users/presentation/screens/activity_posts_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("'Mis Publicaciones'", "l.t('my_posts')")
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/users/presentation/screens/activity_screen_time_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Hoy'", "l.t('today')"),
            ("'Prom. 7 días'", "l.t('avg_7_days')"),
            ("'Prom. 30 días'", "l.t('avg_30_days')"),
            ("'Total semana'", "l.t('total_week')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/users/presentation/screens/accessibility_settings_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Apariencia'", "l.t('appearance_label')"),
            ("'Claro'", "l.t('light')"),
            ("'Oscuro'", "l.t('dark')"),
            ("'Sistema'", "l.t('system')"),
            ("'Accesibilidad'", "l.t('accessibility')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # CYCLING STATS
    # ═══════════════════════════════════════════════════════════
    print("\n=== CYCLING STATS ===")
    f = 'lib/features/cycling_stats/presentation/screens/cycling_stats_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Estadísticas actualizadas'", "l.t('stats_updated')"),
            ("'Mis Estadísticas'", "l.t('my_stats')"),
            ("'Cargando clima...'", "l.t('loading_weather')"),
            ("'Clima actual para rodar'", "l.t('current_weather_cycling')"),
            ("'Distancia'", "l.t('distance')"),
            ("'Rodadas'", "l.t('rides_label')"),
            ("'Vel. Promedio'", "l.t('avg_speed')"),
            ("'Vel. Máxima'", "l.t('max_speed')"),
            ("'Elevación'", "l.t('elevation')"),
            ("'Calorías'", "l.t('calories')"),
            ("'Tiempo'", "l.t('time_label')"),
            ("'Racha'", "l.t('streak')"),
            ("'Sin rodadas aún'", "l.t('no_rides_yet')"),
            ("'Total Rodadas'", "l.t('total_rides')"),
            ("'Ranking regional próximamente'", "l.t('regional_ranking_soon')"),
            ("'Sin amigos en el ranking'", "l.t('no_friends_ranking')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # ACHIEVEMENTS
    # ═══════════════════════════════════════════════════════════
    print("\n=== ACHIEVEMENTS ===")
    f = 'lib/features/achievements/presentation/screens/achievements_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("const Text('Mis Logros'", "Text(l.t('my_achievements')"),
            ("'Sincronizar logros'", "l.t('sync_achievements')"),
            ("'Cómo funcionan los logros'", "l.t('how_achievements_work')"),
            ("'Buscar amigo...'", "l.t('search_friend')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # RIDE TRACKER
    # ═══════════════════════════════════════════════════════════
    print("\n=== RIDE TRACKER ===")
    f = 'lib/features/ride_tracker/presentation/screens/ride_tracker_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Distancia'", "l.t('distance')"),
            ("'Velocidad'", "l.t('speed_label')"),
            ("'Calorías'", "l.t('calories')"),
            ("'Mis Rodadas'", "l.t('my_rides')"),
            ("'Editar nombre'", "l.t('edit_name')"),
            ("'Ej: Ruta del domingo'", "l.t('ride_name_hint')"),
            ("'Eliminar rodada'", "l.t('delete_ride')"),
            ("'Rodada muy corta, no se guardó'", "l.t('ride_too_short')"),
            ("const Text('Guardar y Salir')", "Text(l.t('save_and_exit'))"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # Ride attendance
    f = 'lib/features/rides/presentation/widgets/ride_attendance_button.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("const Text('Sí, voy confirmado')", "Text(l.t('yes_confirmed'))"),
            ("const Text('Definitivamente asistiré')", "Text(l.t('definitely_attending'))"),
            ("'No estoy seguro/a todavía'", "l.t('not_sure_yet')"),
            ("const Text('Confirmar asistencia')", "Text(l.t('confirm_attendance'))"),
            ("const Text('Cancelar asistencia')", "Text(l.t('cancel_attendance'))"),
            ("const Text('Sí, cancelar')", "Text(l.t('yes_cancel'))"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # ROAD REPORTS
    # ═══════════════════════════════════════════════════════════
    print("\n=== ROAD REPORTS ===")
    f = 'lib/features/road_reports/presentation/screens/road_reports_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Activa el servicio de ubicación'", "l.t('enable_location_service')"),
            ("'Se necesitan permisos de ubicación'", "l.t('location_permissions_needed')"),
            ("'Permisos denegados. Ve a Configuración.'", "l.t('permissions_denied_settings')"),
            ("'Eliminar reporte'", "l.t('delete_report')"),
            ("const Text('Reportes de Vía')", "Text(l.t('road_reports_title'))"),
            ("'Ej: Hueco grande en el carril...'", "l.t('report_description_hint')"),
            ("'Escribe una descripción'", "l.t('write_description')"),
            ("'Debes iniciar sesión'", "l.t('must_login')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # EXPERIENCES / SOCIAL
    # ═══════════════════════════════════════════════════════════
    print("\n=== EXPERIENCES / SOCIAL ===")
    f = 'lib/features/experiences/presentation/screens/experiences_list_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("const Text('Repostear publicación')", "Text(l.t('repost_publication'))"),
            ("'Añade un comentario (opcional)'", "l.t('add_comment_optional')"),
            ("'¡Publicación reposteada!'", "l.t('post_reposted')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/experiences/presentation/screens/create_experience_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Editar Publicación'", "l.t('edit_publication')"),
            ("'Guardar y publicar cambios'", "l.t('save_publish_changes')"),
            ("'¡Publicación actualizada exitosamente!'", "l.t('post_updated_success')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/experiences/presentation/widgets/experience_story_viewer.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("const Text('Eliminar historia')", "Text(l.t('delete_story'))"),
            ("'Añade un mensaje (opcional)'", "l.t('add_message_optional')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/experiences/presentation/widgets/profile_highlights.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Editar nombre'", "l.t('edit_name')"),
            ("'Eliminar destacado'", "l.t('delete_highlight')"),
            ("'Nombre del destacado'", "l.t('highlight_name')"),
            ("'Crear Destacado'", "l.t('create_highlight')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/experiences/presentation/widgets/video_preview_dialog.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("'Vista previa del video'", "l.t('video_preview')")
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/social/presentation/screens/post_detail_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("const Text('Repostear publicación')", "Text(l.t('repost_publication'))"),
            ("const Text('Eliminar publicación')", "Text(l.t('delete_post'))"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/social/presentation/widgets/report_content_dialog.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("'Detalles adicionales (opcional)'", "l.t('additional_details_optional')")
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # EMERGENCY
    # ═══════════════════════════════════════════════════════════
    print("\n=== EMERGENCY ===")
    f = 'lib/features/emergency/presentation/screens/emergency_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Cancelar alerta'", "l.t('cancel_alert')"),
            ("'Alerta SOS enviada'", "l.t('sos_alert_sent')"),
            ("'Mis Contactos de Emergencia'", "l.t('my_emergency_contacts')"),
            ("'Ej: 3001234567'", "l.t('phone_example')"),
            ("'Nombre y teléfono son requeridos'", "l.t('name_phone_required')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # SAFETY
    # ═══════════════════════════════════════════════════════════
    print("\n=== SAFETY ===")
    f = 'lib/features/safety/presentation/screens/two_factor_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("const Text('Verificación en dos pasos')", "Text(l.t('two_step_verification'))"),
            ("const Text('Reenviar código')", "Text(l.t('resend_code'))"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/safety/presentation/screens/report_user_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("'Descripcion adicional (opcional)'", "l.t('additional_description_optional')")
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/safety/presentation/screens/active_sessions_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Cuenta creada'", "l.t('account_created')"),
            ("'Último acceso registrado'", "l.t('last_access')"),
            ("'Número verificado'", "l.t('verified_number')"),
            ("'Eliminar registro'", "l.t('delete_record')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/safety/presentation/screens/biometric_settings_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("'Autenticacion fallida'", "l.t('auth_failed')")
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # ACCIDENTS
    # ═══════════════════════════════════════════════════════════
    print("\n=== ACCIDENTS ===")
    f = 'lib/features/accidents/presentation/screens/accident_report_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("'Reportar Accidente'", "l.t('report_accident')")
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/accidents/presentation/screens/accidents_list_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("'Reportes de Accidentes'", "l.t('accident_reports')")
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/accidents/presentation/screens/accident_detail_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("'Detalle del Accidente'", "l.t('accident_detail')")
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # MAPS
    # ═══════════════════════════════════════════════════════════
    print("\n=== MAPS ===")
    f = 'lib/features/maps/presentation/screens/danger_zones_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Zonas de Peligro'", "l.t('danger_zones')"),
            ("'Accidente'", "l.t('accident_label')"),
            ("'Robo'", "l.t('robbery')"),
            ("'Otros'", "l.t('others')"),
            ("const Text('Confirmar zona peligrosa')", "Text(l.t('confirm_danger_zone'))"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # EDUCATION
    # ═══════════════════════════════════════════════════════════
    print("\n=== EDUCATION ===")
    f = 'lib/features/education/presentation/screens/education_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("const Text('Educación Vial')", "Text(l.t('road_education'))")
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # WEATHER
    # ═══════════════════════════════════════════════════════════
    print("\n=== WEATHER ===")
    f = 'lib/features/weather/presentation/screens/weather_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Clima'", "l.t('weather_title')"),
            ("'Visibilidad'", "l.t('visibility_label')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # GROUPS
    # ═══════════════════════════════════════════════════════════
    print("\n=== GROUPS ===")
    f = 'lib/features/groups/presentation/screens/my_groups/my_groups_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("'Eliminar grupo'", "l.t('delete_group')")
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/rides/presentation/screens/list_rides/ride_list_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("'Crear Grupo'", "l.t('create_group')")
        write_file(f, content)
        print(f"  {f}: updated")

    # ═══════════════════════════════════════════════════════════
    # SHOP / STORE
    # ═══════════════════════════════════════════════════════════
    print("\n=== SHOP ===")
    f = 'lib/features/shop/presentation/screens/stolen_bikes_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Buscar...'", "l.t('search_hint')"),
            ("'Buscar marca, modelo, color o serial...'", "l.t('search_brand_model')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/shop/presentation/screens/seller_dashboard_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("const Text('Mis Productos')", "Text(l.t('my_products'))"),
            ("const Text('Editar Producto')", "Text(l.t('edit_product'))"),
            ("const Text('Guardar Cambios')", "Text(l.t('save_changes'))"),
            ("const Text('Eliminar Producto')", "Text(l.t('delete_product'))"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/shop/presentation/screens/cart_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("const Text('Eliminar producto')", "Text(l.t('delete_product'))"),
            ("'Confirmar Compra'", "l.t('confirm_purchase')"),
            ("const Text('Envío:')", "Text(l.t('shipping_label'))"),
            ("'Confirmar y Pagar'", "l.t('confirm_and_pay')"),
            ("'Ingresa tu código'", "l.t('enter_your_code')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/shop/presentation/screens/bike_qr_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("const Text('Código QR de Verificación')", "Text(l.t('qr_verification_code'))")
        write_file(f, content)
        print(f"  {f}: updated")

    # Ride recommendations
    print("\n=== RIDE RECOMMENDATIONS ===")
    f = 'lib/features/ride_recommendations/presentation/widgets/send_recommendation_sheet.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("const Text('Selecciona un amigo')", "Text(l.t('select_a_friend'))"),
            ("const Text('Agrega un nombre a la ruta')", "Text(l.t('add_route_name'))"),
            ("'Recomendación enviada'", "l.t('recommendation_sent')"),
            ("const Text('Hubo un error')", "Text(l.t('there_was_error'))"),
            ("'Ej: Ruta al cerro, Ciclovia del rio...'", "l.t('route_name_hint')"),
            ("'Ej: Mirador, Parque, Cafetería...'", "l.t('point_of_interest_hint')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/ride_recommendations/presentation/screens/my_recommendations_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("'Mis Recomendaciones'", "l.t('my_recommendations')")
        write_file(f, content)
        print(f"  {f}: updated")

    # Age verification
    print("\n=== AGE VERIFICATION ===")
    f = 'lib/features/age_verification/presentation/screens/parental_consent_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'correo@ejemplo.com'", "l.t('email_example')"),
            ("'Cancelar y salir'", "l.t('cancel_and_exit')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    f = 'lib/features/age_verification/presentation/screens/identity_verification_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("const Text('Agrega la parte frontal del documento')", "Text(l.t('add_front_document'))"),
            ("'Toca para agregar la parte frontal'", "l.t('tap_add_front')"),
            ("'Toca para agregar la parte trasera'", "l.t('tap_add_back')"),
            ("'Verificación de Identidad'", "l.t('identity_verification')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # Permissions screen
    print("\n=== PERMISSIONS ===")
    f = 'lib/features/settings/presentation/screens/permissions_screen.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Notificaciones'", "l.t('notifications_label')"),
            ("'Contactos'", "l.t('contacts')"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    # Permission service
    f = 'lib/shared/services/permission_service.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        content = content.replace("const Text('Abrir configuración')", "Text(l.t('open_settings'))")
        write_file(f, content)
        print(f"  {f}: updated")

    # App update service
    f = 'lib/core/services/app_update_service.dart'
    if os.path.exists(f):
        content = read_file(f)
        content = ensure_locale_import(content)
        pairs = [
            ("'Actualización requerida'", "l.t('update_required')"),
            ("'Nueva versión disponible'", "l.t('new_version_available')"),
            ("const Text('Más tarde')", "Text(l.t('later'))"),
        ]
        for old, new in pairs:
            content = content.replace(old, new)
        write_file(f, content)
        print(f"  {f}: updated")

    print("\n✅ ALL DONE!")


def ensure_locale_import(content):
    if 'locale_notifier.dart' in content:
        return content
    lines = content.split('\n')
    last_import = 0
    for i, line in enumerate(lines):
        if line.startswith('import '):
            last_import = i
    lines.insert(last_import + 1, "import 'package:biux/core/design_system/locale_notifier.dart';")
    return '\n'.join(lines)


if __name__ == '__main__':
    main()
