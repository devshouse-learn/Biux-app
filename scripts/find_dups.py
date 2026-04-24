import re

with open('lib/core/config/app_translations.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

sections = {}
current_section = None
for i, line in enumerate(lines):
    if '_es = {' in line: current_section = 'es'
    elif '_en = {' in line: current_section = 'en'
    elif '_pt = {' in line: current_section = 'pt'
    elif '_fr = {' in line: current_section = 'fr'
    elif '_it = {' in line: current_section = 'it'
    
    m = re.match(r"\s*'([^']+)'\s*:", line)
    if m and current_section:
        key = m.group(1)
        if current_section not in sections:
            sections[current_section] = {}
        if key not in sections[current_section]:
            sections[current_section][key] = []
        sections[current_section][key].append(i+1)

for sec in ['es','en','pt','fr','it']:
    dups = {k:v for k,v in sections.get(sec,{}).items() if len(v)>1}
    if dups:
        print(f'--- {sec} duplicates ---')
        for k,v in dups.items():
            print(f'  {k}: lines {v}')
    else:
        print(f'--- {sec}: no duplicates ---')
