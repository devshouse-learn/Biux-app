"""Fix remaining hardcoded strings in create_experience_screen.dart"""

FILE = 'lib/features/experiences/presentation/screens/create_experience_screen.dart'

with open(FILE, 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')

# Find the line with 'Información' 
for i, line in enumerate(lines):
    if "'Información'" in line:
        print(f"Found 'Información' at line {i+1}: {line.strip()!r}")

# Find lines with hardcoded info items
for i, line in enumerate(lines):
    if 'Post de solo texto' in line or 'Historia efímera' in line or 'Multimedia requerida' in line or 'Videos de hasta' in line or 'Máximo 5 elementos' in line:
        print(f"Found info item at line {i+1}: {line.strip()!r}")

print("\n--- Applying fixes ---")

# Replace 'Información' with l.t('information')
content = content.replace("'Información'", "l.t('information')")

# Replace the info items block - find by unique surrounding markers
# We need to replace each _buildInfoItem call that has hardcoded strings

replacements = [
    # text_only_post section
    ("'No se requiere ni permite multimedia. Solo escribe tu publicación.'", "l.t('text_only_post_info')"),
    ("'Tu historia desaparecerá en 24 horas.'", "l.t('ephemeral_story_info')"),
    ("'Las historias requieren al menos una imagen o video (<30s).'", "l.t('multimedia_required_info')"),
    ("'Los videos se comprimirán automáticamente para optimizar la calidad y el tamaño.'", "l.t('videos_compress_info')"),
]

for old, new in replacements:
    if old in content:
        content = content.replace(old, new)
        print(f"  Replaced: {old[:50]}...")
    else:
        print(f"  NOT FOUND: {old[:50]}...")

# For titles with broken emojis, we'll replace by line matching
lines = content.split('\n')
new_lines = []
for i, line in enumerate(lines):
    stripped = line.strip()
    if 'Post de solo texto' in stripped and '_buildInfoItem' not in stripped:
        # This is a title string in _buildInfoItem
        indent = line[:len(line) - len(line.lstrip())]
        new_lines.append(f"{indent}l.t('info_text_only_title'),")
        print(f"  Fixed line {i+1}: text_only title")
    elif 'Historia efímera' in stripped and '_buildInfoItem' not in stripped:
        indent = line[:len(line) - len(line.lstrip())]
        new_lines.append(f"{indent}l.t('info_ephemeral_story_title'),")
        print(f"  Fixed line {i+1}: ephemeral_story title")
    elif 'Multimedia requerida' in stripped and '_buildInfoItem' not in stripped:
        indent = line[:len(line) - len(line.lstrip())]
        new_lines.append(f"{indent}l.t('info_multimedia_required_title'),")
        print(f"  Fixed line {i+1}: multimedia_required title")
    elif 'Videos de hasta 30 segundos' in stripped and '_buildInfoItem' not in stripped:
        indent = line[:len(line) - len(line.lstrip())]
        new_lines.append(f"{indent}l.t('info_videos_30s_title'),")
        print(f"  Fixed line {i+1}: videos_30s title")
    elif 'Máximo 5 elementos' in stripped and '_buildInfoItem' not in stripped:
        indent = line[:len(line) - len(line.lstrip())]
        new_lines.append(f"{indent}l.t('info_max_5_items_title'),")
        print(f"  Fixed line {i+1}: max_5_items title")
    elif "Puedes agregar hasta 5" in stripped:
        indent = line[:len(line) - len(line.lstrip())]
        new_lines.append(f"{indent}l.t('max_5_items_info'),")
        print(f"  Fixed line {i+1}: max_5_items_info")
    else:
        new_lines.append(line)

content = '\n'.join(new_lines)

with open(FILE, 'w', encoding='utf-8') as f:
    f.write(content)

print("\nDone!")
