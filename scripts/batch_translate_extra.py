"""
Add extra translation keys that were missed in the first batch.
"""
import re
import os

TRANSLATIONS_FILE = 'lib/core/config/app_translations.dart'

EXTRA_KEYS = {
    'cycling': {'es': 'Ciclismo', 'en': 'Cycling', 'pt': 'Ciclismo', 'fr': 'Cyclisme', 'it': 'Ciclismo'},
    'community': {'es': 'Comunidad', 'en': 'Community', 'pt': 'Comunidade', 'fr': 'Communauté', 'it': 'Comunità'},
    'safety_section': {'es': 'Seguridad', 'en': 'Safety', 'pt': 'Segurança', 'fr': 'Sécurité', 'it': 'Sicurezza'},
    'learning': {'es': 'Aprendizaje', 'en': 'Learning', 'pt': 'Aprendizagem', 'fr': 'Apprentissage', 'it': 'Apprendimento'},
    'record_ride': {'es': 'Grabar Rodada', 'en': 'Record Ride', 'pt': 'Gravar Pedalada', 'fr': 'Enregistrer une sortie', 'it': 'Registra uscita'},
    'gps_realtime_tracking': {'es': 'GPS tracking en tiempo real', 'en': 'Real-time GPS tracking', 'pt': 'Rastreamento GPS em tempo real', 'fr': 'Suivi GPS en temps réel', 'it': 'Tracciamento GPS in tempo reale'},
    'ride_history': {'es': 'Historial de tus rides grabados', 'en': 'History of your recorded rides', 'pt': 'Histórico das suas pedaladas gravadas', 'fr': 'Historique de vos sorties enregistrées', 'it': 'Storico delle tue uscite registrate'},
    'stats_subtitle': {'es': 'Km, velocidad, nivel y ranking', 'en': 'Km, speed, level and ranking', 'pt': 'Km, velocidade, nível e ranking', 'fr': 'Km, vitesse, niveau et classement', 'it': 'Km, velocità, livello e classifica'},
    'achievements_subtitle': {'es': 'Medallas y desafíos desbloqueados', 'en': 'Medals and challenges unlocked', 'pt': 'Medalhas e desafios desbloqueados', 'fr': 'Médailles et défis débloqués', 'it': 'Medaglie e sfide sbloccate'},
    'panic_button_contacts': {'es': 'Botón de pánico y contactos', 'en': 'Panic button and contacts', 'pt': 'Botão de pânico e contatos', 'fr': 'Bouton de panique et contacts', 'it': 'Pulsante di panico e contatti'},
    'road_reports_subtitle': {'es': 'Baches, obras y peligros en ruta', 'en': 'Potholes, construction and road hazards', 'pt': 'Buracos, obras e perigos na rota', 'fr': 'Nids de poule, travaux et dangers sur la route', 'it': 'Buche, lavori e pericoli sul percorso'},
    'report_incident': {'es': 'Reporta un incidente vial', 'en': 'Report a road incident', 'pt': 'Reporte um incidente viário', 'fr': 'Signalez un incident routier', 'it': 'Segnala un incidente stradale'},
    'education_subtitle': {'es': 'Seguridad, mecánica y consejos', 'en': 'Safety, mechanics and tips', 'pt': 'Segurança, mecânica e dicas', 'fr': 'Sécurité, mécanique et conseils', 'it': 'Sicurezza, meccanica e consigli'},
    'weather_subtitle': {'es': 'Condiciones para rodar hoy', 'en': 'Riding conditions today', 'pt': 'Condições para pedalar hoje', 'fr': 'Conditions pour rouler aujourd\'hui', 'it': 'Condizioni per pedalare oggi'},
    'hold_3s': {'es': 'Mantén presionado 3s', 'en': 'Hold for 3s', 'pt': 'Mantenha pressionado 3s', 'fr': 'Maintenez 3s', 'it': 'Tieni premuto 3s'},
}

def main():
    with open(TRANSLATIONS_FILE, 'r', encoding='utf-8') as f:
        content = f.read()
    
    lines = content.split('\n')
    
    # Find existing keys per section
    sections = {}
    current_section = None
    section_end = {}
    existing_keys = {'es': set(), 'en': set(), 'pt': set(), 'fr': set(), 'it': set()}
    
    for i, line in enumerate(lines):
        if '_es = {' in line and 'static const' in line: current_section = 'es'
        elif '_en = {' in line and 'static const' in line: current_section = 'en'
        elif '_pt = {' in line and 'static const' in line: current_section = 'pt'
        elif '_fr = {' in line and 'static const' in line: current_section = 'fr'
        elif '_it = {' in line and 'static const' in line: current_section = 'it'
        
        if current_section:
            m = re.match(r"\s*'([^']+)'\s*:", line)
            if m:
                existing_keys[current_section].add(m.group(1))
            if line.strip() == '};' and current_section:
                section_end[current_section] = i
                current_section = None
    
    for lang in ['it', 'fr', 'pt', 'en', 'es']:
        if lang not in section_end:
            print(f"WARNING: Could not find end of section '{lang}'")
            continue
        
        missing = []
        for key, translations in EXTRA_KEYS.items():
            if key not in existing_keys[lang]:
                value = translations[lang].replace("'", "\\'")
                missing.append(f"    '{key}': '{value}',")
        
        if missing:
            insert_line = section_end[lang]
            new_lines = ['\n    // ── Drawer & navigation extras ──'] + missing
            for j, new_line in enumerate(new_lines):
                lines.insert(insert_line + j, new_line)
            
            offset = len(new_lines)
            for other_lang in ['it', 'fr', 'pt', 'en', 'es']:
                if other_lang != lang and other_lang in section_end and section_end[other_lang] > insert_line:
                    section_end[other_lang] += offset
            
            print(f"[{lang}] Added {len(missing)} extra keys")
        else:
            print(f"[{lang}] All extra keys already present")
    
    with open(TRANSLATIONS_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print("\nDone!")

if __name__ == '__main__':
    main()
