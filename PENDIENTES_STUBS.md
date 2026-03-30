# Pendientes implementados como STUBs

Todos los stubs han sido implementados (20 marzo 2026):

- [x] ~~Payments~~: Implementado con Firestore (`payment_intents`). Ver `lib/features/payments/data/repositories/payments_firebase_repository_impl.dart`
- [x] ~~Advertisements~~: Implementado con Firestore (`publicidades`). Ver `lib/features/advertisements/data/repositories/advertising_repository_impl.dart`
- [x] ~~Coupons~~: Implementado con Firestore (`cupones`) + cache local. Ver `lib/features/store/data/datasources/coupon_datasource_impl.dart`
- [x] ~~Video service~~: Métodos completados con `video_player` (duración, dimensiones). Ver `lib/features/experiences/data/datasources/video_experience_datasource.dart`. Nota: agregar `video_thumbnail` para captura de frames.
- [x] ~~Bike actions~~: Botones de UI conectados a `BikeProvider` real. Nuevo `MarkAsRecoveredUseCase`. Archivo stub eliminado.
