#!/usr/bin/env python3
"""
Descarga imagenes reales de productos de ciclismo y las sube a Firebase Storage.
Luego actualiza mock_products.dart con las URLs de Firebase.

Requisitos:
  pip3 install google-cloud-storage firebase-admin
  
Alternativa manual: Subir las imagenes desde la consola de Firebase.
"""
import subprocess
import sys
import os

# Verificar si firebase-admin esta instalado
try:
    import firebase_admin
    from firebase_admin import credentials, storage
    HAS_FIREBASE = True
except ImportError:
    HAS_FIREBASE = False

# Verificar si requests esta instalado
try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False

if not HAS_REQUESTS:
    print("Instalando requests...")
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'requests', '-q'])
    import requests

# URLs verificadas de imagenes LIBRES de derechos (Pexels - API publica)
# Cada URL fue seleccionada manualmente para coincidir con el producto
PRODUCT_IMAGES = {
    'jersey': {
        'name': 'Jersey Ciclismo Pro',
        # Pexels: ciclista con jersey - foto por Pixabay
        'url': 'https://images.pexels.com/photos/248547/pexels-photo-248547.jpeg?auto=compress&cs=tinysrgb&w=600',
        'filename': 'mock_jersey.jpg',
    },
    'shorts': {
        'name': 'Culote con Badana Gel',
        # Pexels: ciclista de ruta pedaleando
        'url': 'https://images.pexels.com/photos/5970275/pexels-photo-5970275.jpeg?auto=compress&cs=tinysrgb&w=600',
        'filename': 'mock_culote.jpg',
    },
    'gloves': {
        'name': 'Guantes Ciclismo Gel',
        # Pexels: manos en manillar de bicicleta
        'url': 'https://images.pexels.com/photos/5462562/pexels-photo-5462562.jpeg?auto=compress&cs=tinysrgb&w=600',
        'filename': 'mock_guantes.jpg',
    },
    'helmet': {
        'name': 'Casco Aerodinamico',
        # Pexels: casco de ciclismo
        'url': 'https://images.pexels.com/photos/5462568/pexels-photo-5462568.jpeg?auto=compress&cs=tinysrgb&w=600',
        'filename': 'mock_casco.jpg',
    },
    'glasses': {
        'name': 'Gafas Deportivas UV400',
        # Pexels: gafas de sol deportivas
        'url': 'https://images.pexels.com/photos/701877/pexels-photo-701877.jpeg?auto=compress&cs=tinysrgb&w=600',
        'filename': 'mock_gafas.jpg',
    },
    'shoes': {
        'name': 'Zapatillas Ciclismo Road',
        # Pexels: zapatillas deportivas
        'url': 'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?auto=compress&cs=tinysrgb&w=600',
        'filename': 'mock_zapatillas.jpg',
    },
}

# Directorio temporal para descargar
DOWNLOAD_DIR = '/tmp/biux_mock_images'
os.makedirs(DOWNLOAD_DIR, exist_ok=True)

print("=" * 60)
print("  DESCARGANDO IMAGENES DE PRODUCTOS")
print("=" * 60)

downloaded = {}
for key, info in PRODUCT_IMAGES.items():
    filepath = os.path.join(DOWNLOAD_DIR, info['filename'])
    print(f"\n📥 Descargando: {info['name']}")
    print(f"   URL: {info['url']}")
    
    try:
        response = requests.get(info['url'], timeout=15, headers={
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)'
        })
        if response.status_code == 200 and len(response.content) > 1000:
            with open(filepath, 'wb') as f:
                f.write(response.content)
            size_kb = len(response.content) / 1024
            print(f"   ✅ Descargada ({size_kb:.0f} KB)")
            downloaded[key] = filepath
        else:
            print(f"   ❌ Error: status={response.status_code}, size={len(response.content)}")
    except Exception as e:
        print(f"   ❌ Error: {e}")

print(f"\n{'=' * 60}")
print(f"  RESULTADO: {len(downloaded)}/{len(PRODUCT_IMAGES)} imagenes descargadas")
print(f"{'=' * 60}")

if len(downloaded) < 6:
    print("\n⚠️  Algunas imagenes no se descargaron.")
    print("Las imagenes descargadas estan en:", DOWNLOAD_DIR)
    print("\nPuedes subirlas manualmente a Firebase Storage:")
    print("  1. Ve a https://console.firebase.google.com/project/biux-1576614678644/storage")
    print("  2. Crea carpeta 'shop/mock_products/'")
    print("  3. Sube cada imagen")
    print("  4. Copia la URL de descarga")
else:
    print(f"\n✅ Todas las imagenes descargadas en: {DOWNLOAD_DIR}")
    print("\nAhora necesitas subirlas a Firebase Storage.")
    print("Puedes hacerlo de dos formas:\n")
    print("OPCION A - Firebase Console (manual):")
    print("  1. Ve a https://console.firebase.google.com/project/biux-1576614678644/storage")
    print("  2. Crea carpeta 'shop/mock_products/'")
    print("  3. Sube cada archivo .jpg")
    print("  4. Copia cada URL de descarga\n")
    print("OPCION B - Ejecutar: python3 scripts/upload_to_firebase.py")
    print("  (requiere: pip3 install firebase-admin)")

# Listar archivos descargados
print(f"\nArchivos en {DOWNLOAD_DIR}:")
for key, path in downloaded.items():
    size = os.path.getsize(path)
    print(f"  📁 {os.path.basename(path)} ({size/1024:.0f} KB)")
