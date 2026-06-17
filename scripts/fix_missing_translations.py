#!/usr/bin/env python3
"""
Script para actualizar archivos de la app con traducciones dinámicas.
Reemplaza strings hardcodeados en español con llamadas a LocaleNotifier.t()
"""

import re
import os

# Mapeo de strings españoles a keys de traducción
TRANSLATION_MAP = {
    # Profile Screen
    "'Cancelar'": "'cancel_button_label'",
    "'Eliminar'": "'delete_button_label'",
    "'Cargando...'": "'loading_ellipsis'",
    "'Editar Perfil'": "'edit_profile_title'",
    "'Perfil actualizado correctamente'": "'profile_updated_success'",
    "'Guardar'": "'save_button_label'",
    "'Error cargando datos del perfil'": "'error_loading_profile'",
    "'Reintentar'": "'retry_button_label'",
    "'Agregar Historia'": "'add_story_fab'",
    "'Nueva Publicación'": "'new_post_fab'",
    "'Publicación eliminada'": "'post_deleted_message'",
    "'Error: Usuario inválido'": "'invalid_user_error'",
    "'¿Deseas eliminar esta publicación? Esta acción no se puede deshacer.'": "'delete_post_confirmation'",

    # Ride Tracker
    "'Historial actualizado'": "'history_updated_success'",
    "'Eliminar rodada'": "'delete_ride_dialog'",
    "'¿Salir?'": "'exit_ride_confirmation'",
    "'Rodada muy corta, no se guardó'": "'short_ride_message'",
    "'No se pudo trazar la ruta'": "'route_trace_error'",
    
    # Road Reports
    "'¿Estás seguro de que quieres eliminar este reporte?'": "'delete_report_confirmation'",
    
    # Report User
    "'Tambien bloquear a este usuario'": "'also_block_user'",
    
    # Other
    "'Renombrar destacado'": "'rename_highlight'",
    "'No tienes historias para destacar'": "'no_stories_highlight'",
    "'Error cargando historias'": "'error_loading_stories'",
    "'Error al repostear: '": "'repost_error'",
    "'Error al enviar audio: '": "'audio_send_error'",
    "'Denegar'": "'deny_button'",
    "'Error enviando reporte'": "'report_send_error'",
    "'Google Maps'": "'google_maps_button'",
    "'Probar Conexión'": "'testing_button'",
    "'Probando...'": "'testing_message'",
}

def process_file(filepath):
    """Procesa un archivo y reemplaza strings con traducciones"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        for spanish, key in TRANSLATION_MAP.items():
            if spanish in content:
                # Crear el reemplazo con l.t()
                replacement = f"l.t({key})"
                content = content.replace(spanish, replacement)
                print(f"  ✓ {spanish} → l.t({key})")
        
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False

def main():
    print("🔧 Actualizando archivos con traducciones dinámicas...\n")
    
    files_to_update = [
        "lib/features/users/presentation/screens/profile_screen.dart",
        "lib/features/ride_tracker/presentation/screens/ride_tracker_screen.dart",
        "lib/features/road_reports/presentation/screens/road_reports_screen.dart",
        "lib/features/social/presentation/screens/report_user_screen.dart",
        "lib/features/experiences/presentation/screens/experiences_list_screen.dart",
        "lib/features/chat/presentation/widgets/chat_input.dart",
        "lib/features/social/presentation/widgets/social_notifications_list.dart",
        "lib/features/social/presentation/widgets/social_report_content_dialog.dart",
        "lib/features/rides/presentation/screens/rides_detail_screen.dart",
        "lib/features/emergency/presentation/screens/emergency_screen.dart",
        "lib/features/achievements/presentation/screens/achievements_screen.dart",
        "lib/features/shop/presentation/screens/stolen_bikes_screen.dart",
        "lib/features/shop/presentation/screens/admin_alerts_screen.dart",
    ]
    
    updated_count = 0
    for file in files_to_update:
        filepath = os.path.join(".", file)
        if os.path.exists(filepath):
            print(f"📝 {file}")
            if process_file(filepath):
                updated_count += 1
        else:
            print(f"⚠️  {file} - NO ENCONTRADO")
    
    print(f"\n✅ {updated_count} archivo(s) actualizado(s)")

if __name__ == "__main__":
    main()
