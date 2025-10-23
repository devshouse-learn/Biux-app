# Script de despliegue de Cloud Functions para Biux

Write-Host "🔔 Desplegando Cloud Functions de Notificaciones - Biux" -ForegroundColor Cyan
Write-Host ""

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "functions/notifications.js")) {
    Write-Host "❌ Error: Debes ejecutar este script desde biux-cloud/" -ForegroundColor Red
    exit 1
}

# Verificar que Firebase CLI está instalado
try {
    firebase --version | Out-Null
}
catch {
    Write-Host "❌ Firebase CLI no está instalado" -ForegroundColor Red
    Write-Host "Instala con: npm install -g firebase-tools" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Firebase CLI encontrado" -ForegroundColor Green

# Verificar login
Write-Host ""
Write-Host "📋 Verificando autenticación..." -ForegroundColor Yellow
$loginCheck = firebase projects:list 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ No estás autenticado en Firebase" -ForegroundColor Red
    Write-Host "Ejecuta: firebase login" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Autenticado correctamente" -ForegroundColor Green

# Mostrar proyecto actual
Write-Host ""
Write-Host "📋 Proyecto actual:" -ForegroundColor Yellow
firebase use

# Confirmar despliegue
Write-Host ""
Write-Host "⚠️  ¿Deseas desplegar las Cloud Functions?" -ForegroundColor Yellow
Write-Host "   Esto desplegará todas las funciones de notificaciones:" -ForegroundColor Gray
Write-Host "   - onLikeCreated" -ForegroundColor Gray
Write-Host "   - onCommentCreated" -ForegroundColor Gray
Write-Host "   - onFollowCreated" -ForegroundColor Gray
Write-Host "   - onRideInvitationCreated" -ForegroundColor Gray
Write-Host "   - onGroupInvitationCreated" -ForegroundColor Gray
Write-Host "   - onStoryCreated" -ForegroundColor Gray
Write-Host "   - sendRideReminders (scheduled)" -ForegroundColor Gray
Write-Host "   - onGroupUpdate" -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "Continuar? (s/n)"
if ($confirm -ne "s" -and $confirm -ne "S") {
    Write-Host "❌ Despliegue cancelado" -ForegroundColor Yellow
    exit 0
}

# Instalar dependencias si es necesario
Write-Host ""
Write-Host "📦 Verificando dependencias..." -ForegroundColor Yellow
Set-Location functions

if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Instalando dependencias..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al instalar dependencias" -ForegroundColor Red
        Set-Location ..
        exit 1
    }
    Write-Host "✅ Dependencias instaladas" -ForegroundColor Green
}
else {
    Write-Host "✅ Dependencias ya instaladas" -ForegroundColor Green
}

Set-Location ..

# Desplegar funciones
Write-Host ""
Write-Host "🚀 Desplegando funciones..." -ForegroundColor Cyan
firebase deploy --only functions

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ ¡Despliegue completado exitosamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Próximos pasos:" -ForegroundColor Yellow
    Write-Host "1. Verifica las funciones en Firebase Console:" -ForegroundColor Gray
    Write-Host "   https://console.firebase.google.com/project/biux-1576614678644/functions" -ForegroundColor Blue
    Write-Host ""
    Write-Host "2. Prueba las notificaciones:" -ForegroundColor Gray
    Write-Host "   - Dale like a una publicación" -ForegroundColor Gray
    Write-Host "   - Comenta en una experiencia" -ForegroundColor Gray
    Write-Host "   - Sigue a un usuario" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Monitorea los logs:" -ForegroundColor Gray
    Write-Host "   firebase functions:log" -ForegroundColor Blue
    Write-Host ""
}
else {
    Write-Host ""
    Write-Host "❌ Error en el despliegue" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔍 Verifica los errores arriba y:" -ForegroundColor Yellow
    Write-Host "1. Revisa la configuración de Firebase" -ForegroundColor Gray
    Write-Host "2. Verifica que el proyecto existe" -ForegroundColor Gray
    Write-Host "3. Comprueba los permisos de tu cuenta" -ForegroundColor Gray
    Write-Host ""
    exit 1
}
