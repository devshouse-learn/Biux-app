import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Configuración real de Firebase para el proyecto
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Usando la configuración de Windows que es la más compatible para scripts
    return const FirebaseOptions(
      apiKey: 'AIzaSyAaRKxMumNd_R_j1eeKCmj4ZDK3YHZRm9c',
      appId: '1:1047544274797:web:c080e371872675a76dc464',
      messagingSenderId: '1047544274797',
      projectId: 'biux-1576614678644',
      authDomain: 'biux-1576614678644.firebaseapp.com',
      databaseURL: 'https://biux-1576614678644-default-rtdb.firebaseio.com',
      storageBucket: 'biux-1576614678644.appspot.com',
      measurementId: 'G-HPQ98V1426',
    );
  }
}

Future<void> resetAndInsertCities() async {
  try {
    // Inicializar Firebase
    print('🔥 Inicializando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente');

    final firestore = FirebaseFirestore.instance;
    final citiesRef = firestore.collection('cities');

    print('🗑️ Eliminando ciudades existentes...');

    // 1. Borrar todas las ciudades existentes
    final snapshot = await citiesRef.get();
    int deletedCount = 0;

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
      deletedCount++;
      print('   ❌ Eliminada: ${doc.data()['name'] ?? doc.id}');
    }

    print('✅ Ciudades eliminadas: $deletedCount');
    print('📍 Insertando nuevas ciudades...');

    // 2. Insertar las 10 principales capitales (Ibagué primero)
    final cities = [
      {'name': 'Ibagué', 'priority': 1},
      {'name': 'Bogotá', 'priority': 2},
      {'name': 'Medellín', 'priority': 3},
      {'name': 'Cali', 'priority': 4},
      {'name': 'Barranquilla', 'priority': 5},
      {'name': 'Cartagena', 'priority': 6},
      {'name': 'Bucaramanga', 'priority': 7},
      {'name': 'Pereira', 'priority': 8},
      {'name': 'Santa Marta', 'priority': 9},
      {'name': 'Manizales', 'priority': 10},
    ];

    int insertedCount = 0;
    for (final city in cities) {
      final docRef = await citiesRef.add(city);
      insertedCount++;
      print(
          '   ➕ Agregada: ${city['name']} (prioridad: ${city['priority']}) - ID: ${docRef.id}');
    }

    print('');
    print('🎉 ¡Script completado exitosamente!');
    print('📊 Resumen:');
    print('   - Ciudades eliminadas: $deletedCount');
    print('   - Ciudades insertadas: $insertedCount');
    print('   - Estado: ✅ ÉXITO');
    print('');
  } catch (e) {
    print('');
    print('❌ Error ejecutando el script: $e');
    print('🔍 Verifica:');
    print('   - Que el proyecto de Firebase esté configurado correctamente');
    print('   - Que tengas permisos de escritura en Firestore');
    print('   - Que la conexión a internet esté activa');
    print('');
    exit(1);
  }
}

void main() async {
  print('🚀 Iniciando script de configuración de ciudades...');
  print('📋 Este script va a:');
  print('   1. Eliminar todas las ciudades existentes en Firestore');
  print('   2. Insertar 10 capitales principales de Colombia');
  print('   3. Establecer Ibagué como primera prioridad');
  print('');

  await resetAndInsertCities();

  print('✨ Script finalizado. Presiona Enter para salir...');
  stdin.readLineSync();
}
