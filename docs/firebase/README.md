# Documentación Firebase

Esta carpeta contiene toda la documentación relacionada con la configuración, implementación y uso de Firebase en la aplicación Biux.

## Documentos Disponibles

### Autenticación por Teléfono

1. **FIREBASE_PHONE_AUTH_SETUP.md**
   - Configuración inicial de Firebase Phone Authentication
   - Requisitos previos
   - Configuración en Firebase Console
   - Configuración en el proyecto Flutter

2. **FIREBASE_PHONE_AUTH_IMPLEMENTATION.md**
   - Implementación del código de autenticación
   - Flujo de verificación de teléfono
   - Manejo de errores y edge cases
   - Ejemplos de código

3. **ENABLE_FIREBASE_PHONE_AUTH_MANUAL.md**
   - Guía manual paso a paso
   - Habilitación de Phone Auth en diferentes plataformas
   - Troubleshooting común

## Servicios Firebase Utilizados

- **Firebase Authentication** - Autenticación de usuarios (teléfono, Google, Facebook, Apple)
- **Cloud Firestore** - Base de datos NoSQL en tiempo real
- **Firebase Storage** - Almacenamiento de archivos (imágenes, videos)
- **Firebase Analytics** - Análisis de uso de la aplicación
- **Firebase Messaging** - Notificaciones push
- **Firebase Crashlytics** - Reportes de crashes

## Configuración General

El archivo `firebase_options.dart` en la raíz de `lib/` contiene la configuración auto-generada por FlutterFire CLI.

**Project ID**: `biux-1576614678644`

## Recursos Adicionales

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Documentation](https://firebase.google.com/docs)

## Notas Importantes

- Nunca commitear archivos `google-services.json` o `GoogleService-Info.plist` con credenciales reales
- Mantener las reglas de seguridad de Firestore actualizadas
- Revisar periódicamente el uso de Firebase para optimizar costos
