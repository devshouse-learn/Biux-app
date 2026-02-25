#!/usr/bin/env python3
"""
Descarga imagenes reales de productos de ciclismo usando urllib (sin dependencias externas).
Las URLs son de Pexels, fotos libres de derechos.
"""
import urllib.request
import os
import ssl

# Desactivar verificacion SSL para evitar errores en macOS
ssl._create_default_https_context = ssl._create_unverified_context

DOWNLOAD_DIR = '/tmp/biux_mock_images'
os.makedirs(DOWNLOAD_DIR, exist_ok=True)

# URLs de Pexels con IDs verificados de fotos de ciclismo
PRODUCT_IMAGES = [
    {
        'key': 'jersey',
        'name': 'Jersey Ciclismo Pro',
        'url': 'https://images.pexels.com/photos/248547/pexels-photo-248547.jpeg?auto=compress&cs=tinysrgb&w=600',
        'filename': 'mock_jersey.jpg',
    },
    {
        'key': 'culote',
        'name': 'Culote con Badana Gel',
        'url': 'https://images.pexels.com/photos/5970275/pexels-photo-5970275.jpeg?auto=compress&cs=tinysrgb&w=600',
        'filename': 'mock_culote.jpg',
    },
    {
        'key': 'guantes',
        'name': 'Guantes Ciclismo Gel',
        'url': 'https://images.pexels.com/photos/5462562/pexels-photo-5462562.jpeg?auto=compress&cs=tinysrgb&w=600',
        'filename': 'mock_guantes.jpg',
    },
    {
        'key': 'casco',
        'name': 'Casco Aerodinamico',
        'url': 'https://images.pexels.com/photos/5462568/pexels-photo-5462568.jpeg?auto=compress&cs=tinysrgb&w=600',
        'filename': 'mock_casco.jpg',
    },
    {
        'key': 'gafas',
        'name': 'Gafas Deportivas UV400',
        'url': 'https://images.pexels.com/photos/701877/pexels-photo-701877.jpeg?auto=compress&cs=tinysrgb&w=600',
        'filename': 'mock_gafas.jpg',
    },
    {
        'key': 'zapatillas',
        'name': 'Zapatillas Ciclismo Road',
        'url': 'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?auto=compress&cs=tinysrgb&w=600',
        'filename': 'mock_zapatillas.jpg',
    },
]

print("=" * 60)
print("  DESCARGANDO IMAGENES DE PRODUCTOS DE CICLISMO")
print("=" * 60)

headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)'}
downloaded = 0

for img in PRODUCT_IMAGES:
    filepath = os.path.join(DOWNLOAD_DIR, img['filename'])
    print(f"\n📥 {img['name']}")
    print(f"   URL: {img['url'][:80]}...")
    
    try:
        req = urllib.request.Request(img['url'], headers=headers)
        with urllib.request.urlopen(req, timeout=15) as response:
            data = response.read()
            if len(data) > 1000:
                with open(filepath, 'wb') as f:
                    f.write(data)
                print(f"   ✅ OK ({len(data)/1024:.0f} KB) -> {filepath}")
                downloaded += 1
            else:
                print(f"   ❌ Imagen muy pequeña ({len(data)} bytes)")
    except Exception as e:
        print(f"   ❌ Error: {e}")

print(f"\n{'=' * 60}")
print(f"  RESULTADO: {downloaded}/6 imagenes descargadas")
print(f"  Directorio: {DOWNLOAD_DIR}")
print(f"{'=' * 60}")

if downloaded > 0:
    print(f"\nArchivos descargados:")
    for f in os.listdir(DOWNLOAD_DIR):
        size = os.path.getsize(os.path.join(DOWNLOAD_DIR, f))
        print(f"  📁 {f} ({size/1024:.0f} KB)")
    
    print(f"\n📌 SIGUIENTE PASO:")
    print(f"   Sube las imagenes a Firebase Storage:")
    print(f"   https://console.firebase.google.com/project/biux-1576614678644/storage")
    print(f"   Carpeta destino: shop/mock_products/")
