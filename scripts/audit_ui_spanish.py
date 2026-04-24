#!/usr/bin/env python3
"""Audit remaining hardcoded Spanish strings in PRESENTATION layer only (screens/widgets)"""
import re, os, glob

# Only presentation layer files - what users actually see
files = glob.glob('lib/**/presentation/**/*.dart', recursive=True)
files += glob.glob('lib/shared/widgets/*.dart', recursive=True)
files += glob.glob('lib/shared/services/permission_service.dart', recursive=True)
files = list(set(files))
files = [f for f in files if 'app_translations' not in f and 'locale_notifier' not in f]

spanish_patterns = [
    r'Cancelar', r'Guardar', r'Eliminar', r'Editar', r'Confirmar', r'Aceptar',
    r'Cerrar', r'Buscar', r'Siguiente', r'Anterior', r'Publicar', r'Compartir',
    r'Enviar', r'Agregar', r'Crear(?!\.)', r'Cargar', r'Actualizar', r'Copiar',
    r'Seleccionar', r'Descartar', r'Salir', r'Continuar', r'Reintentar',
    r'[Pp]erfil', r'[Rr]odada', r'[Gg]rupo', r'[Mm]ensaje', r'[Ff]oto', r'[Pp]ublicaci',
    r'Seguidores', r'Siguiendo', r'Miembros', r'Administrador',
    r'No hay', r'No se ', r'Error al', r'Ingresa', r'Escribe',
    r'[Uu]suario', r'[Cc]orreo', r'[Nn]ombre', r'[Cc]ontrase',
    r'[Cc]argando', r'Texto copiado',
    r'\xbf',  # ¿
    r'Hoy', r'Ayer', r'[Ss]emana', 
    r'[Cc].mara', r'[Uu]bicaci', r'[Mm]icr.fono', r'[Gg]aler',
    r'[Pp]ermiso', r'Desliza', r'Presiona', r'Mantener', r'Soltar',
    r'Descripci', r'Informaci', r'Configuraci',
    r'[Nn]egrita', r'[Cc]ontraste', r'[Aa]nimaci',
    r'Silenciar', r'Bloquear', r'Reportar', r'Denunciar',
    r'[Ss]eguir\b', r'[Dd]ejar de seguir', r'[Ss]olicitud',
    r'[Dd]istancia', r'[Vv]elocidad', r'[Dd]uraci', r'[Cc]alor',
    r'[Ee]levaci', r'[Rr]itmo', r'[Kk]il.metro',
    r'[Rr]uta', r'[Mm]apa',
    r'[Nn]otificaci', r'[Hh]istoria', r'[Cc]omentario',
    r'[Rr]esponder', r'[Mm]e gusta', r'[Ff]avorito',
    r'[Ss]in ', r'Ning',
    r'[Ll]ogro', r'[Ee]stad.stica', r'[Rr]ecord',
    r'[Bb]icicleta', r'[Cc]iclismo', r'[Cc]iclista',
    r'[Cc]lima', r'[Tt]emperatura', r'[Vv]iento', r'[Hh]umedad',
    r'[Ee]mergencia', r'[Aa]ccidente', r'[Pp]eligro',
    r'[Rr]obad[ao]', r'[Ee]ducaci', r'[Ss]eguridad',
    r'[Tt]ienda', r'[Cc]arrito', r'[Cc]omprar', r'[Pp]recio',
    r'[Aa]migo', r'[Ss]ugerencia', r'[Rr]ecomenda',
    r'[Pp]rivad', r'[Pp].blic',
    r'[Ii]magen', r'[Vv]ideo', r'[Aa]udio',
    r'[Ff]iltrar', r'[Oo]rdenar',
    r'[Nn]uev[oa]', r'[Rr]eciente', r'[Pp]opular',
    r'[Dd]eshacer', r'[Ll]ista', r'[Dd]etalle',
    r'[Pp]endiente', r'[Aa]probad', r'[Rr]echazad',
    r'[Cc]omplet', r'[Cc]onex', r'[Cc]onect',
    r'[Dd]escuento', r'[Cc]up.n', r'[Oo]ferta',
    r'[Vv]erific', r'[Rr]egistrad',
    r'[Cc]ategor', r'[Pp]roducto', r'[Ss]tock',
    r'[Vv]endedor', r'[Tt]omar foto',
    r'[Gg]rabar', r'[Ss]ubir',
    r'[Rr]eporte', r'[Dd]enuncia',
    r'[Cc]uenta', r'[Ss]esi.n',
    r'[Pp]agar', r'[Pp]ago',
]

combined = '|'.join(spanish_patterns)

count = 0
results = []
for fpath in sorted(files):
    try:
        with open(fpath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except:
        continue
    for i, line in enumerate(lines):
        stripped = line.strip()
        # Skip comments, imports, and debug/log lines
        if stripped.startswith('//') or stripped.startswith('import ') or stripped.startswith('///'):
            continue
        if 'print(' in stripped or 'debugPrint(' in stripped or 'log(' in stripped:
            continue
        if 'Logger' in stripped or 'logger' in stripped:
            continue
        # Skip emoji-prefixed debug messages
        if any(stripped.startswith(p) for p in ["'📱", "'🔍", "'📋", "'📝", "'📡", "'🔄", "'✅", "'❌", "'⚠️", "'🚀", "'📸", "'🎥", "'📤", "'🗑"]):
            continue
        
        # Find all string literals
        all_strings = re.findall(r"'([^']*?)'", line)
        all_strings += re.findall(r'"([^"]*?)"', line)
        
        for s in all_strings:
            if not s or len(s) < 3:
                continue
            # Skip non-user-visible strings
            if s.startswith('package:') or s.startswith('assets/') or s.startswith('img/'):
                continue
            if s.startswith('http') or s.startswith('/api') or s.startswith('0x'):
                continue
            if re.match(r'^[a-z_]+$', s):  # translation key
                continue
            if re.match(r'^[A-Z_0-9]+$', s):  # constant
                continue
            if re.match(r'^#[0-9a-fA-F]+$', s):  # hex color
                continue
            if re.match(r'^[\d.]+$', s):  # number
                continue
            if 'l.t(' in s:
                continue
            if s.startswith('Error:') or s == 'delete' or s == 'error':
                continue
            # Skip Firebase/tech strings
            if any(x in s for x in ['firebase', 'Firebase', 'Firestore', 'userId', 'chatId', 'groupId', 'token', '.png', '.jpg', '.svg', 'null', 'void', 'usuarios', 'data.', 'snapshot', 'doc.', 'ref.']):
                continue
            # Skip variable interpolation patterns that are just IDs
            if s.startswith('$') and len(s) < 20:
                continue
            
            if re.search(combined, s):
                results.append((fpath.replace('\\', '/'), i+1, s[:120]))
                count += 1

# Deduplicate
seen = set()
unique = []
for fpath, line, s in results:
    key = f"{fpath}:{line}"
    if key not in seen:
        seen.add(key)
        unique.append((fpath, line, s))

print(f"TOTAL UI STRINGS TO TRANSLATE: {len(unique)}")
print("=" * 80)
cur_file = ""
for fpath, line, s in unique:
    if fpath != cur_file:
        cur_file = fpath
        print(f"\n### {fpath}")
    print(f"  L{line}: {s}")
