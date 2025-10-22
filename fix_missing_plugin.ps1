# Script PowerShell para solucionar MissingPluginException
# Ejecutar desde: D:\projects\biux
# Uso: .\fix_missing_plugin.ps1

Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  SOLUCIONADOR DE MissingPluginException                  ║" -ForegroundColor Cyan
Write-Host "║  Firebase Realtime Database - Biux App                   ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Verificar que estamos en el directorio correcto
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ ERROR: No se encontró pubspec.yaml" -ForegroundColor Red
    Write-Host "   Ejecuta este script desde: D:\projects\biux" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Directorio correcto detectado" -ForegroundColor Green
Write-Host ""

# Paso 2: Detener cualquier proceso de Flutter
Write-Host "🛑 Deteniendo procesos de Flutter..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.Name -like "*flutter*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "✅ Procesos detenidos" -ForegroundColor Green
Write-Host ""

# Paso 3: Limpiar Flutter
Write-Host "🧹 Limpiando Flutter..." -ForegroundColor Yellow
flutter clean | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Flutter limpio" -ForegroundColor Green
}
else {
    Write-Host "⚠️  Advertencia: flutter clean falló" -ForegroundColor Yellow
}
Write-Host ""

# Paso 4: Borrar carpetas build de Android
Write-Host "🗑️  Borrando carpetas build de Android..." -ForegroundColor Yellow
Remove-Item -Recurse -Force "android\build" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "android\app\build" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
Write-Host "✅ Carpetas build borradas" -ForegroundColor Green
Write-Host ""

# Paso 5: Reinstalar dependencias
Write-Host "📦 Reinstalando dependencias..." -ForegroundColor Yellow
flutter pub get | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dependencias instaladas" -ForegroundColor Green
}
else {
    Write-Host "❌ ERROR: flutter pub get falló" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Paso 6: Verificar google-services.json
Write-Host "🔍 Verificando google-services.json..." -ForegroundColor Yellow
if (Test-Path "android\app\google-services.json") {
    Write-Host "✅ google-services.json encontrado" -ForegroundColor Green
}
else {
    Write-Host "❌ ERROR: google-services.json NO encontrado" -ForegroundColor Red
    Write-Host "   Descárgalo desde Firebase Console" -ForegroundColor Yellow
    Write-Host "   Y colócalo en: android\app\google-services.json" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Paso 7: Limpiar Gradle
Write-Host "🧹 Limpiando Gradle..." -ForegroundColor Yellow
Push-Location android
.\gradlew clean | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Gradle limpio" -ForegroundColor Green
}
else {
    Write-Host "⚠️  Advertencia: gradlew clean falló" -ForegroundColor Yellow
}
Pop-Location
Write-Host ""

# Paso 8: Verificar configuración
Write-Host "🔍 Verificando configuración..." -ForegroundColor Yellow

# Verificar build.gradle.kts
$buildGradle = Get-Content "android\app\build.gradle.kts" -Raw
if ($buildGradle -match 'com\.google\.gms\.google-services') {
    Write-Host "✅ Plugin Google Services encontrado en build.gradle.kts" -ForegroundColor Green
}
else {
    Write-Host "⚠️  ADVERTENCIA: Plugin Google Services NO encontrado" -ForegroundColor Yellow
    Write-Host "   Agrega: id('com.google.gms.google-services')" -ForegroundColor Yellow
}

# Verificar firebase_options.dart
$firebaseOptions = Get-Content "lib\firebase_options.dart" -Raw
if ($firebaseOptions -match 'databaseURL') {
    Write-Host "✅ databaseURL encontrado en firebase_options.dart" -ForegroundColor Green
}
else {
    Write-Host "⚠️  ADVERTENCIA: databaseURL NO encontrado" -ForegroundColor Yellow
    Write-Host "   Ejecuta: flutterfire configure" -ForegroundColor Yellow
}
Write-Host ""

# Paso 9: Mostrar dispositivos disponibles
Write-Host "📱 Dispositivos disponibles:" -ForegroundColor Yellow
flutter devices
Write-Host ""

# Paso 10: Instrucciones finales
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ LIMPIEZA COMPLETADA                                  ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📋 PRÓXIMOS PASOS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Ejecuta:" -ForegroundColor White
Write-Host "   flutter run" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Espera a que compile COMPLETAMENTE" -ForegroundColor White
Write-Host "   (NO uses hot reload después)" -ForegroundColor Red
Write-Host ""
Write-Host "3. Prueba comentar en un post" -ForegroundColor White
Write-Host ""
Write-Host "4. Si sigue fallando:" -ForegroundColor White
Write-Host "   - Agrega FirebaseDatabaseDiagnostic widget" -ForegroundColor Yellow
Write-Host "   - Presiona 'Probar Conexión'" -ForegroundColor Yellow
Write-Host "   - Reporta el resultado" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  IMPORTANTE:" -ForegroundColor Red
Write-Host "   NO uses 'r' (hot reload) después de 'flutter run'" -ForegroundColor Red
Write-Host "   Los plugins nativos requieren rebuild completo" -ForegroundColor Red
Write-Host ""
Write-Host "🚀 ¡Buena suerte!" -ForegroundColor Green
