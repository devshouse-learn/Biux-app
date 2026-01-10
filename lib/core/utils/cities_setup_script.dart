import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

Future<void> resetAndInsertCities() async {
  // Inicializar Firebase si no está inicializado
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Ya está inicializado
  }

  final firestore = FirebaseFirestore.instance;
  final citiesRef = firestore.collection('cities');

  print('🗑️ Eliminando ciudades existentes...');

  // 1. Borrar todas las ciudades existentes
  final snapshot = await citiesRef.get();
  for (final doc in snapshot.docs) {
    await doc.reference.delete();
    print('   Eliminada: ${doc.data()['name'] ?? doc.id}');
  }

  print('✅ Ciudades eliminadas: ${snapshot.docs.length}');
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

  for (final city in cities) {
    await citiesRef.add(city);
    print('   ➕ Agregada: ${city['name']} (prioridad: ${city['priority']})');
  }

  print('✅ Ciudades actualizadas correctamente: ${cities.length} ciudades');
  print('🎉 Script completado exitosamente!');
}

// Para ejecutar directamente
void main() async {
  try {
    await resetAndInsertCities();
  } catch (e) {
    print('❌ Error: $e');
  }
}
