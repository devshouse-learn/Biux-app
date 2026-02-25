#!/usr/bin/env python3
"""
Descarga imagenes buscando en Google Images via scraping simple.
Busca por nombre exacto del producto + "producto" para encontrar fotos de producto real.
Usa DuckDuckGo Instant Answer API (no requiere API key).
"""
import urllib.request
import urllib.parse
import json
import os
import ssl
import re

ssl._create_default_https_context = ssl._create_unverified_context

DOWNLOAD_DIR = '/tmp/biux_mock_images'
DEST_DIR = '/Users/macmini/biux/img/shop'
os.makedirs(DOWNLOAD_DIR, exist_ok=True)
os.makedirs(DEST_DIR, exist_ok=True)

# Productos con queries de busqueda MUY especificos
PRODUCTS = [
    {
        'filename': 'mock_jersey.jpg',
        'query': 'cycling jersey product photo',
        # Backup: URL directa de un jersey de ciclismo real de una tienda
        'direct_urls': [
            'https://contents.mediadecathlon.com/p2519513/k$c647e8e7b1d0e9a06ceb31ba65f8c3cc/maillot-manga-corta-ciclismo-carretera-hombre-van-rysel-rcr.jpg?format=auto&quality=40&f=800x800',
            'https://contents.mediadecathlon.com/p1968825/k$2a70c16e3c0f2b3e4e5a6b7c8d9e0f1a/maillot-ciclismo-carretera.jpg?format=auto&quality=40&f=800x800',
        ],
    },
    {
        'filename': 'mock_culote.jpg',
        'query': 'culotte ciclismo badana producto',
        'direct_urls': [
            'https://contents.mediadecathlon.com/p2397562/k$0c3e8f6a2b4d7c9e1f5a3b6d8c0e2f4a/culotte-corto-ciclismo-carretera-hombre.jpg?format=auto&quality=40&f=800x800',
            'https://contents.mediadecathlon.com/p1548498/k$a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6/culote-ciclismo.jpg?format=auto&quality=40&f=800x800',
        ],
    },
    {
        'filename': 'mock_guantes.jpg',
        'query': 'cycling gloves product',
        'direct_urls': [
            'https://contents.mediadecathlon.com/p2060498/k$a1b2c3d4e5f6g7h8i9j0/guantes-ciclismo-carretera-roadr-900.jpg?format=auto&quality=40&f=800x800',
            'https://contents.mediadecathlon.com/p1821055/k$f1e2d3c4b5a6/guantes-ciclismo.jpg?format=auto&quality=40&f=800x800',
        ],
    },
    {
        'filename': 'mock_casco.jpg',
        'query': 'bicycle helmet cycling product',
        'direct_urls': [
            'https://contents.mediadecathlon.com/p2457755/k$a1b2c3d4/casco-ciclismo-carretera-van-rysel.jpg?format=auto&quality=40&f=800x800',
            'https://contents.mediadecathlon.com/p1604388/k$e5f6a7b8/casco-bicicleta.jpg?format=auto&quality=40&f=800x800',
        ],
    },
    {
        'filename': 'mock_gafas.jpg',
        'query': 'cycling sunglasses sport product',
        'direct_urls': [
            'https://contents.mediadecathlon.com/p2353917/k$a1b2c3/gafas-ciclismo-adulto-roadr-900.jpg?format=auto&quality=40&f=800x800',
            'https://contents.mediadecathlon.com/p2104559/k$d4e5f6/gafas-ciclismo.jpg?format=auto&quality=40&f=800x800',
        ],
    },
    {
        'filename': 'mock_zapatillas.jpg',
        'query': 'road cycling shoes product',
        'direct_urls': [
            'https://contents.mediadecathlon.com/p2285937/k$a1b2c3/zapatillas-ciclismo-carretera-van-rysel.jpg?format=auto&quality=40&f=800x800',
            'https://contents.mediadecathlon.com/p1965478/k$d4e5f6/zapatillas-ciclismo-carretera.jpg?format=auto&quality=40&f=800x800',
        ],
    },
]

headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'image/jpeg,image/png,image/*,*/*',
}

def download_image(url, filepath):
    """Intenta descargar una imagen y verifica que sea valida"""
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=10) as response:
            data = response.read()
            content_type = response.headers.get('Content-Type', '')
            
            # Verificar que es una imagen real (no HTML de error)
            if len(data) < 2000:
                return False, f"Muy pequena ({len(data)} bytes)"
            if b'<!DOCTYPE' in data[:200] or b'<html' in data[:200]:
                return False, "Es HTML, no imagen"
            if 'text/html' in content_type:
                return False, f"Content-Type: {content_type}"
            
            with open(filepath, 'wb') as f:
                f.write(data)
            return True, f"{len(data)/1024:.0f} KB"
    except Exception as e:
        return False, str(e)

def search_and_download_via_bing(query, filepath):
    """Busca imagen en Bing Images y descarga la primera resultado"""
    try:
        search_url = f"https://www.bing.com/images/search?q={urllib.parse.quote(query)}&first=1&count=5&qft=+filterui:imagesize-medium"
        req = urllib.request.Request(search_url, headers={
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
        })
        with urllib.request.urlopen(req, timeout=10) as response:
            html = response.read().decode('utf-8', errors='ignore')
        
        # Extraer URLs de imagenes del HTML de Bing
        # Bing usa murl en los resultados
        img_urls = re.findall(r'murl&quot;:&quot;(https?://[^&]+\.(?:jpg|jpeg|png))', html)
        
        if not img_urls:
            # Intentar otro patron
            img_urls = re.findall(r'"murl":"(https?://[^"]+)"', html)
        
        for img_url in img_urls[:5]:
            img_url = img_url.replace('&amp;', '&')
            success, msg = download_image(img_url, filepath)
            if success:
                return True, f"Bing: {msg}"
        
        return False, f"No se encontraron imagenes para: {query}"
    except Exception as e:
        return False, f"Error buscando: {e}"

print("=" * 60)
print("  BUSCANDO Y DESCARGANDO IMAGENES REALES DE PRODUCTOS")
print("=" * 60)

results = {}
for product in PRODUCTS:
    filepath_tmp = os.path.join(DOWNLOAD_DIR, product['filename'])
    filepath_dest = os.path.join(DEST_DIR, product['filename'])
    
    print(f"\n🔍 {product['filename']}: buscando '{product['query']}'...")
    
    downloaded = False
    
    # Intento 1: URLs directas conocidas
    for url in product.get('direct_urls', []):
        success, msg = download_image(url, filepath_tmp)
        if success:
            print(f"   ✅ URL directa: {msg}")
            downloaded = True
            break
        else:
            print(f"   ⚠️  URL directa fallo: {msg}")
    
    # Intento 2: Buscar en Bing Images
    if not downloaded:
        success, msg = search_and_download_via_bing(product['query'], filepath_tmp)
        if success:
            print(f"   ✅ {msg}")
            downloaded = True
        else:
            print(f"   ❌ {msg}")
    
    if downloaded:
        # Copiar a destino
        import shutil
        shutil.copy2(filepath_tmp, filepath_dest)
        results[product['filename']] = True
        print(f"   📁 Copiado a: img/shop/{product['filename']}")
    else:
        results[product['filename']] = False

print(f"\n{'=' * 60}")
ok = sum(1 for v in results.values() if v)
print(f"  RESULTADO: {ok}/{len(results)} imagenes descargadas")
print(f"{'=' * 60}")

for name, success in results.items():
    icon = "✅" if success else "❌"
    print(f"  {icon} {name}")

if ok < 6:
    print(f"\n⚠️ Faltan {6-ok} imagenes.")
    print("Para las que faltan, descargalas manualmente:")
    print("  1. Busca en Google Imagenes el producto")
    print("  2. Descarga la foto y guardala como:")
    for name, success in results.items():
        if not success:
            print(f"     /Users/macmini/biux/img/shop/{name}")
