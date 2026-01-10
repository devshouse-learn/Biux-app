#!/usr/bin/env dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script para eliminar todos los productos de Firebase Firestore
/// 
/// USO:
/// dart scripts/delete_all_products.dart
/// 
/// NOTA: Requiere que Firebase esté configurado correctamente

void main() async {
  print('🗑️  ELIMINACIÓN DE PRODUCTOS - Biux App');
  print('=' * 50);
  print('');

  // Confirmación
  print('⚠️  ADVERTENCIA: Este script eliminará TODOS los productos de Firebase.');
  print('');
  stdout.write('¿Estás seguro de que deseas continuar? (escribe "SI" para confirmar): ');
  final confirmation = stdin.readLineSync();

  if (confirmation?.toUpperCase() != 'SI') {
    print('❌ Operación cancelada.');
    exit(0);
  }

  print('');
  print('🔄 Inicializando Firebase...');

  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyC8XzLfVqK7k7K8HwKvWl-C8gQZ2K2Z8qQ',
        appId: '1:576614678644:web:1234567890abcdef',
        messagingSenderId: '576614678644',
        projectId: 'biux-1576614678644',
        storageBucket: 'biux-1576614678644.appspot.com',
      ),
    );

    print('✅ Firebase inicializado');
    print('');

    final firestore = FirebaseFirestore.instance;
    final productsCollection = firestore.collection('products');

    // Obtener todos los productos
    print('📦 Obteniendo productos...');
    final snapshot = await productsCollection.get();
    final totalProducts = snapshot.docs.length;

    if (totalProducts == 0) {
      print('✅ No hay productos para eliminar.');
      exit(0);
    }

    print('📊 Productos encontrados: $totalProducts');
    print('');
    print('🗑️  Eliminando productos...');
    print('');

    // Eliminar productos en lotes de 500 (límite de Firestore)
    final batch = firestore.batch();
    int deletedCount = 0;

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
      deletedCount++;
      
      // Mostrar progreso cada 10 productos
      if (deletedCount % 10 == 0 || deletedCount == totalProducts) {
        stdout.write('\r🗑️  Eliminados: $deletedCount/$totalProducts');
      }

      // Ejecutar batch cada 500 operaciones (límite de Firestore)
      if (deletedCount % 500 == 0) {
        await batch.commit();
        print('\n   ✓ Lote de 500 productos eliminado');
      }
    }

    // Ejecutar el último batch si quedaron productos
    if (deletedCount % 500 != 0) {
      await batch.commit();
    }

    print('');
    print('');
    print('=' * 50);
    print('✅ OPERACIÓN COMPLETADA');
    print('=' * 50);
    print('📊 Total eliminados: $deletedCount productos');
    print('');

  } catch (e) {
    print('');
    print('❌ ERROR: $e');
    exit(1);
  }
}
