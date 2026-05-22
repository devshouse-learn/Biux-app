#!/bin/bash

# Mapeo de textos → claves de traducción (para los textos críticos más comunes)
declare -A map
map["Text('Seguir pedaleando')"]="Text(l.t('continue_cycling'))"
map["Text('Entendido')"]="Text(l.t('understood'))"
map["Text('Cargando...')"]="Text(l.t('loading'))"
map["Text('Crear')"]="Text(l.t('create'))"
map["Text('Cancelar')"]="Text(l.t('cancel'))"
map["Text('No')"]="Text(l.t('no_button'))"
map["content: Text('Agrega la parte frontal del documento')"]="content: Text(l.t('front_side_required'))"
map["content: Text('Error: \$e')"]="content: Text(l.t('error'))"
map["Text('Limpiar Base de Datos')"]="Text(l.t('clean_database'))"
map["Text('Esto incluye:')"]="Text(l.t('includes'))"
map["Text('Limpiando productos sin imágenes...')"]="Text(l.t('cleaning_products'))"
map["const Text('Limpiar Ahora')"]="const Text(l.t('clean_now'))"
map["const Text('Volver')"]="const Text(l.t('back_button'))"
map["Text('Error al enviar audio: \$e')"]="Text(l.t('error_sending_audio'))"
map["Text('Error al seleccionar imagen: \$e')"]="Text(l.t('error_selecting_image'))"
map["Text('Error al subir imagen')"]="Text(l.t('error_uploading_image'))"
map["Text('Error al subir video')"]="Text(l.t('error_uploading_video'))"
map["Text('Error al repostear: \$e')"]="Text(l.t('error_reposting'))"

# Encontrar archivos
files=$(find lib/features -name "*.dart" -type f \( -path "*/presentation/screens/*" -o -path "*/presentation/widgets/*" \))

count=0
for file in $files; do
    for old in "${!map[@]}"; do
        new=${map[$old]}
        if grep -q "$old" "$file" 2>/dev/null; then
            # Escapar para sed
            old_escaped=$(echo "$old" | sed 's/[&/\]/\&/g')
            new_escaped=$(echo "$new" | sed 's/[&/\]/\&/g')
            sed -i "s/$old_escaped/$new_escaped/g" "$file"
            ((count++))
            echo "Reemplazado en $file: $old"
        fi
    done
done

echo "Total reemplazos realizados: $count"
