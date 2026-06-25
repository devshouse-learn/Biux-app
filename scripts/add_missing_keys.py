#!/usr/bin/env python3
"""Add missing translation keys to app_translations.dart."""

import re

TRANSLATIONS_FILE = 'lib/core/config/app_translations.dart'

# New keys to add, organized by language
NEW_KEYS = {
    'es': {
        'received_tab': 'Recibidas',
        'sent_tab': 'Enviadas',
        'reply_action': 'Responder',
        'react_action': 'Reaccionar',
        'copy_text': 'Copiar texto',
        'forward_action': 'Reenviar',
        'unpin_action': 'Desfijar',
        'unstar_action': 'Quitar destacado',
        'star_action': 'Destacar',
        'vote_singular': 'voto',
        'votes_plural': 'votos',
        'start_route': 'Iniciar ruta',
        'delete_message_for_you_confirm': '¿Eliminar este mensaje solo para ti?',
        'delete_message_for_all_confirm': '¿Eliminar este mensaje para todos los participantes?',
        'where_are_you_going': 'Hacia dónde vas...',
        'serial_example_hint': 'Ej: WTU123H456789',
        'report_stolen_bike_info': 'Reporta tu bicicleta robada para alertar a la comunidad y evitar su reventa.',
        'contact_authorities_if_found': 'Contacta a las autoridades si la encuentras',
        'brand_required': 'Marca *',
        'brand_example': 'Ej: Specialized',
        'model_required': 'Modelo *',
        'model_example': 'Ej: Allez Sprint',
        'color_required': 'Color *',
        'color_example': 'Ej: Negro/Rojo',
        'type_required': 'Tipo *',
        'bike_type_title': 'Tipo de Bicicleta',
        'serial_number_required': 'Número de Serie *',
        'frame_number': 'Número del cuadro',
        'city_required': 'Ciudad *',
        'theft_details_section': 'Detalles del Robo',
        'theft_date_required': 'Fecha del robo *',
        'theft_location_required': 'Lugar del robo *',
        'how_theft_happened': 'Cómo sucedió el robo...',
        'submit_confirms_truthful': 'Al enviar confirmas que la información es verídica',
        'report_registered_community_alerted': 'Tu reporte ha sido registrado. La comunidad será alertada.',
        'stolen_badge': 'ROBADA',
        'police_report_label': 'Denuncia',
        'order': 'Orden',
        'edit_message_title': 'Editar mensaje',
    },
    'en': {
        'received_tab': 'Received',
        'sent_tab': 'Sent',
        'reply_action': 'Reply',
        'react_action': 'React',
        'copy_text': 'Copy text',
        'forward_action': 'Forward',
        'unpin_action': 'Unpin',
        'unstar_action': 'Remove highlight',
        'star_action': 'Highlight',
        'vote_singular': 'vote',
        'votes_plural': 'votes',
        'start_route': 'Start route',
        'delete_message_for_you_confirm': 'Delete this message only for you?',
        'delete_message_for_all_confirm': 'Delete this message for all participants?',
        'where_are_you_going': 'Where are you going...',
        'serial_example_hint': 'E.g.: WTU123H456789',
        'report_stolen_bike_info': 'Report your stolen bike to alert the community and prevent resale.',
        'contact_authorities_if_found': 'Contact the authorities if you find it',
        'brand_required': 'Brand *',
        'brand_example': 'E.g.: Specialized',
        'model_required': 'Model *',
        'model_example': 'E.g.: Allez Sprint',
        'color_required': 'Color *',
        'color_example': 'E.g.: Black/Red',
        'type_required': 'Type *',
        'bike_type_title': 'Bike Type',
        'serial_number_required': 'Serial Number *',
        'frame_number': 'Frame number',
        'city_required': 'City *',
        'theft_details_section': 'Theft Details',
        'theft_date_required': 'Theft date *',
        'theft_location_required': 'Theft location *',
        'how_theft_happened': 'How the theft happened...',
        'submit_confirms_truthful': 'By submitting you confirm that the information is truthful',
        'report_registered_community_alerted': 'Your report has been registered. The community will be alerted.',
        'stolen_badge': 'STOLEN',
        'police_report_label': 'Report',
        'order': 'Order',
        'edit_message_title': 'Edit message',
    },
    'pt': {
        'received_tab': 'Recebidas',
        'sent_tab': 'Enviadas',
        'reply_action': 'Responder',
        'react_action': 'Reagir',
        'copy_text': 'Copiar texto',
        'forward_action': 'Encaminhar',
        'unpin_action': 'Desafixar',
        'unstar_action': 'Remover destaque',
        'star_action': 'Destacar',
        'vote_singular': 'voto',
        'votes_plural': 'votos',
        'start_route': 'Iniciar rota',
        'delete_message_for_you_confirm': 'Excluir esta mensagem apenas para você?',
        'delete_message_for_all_confirm': 'Excluir esta mensagem para todos os participantes?',
        'where_are_you_going': 'Para onde você vai...',
        'serial_example_hint': 'Ex: WTU123H456789',
        'report_stolen_bike_info': 'Reporte sua bicicleta roubada para alertar a comunidade e evitar revenda.',
        'contact_authorities_if_found': 'Contacte as autoridades se encontrá-la',
        'brand_required': 'Marca *',
        'brand_example': 'Ex: Specialized',
        'model_required': 'Modelo *',
        'model_example': 'Ex: Allez Sprint',
        'color_required': 'Cor *',
        'color_example': 'Ex: Preto/Vermelho',
        'type_required': 'Tipo *',
        'bike_type_title': 'Tipo de Bicicleta',
        'serial_number_required': 'Número de Série *',
        'frame_number': 'Número do quadro',
        'city_required': 'Cidade *',
        'theft_details_section': 'Detalhes do Roubo',
        'theft_date_required': 'Data do roubo *',
        'theft_location_required': 'Local do roubo *',
        'how_theft_happened': 'Como aconteceu o roubo...',
        'submit_confirms_truthful': 'Ao enviar você confirma que as informações são verdadeiras',
        'report_registered_community_alerted': 'Seu relatório foi registrado. A comunidade será alertada.',
        'stolen_badge': 'ROUBADA',
        'police_report_label': 'Boletim',
        'order': 'Ordem',
        'edit_message_title': 'Editar mensagem',
    },
    'fr': {
        'received_tab': 'Reçues',
        'sent_tab': 'Envoyées',
        'reply_action': 'Répondre',
        'react_action': 'Réagir',
        'copy_text': 'Copier le texte',
        'forward_action': 'Transférer',
        'unpin_action': 'Désépingler',
        'unstar_action': 'Retirer des favoris',
        'star_action': 'Mettre en favori',
        'vote_singular': 'vote',
        'votes_plural': 'votes',
        'start_route': 'Démarrer l\'itinéraire',
        'delete_message_for_you_confirm': 'Supprimer ce message uniquement pour vous ?',
        'delete_message_for_all_confirm': 'Supprimer ce message pour tous les participants ?',
        'where_are_you_going': 'Où allez-vous...',
        'serial_example_hint': 'Ex : WTU123H456789',
        'report_stolen_bike_info': 'Signalez votre vélo volé pour alerter la communauté et empêcher sa revente.',
        'contact_authorities_if_found': 'Contactez les autorités si vous le trouvez',
        'brand_required': 'Marque *',
        'brand_example': 'Ex : Specialized',
        'model_required': 'Modèle *',
        'model_example': 'Ex : Allez Sprint',
        'color_required': 'Couleur *',
        'color_example': 'Ex : Noir/Rouge',
        'type_required': 'Type *',
        'bike_type_title': 'Type de Vélo',
        'serial_number_required': 'Numéro de Série *',
        'frame_number': 'Numéro de cadre',
        'city_required': 'Ville *',
        'theft_details_section': 'Détails du Vol',
        'theft_date_required': 'Date du vol *',
        'theft_location_required': 'Lieu du vol *',
        'how_theft_happened': 'Comment le vol s\'est passé...',
        'submit_confirms_truthful': 'En soumettant, vous confirmez que les informations sont véridiques',
        'report_registered_community_alerted': 'Votre signalement a été enregistré. La communauté sera alertée.',
        'stolen_badge': 'VOLÉ',
        'police_report_label': 'Plainte',
        'order': 'Ordre',
        'edit_message_title': 'Modifier le message',
    },
    'it': {
        'received_tab': 'Ricevute',
        'sent_tab': 'Inviate',
        'reply_action': 'Rispondi',
        'react_action': 'Reagisci',
        'copy_text': 'Copia testo',
        'forward_action': 'Inoltra',
        'unpin_action': 'Rimuovi pin',
        'unstar_action': 'Rimuovi evidenziazione',
        'star_action': 'Evidenzia',
        'vote_singular': 'voto',
        'votes_plural': 'voti',
        'start_route': 'Inizia percorso',
        'delete_message_for_you_confirm': 'Eliminare questo messaggio solo per te?',
        'delete_message_for_all_confirm': 'Eliminare questo messaggio per tutti i partecipanti?',
        'where_are_you_going': 'Dove stai andando...',
        'serial_example_hint': 'Es: WTU123H456789',
        'report_stolen_bike_info': 'Segnala la tua bicicletta rubata per avvisare la comunità e prevenirne la rivendita.',
        'contact_authorities_if_found': 'Contatta le autorità se la trovi',
        'brand_required': 'Marca *',
        'brand_example': 'Es: Specialized',
        'model_required': 'Modello *',
        'model_example': 'Es: Allez Sprint',
        'color_required': 'Colore *',
        'color_example': 'Es: Nero/Rosso',
        'type_required': 'Tipo *',
        'bike_type_title': 'Tipo di Bicicletta',
        'serial_number_required': 'Numero di Serie *',
        'frame_number': 'Numero del telaio',
        'city_required': 'Città *',
        'theft_details_section': 'Dettagli del Furto',
        'theft_date_required': 'Data del furto *',
        'theft_location_required': 'Luogo del furto *',
        'how_theft_happened': 'Come è avvenuto il furto...',
        'submit_confirms_truthful': 'Inviando confermi che le informazioni sono veritiere',
        'report_registered_community_alerted': 'La tua segnalazione è stata registrata. La comunità sarà avvisata.',
        'stolen_badge': 'RUBATA',
        'police_report_label': 'Denuncia',
        'order': 'Ordine',
        'edit_message_title': 'Modifica messaggio',
    },
}

# Language section markers (approximate line patterns to find the end of each section)
LANG_ORDER = ['es', 'en', 'pt', 'fr', 'it']
# We'll find the last key before the closing }; of each map and insert before it

def find_insertion_points(content):
    """Find the line number of the closing }; for each language map."""
    lines = content.split('\n')
    # The maps close with '  };' at specific lines
    # We look for lines that are exactly '  };'
    insertion_points = []
    skip_first = True  # Skip the first one which is the _translations map
    for i, line in enumerate(lines):
        if line.strip() == '};' and line.startswith('  '):
            if skip_first:
                skip_first = False
                continue
            insertion_points.append(i)
    
    return insertion_points

def main():
    with open(TRANSLATIONS_FILE, 'r', encoding='utf-8') as f:
        content = f.read()
    
    lines = content.split('\n')
    insertion_points = find_insertion_points(content)
    
    if len(insertion_points) != 5:
        print(f"ERROR: Found {len(insertion_points)} map ends, expected 5")
        return
    
    # Check which keys already exist in each section
    added_count = 0
    offset = 0
    
    for lang_idx, lang in enumerate(LANG_ORDER):
        insert_line = insertion_points[lang_idx] + offset
        keys_to_add = NEW_KEYS[lang]
        
        # Check which keys already exist in the section
        if lang_idx < len(insertion_points) - 1:
            section_end = insertion_points[lang_idx + 1] + offset
        else:
            section_end = len(lines)
        
        section_start = insertion_points[lang_idx] + offset - 500  # Look back 500 lines
        if section_start < 0:
            section_start = 0
        
        section_text = '\n'.join(lines[section_start:section_end])
        
        new_lines = []
        for key, value in keys_to_add.items():
            # Check if key already exists in this section
            if f"'{key}':" in section_text:
                continue
            # Escape single quotes in values
            escaped_value = value.replace("'", "\\'")
            new_lines.append(f"    '{key}': '{escaped_value}',")
            added_count += 1
        
        if new_lines:
            # Add a comment header
            new_lines.insert(0, '')
            new_lines.insert(1, '    // === Additional UI translations (auto-generated) ===')
            
            # Insert before the closing line
            for i, new_line in enumerate(new_lines):
                lines.insert(insert_line + i, new_line)
            
            offset += len(new_lines)
    
    with open(TRANSLATIONS_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print(f"Added {added_count} new translation keys across 5 languages")

if __name__ == '__main__':
    main()
