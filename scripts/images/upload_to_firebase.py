#!/usr/bin/env python3
"""
Sube las imagenes descargadas a Firebase Storage usando gsutil (viene con gcloud CLI)
o firebase CLI, y genera las URLs publicas.

Alternativa: usa firebase storage:upload si tienes firebase CLI instalado.
"""
import subprocess
import os
import json

DOWNLOAD_DIR = '/tmp/biux_mock_images'
BUCKET = 'biux-1576614678644.firebasestorage.app'
STORAGE_PATH = 'shop/mock_products'

# Mapeo de archivos a productos
FILES = {
    'mock_jersey.jpg': 'prod_001',
    'mock_culote.jpg': 'prod_002', 
    'mock_guantes.jpg': 'prod_003',
    'mock_casco.jpg': 'prod_004',
    'mock_gafas.jpg': 'prod_005',
    'mock_zapatillas.jpg': 'prod_006',
}

print("=" * 60)
print("  SUBIENDO IMAGENES A FIREBASE STORAGE")
print("=" * 60)

uploaded_urls = {}

for filename, prod_id in FILES.items():
    filepath = os.path.join(DOWNLOAD_DIR, filename)
    if not os.path.exists(filepath):
        print(f"❌ No encontrado: {filepath}")
        continue
    
    remote_path = f"{STORAGE_PATH}/{filename}"
    print(f"\n📤 Subiendo: {filename} -> gs://{BUCKET}/{remote_path}")
    
    # Intentar con gsutil
    try:
        result = subprocess.run(
            ['gsutil', 'cp', filepath, f'gs://{BUCKET}/{remote_path}'],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode == 0:
            # Hacer el archivo publico
            subprocess.run(
                ['gsutil', 'acl', 'ch', '-u', 'AllUsers:R', f'gs://{BUCKET}/{remote_path}'],
                capture_output=True, text=True, timeout=15
            )
            # URL publica
            url = f"https://firebasestorage.googleapis.com/v0/b/{BUCKET}/o/{STORAGE_PATH}%2F{filename}?alt=media"
            uploaded_urls[prod_id] = url
            print(f"   ✅ Subida exitosa")
            print(f"   🔗 {url}")
        else:
            print(f"   ❌ Error gsutil: {result.stderr}")
    except FileNotFoundError:
        print("   ⚠️  gsutil no encontrado. Intentando con firebase CLI...")
        # No hay firebase storage upload directo via CLI
        print("   ❌ Necesitas gsutil (Google Cloud SDK) o subir manualmente")
    except Exception as e:
        print(f"   ❌ Error: {e}")

if uploaded_urls:
    print(f"\n{'=' * 60}")
    print(f"  URLs GENERADAS ({len(uploaded_urls)}):")
    print(f"{'=' * 60}")
    for prod_id, url in uploaded_urls.items():
        print(f"  {prod_id}: {url}")
    
    # Guardar URLs en archivo JSON para uso posterior
    urls_file = '/tmp/biux_mock_urls.json'
    with open(urls_file, 'w') as f:
        json.dump(uploaded_urls, f, indent=2)
    print(f"\nURLs guardadas en: {urls_file}")
else:
    print(f"\n{'=' * 60}")
    print("  NO SE PUDIERON SUBIR IMAGENES AUTOMATICAMENTE")
    print(f"{'=' * 60}")
    print("\nOpciones:")
    print("1. Instala Google Cloud SDK: brew install google-cloud-sdk")
    print("2. O sube manualmente desde la consola de Firebase:")
    print(f"   https://console.firebase.google.com/project/biux-1576614678644/storage")
    print(f"   Carpeta: {STORAGE_PATH}/")
    print(f"   Archivos en: {DOWNLOAD_DIR}/")
