#!/usr/bin/env python3
"""Add batch 4 translation keys to app_translations.dart."""

import re

TRANSLATIONS_FILE = 'lib/core/config/app_translations.dart'

NEW_KEYS = {
    'es': {
        'reposting': 'Reposteando...',
        'repost_action': 'Repostear',
        'reply_label': 'Respuesta',
        'time_years': 'año(s)',
        'time_months': 'mes(es)',
        'confirm_remove_like': '¿Quieres quitar tu like? Desaparecerá de esta lista.',
        'time_ago_lower': 'hace',
        'second': 'segundo',
        'seconds': 'segundos',
        'minute': 'minuto',
        'minutes': 'minutos',
        'hour': 'hora',
        'hours': 'horas',
        'day': 'día',
        'days': 'días',
        'enter_birthdate': 'Ingresa tu fecha de nacimiento',
    },
    'en': {
        'reposting': 'Reposting...',
        'repost_action': 'Repost',
        'reply_label': 'Reply',
        'time_years': 'year(s)',
        'time_months': 'month(s)',
        'confirm_remove_like': 'Do you want to remove your like? It will disappear from this list.',
        'time_ago_lower': 'ago',
        'second': 'second',
        'seconds': 'seconds',
        'minute': 'minute',
        'minutes': 'minutes',
        'hour': 'hour',
        'hours': 'hours',
        'day': 'day',
        'days': 'days',
        'enter_birthdate': 'Enter your date of birth',
    },
    'pt': {
        'reposting': 'Repostando...',
        'repost_action': 'Repostar',
        'reply_label': 'Resposta',
        'time_years': 'ano(s)',
        'time_months': 'mês(es)',
        'confirm_remove_like': 'Quer remover seu like? Ele desaparecerá desta lista.',
        'time_ago_lower': 'há',
        'second': 'segundo',
        'seconds': 'segundos',
        'minute': 'minuto',
        'minutes': 'minutos',
        'hour': 'hora',
        'hours': 'horas',
        'day': 'dia',
        'days': 'dias',
        'enter_birthdate': 'Insira sua data de nascimento',
    },
    'fr': {
        'reposting': 'Republication...',
        'repost_action': 'Republier',
        'reply_label': 'Réponse',
        'time_years': 'an(s)',
        'time_months': 'mois',
        'confirm_remove_like': 'Voulez-vous retirer votre like ? Il disparaîtra de cette liste.',
        'time_ago_lower': 'il y a',
        'second': 'seconde',
        'seconds': 'secondes',
        'minute': 'minute',
        'minutes': 'minutes',
        'hour': 'heure',
        'hours': 'heures',
        'day': 'jour',
        'days': 'jours',
        'enter_birthdate': 'Entrez votre date de naissance',
    },
    'it': {
        'reposting': 'Ripubblicando...',
        'repost_action': 'Ripubblica',
        'reply_label': 'Risposta',
        'time_years': 'anno/i',
        'time_months': 'mese/i',
        'confirm_remove_like': 'Vuoi rimuovere il tuo like? Scomparirà da questa lista.',
        'time_ago_lower': 'fa',
        'second': 'secondo',
        'seconds': 'secondi',
        'minute': 'minuto',
        'minutes': 'minuti',
        'hour': 'ora',
        'hours': 'ore',
        'day': 'giorno',
        'days': 'giorni',
        'enter_birthdate': 'Inserisci la tua data di nascita',
    },
}


def find_map_closing(lines, map_name):
    """Find the closing `};` of a specific map declaration."""
    in_map = False
    brace_count = 0
    for i, line in enumerate(lines):
        if f'Map<String, String> {map_name}' in line or f'final {map_name}' in line:
            in_map = True
        if in_map:
            brace_count += line.count('{') - line.count('}')
            if brace_count <= 0 and in_map:
                return i
    return -1


def main():
    with open(TRANSLATIONS_FILE, 'r', encoding='utf-8') as f:
        content = f.read()
    lines = content.split('\n')

    existing_keys = set()
    for line in lines:
        m = re.match(r"\s+'(\w+)'\s*:", line)
        if m:
            existing_keys.add(m.group(1))

    maps_order = ['_es', '_en', '_pt', '_fr', '_it']
    lang_order = ['es', 'en', 'pt', 'fr', 'it']

    closings = {}
    for map_name in maps_order:
        idx = find_map_closing(lines, map_name)
        if idx == -1:
            print(f"ERROR: Could not find closing for {map_name}")
            return
        closings[map_name] = idx
        print(f"Found {map_name} closing at line {idx + 1}")

    for map_name, lang in reversed(list(zip(maps_order, lang_order))):
        keys = NEW_KEYS.get(lang, {})
        if not keys:
            continue
        
        insert_lines = []
        for key, value in keys.items():
            if key in existing_keys:
                print(f"  SKIP (exists): '{key}' in {lang}")
                continue
            escaped_value = value.replace("'", "\\'")
            insert_lines.append(f"    '{key}': '{escaped_value}',")
        
        if insert_lines:
            closing_idx = closings[map_name]
            for j, insert_line in enumerate(insert_lines):
                lines.insert(closing_idx + j, insert_line)
            print(f"  Inserted {len(insert_lines)} keys into {map_name}")
            
            offset = len(insert_lines)
            for mn in maps_order:
                if closings[mn] > closings[map_name]:
                    closings[mn] += offset

    with open(TRANSLATIONS_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print("\nDone!")


if __name__ == '__main__':
    main()
