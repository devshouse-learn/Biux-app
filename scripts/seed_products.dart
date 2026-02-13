/// Script para crear productos de prueba en Firestore
///
/// CÓMO EJECUTAR:
/// 1. Asegúrate de tener Firebase configurado
/// 2. Ejecuta: dart run lib/scripts/seed_products.dart
///
/// ALTERNATIVA MANUAL:
/// Copia los productos de abajo y créalos manualmente en Firebase Console

import 'package:biux/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  print('🚀 Iniciando script de productos de prueba...\n');

  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado\n');

    final firestore = FirebaseFirestore.instance;
    final productosRef = firestore.collection('productos');

    // NOTA: Cambia este ID por el ID de tu usuario en Firestore
    const vendedorId = 'admin_biux_test_123'; // Usuario de prueba
    const vendedorNombre = 'Tienda Oficial Biux';

    if (vendedorId == 'TU_USER_ID_AQUI' ||
        vendedorId == 'admin_biux_test_123') {
      print('⚠️  Usando vendedorId de prueba: $vendedorId');
      print('   Si quieres usar tu propio ID, edita el script\n');
    }

    final productos = [
      // 1. Bicicleta de Montaña
      {
        'nombre': 'Bicicleta Trek X-Caliber 8',
        'descripcion':
            'Bicicleta de montaña profesional con cuadro de aluminio Alpha Silver, suspensión RockShox Judy Silver y frenos hidráulicos. Perfecta para trail y cross-country.',
        'precio': 25000.0,
        'descuento': 15.0,
        'categoria': 'bicicletas',
        'vendedorId': vendedorId,
        'vendedorNombre': vendedorNombre,
        'imagenes': [
          'https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?w=800',
          'https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?w=800',
        ],
        'stock': 5,
        'destacado': true,
        'activo': true,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'tags': ['mtb', 'trek', 'montaña', 'aluminio', 'rockshox'],
        'especificaciones': {
          'Material': 'Aluminio Alpha Silver',
          'Suspensión': 'RockShox Judy Silver 100mm',
          'Frenos': 'Hidráulicos Shimano MT200',
          'Cambios': 'Shimano Deore 12 velocidades',
          'Ruedas': '29 pulgadas',
          'Peso': '13.5 kg',
        },
      },

      // 2. Casco
      {
        'nombre': 'Casco POC Ventral Air SPIN',
        'descripcion':
            'Casco de carretera de alta gama con tecnología SPIN para mayor protección. Diseño aerodinámico con excelente ventilación.',
        'precio': 4500.0,
        'descuento': null,
        'categoria': 'proteccion',
        'vendedorId': vendedorId,
        'vendedorNombre': vendedorNombre,
        'imagenes': [
          'https://images.unsplash.com/photo-1519620149092-a0d3ce7446e1?w=800',
        ],
        'stock': 12,
        'destacado': true,
        'activo': true,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'tags': ['casco', 'poc', 'seguridad', 'aerodinámico'],
        'especificaciones': {
          'Tallas': 'S, M, L',
          'Peso': '250g',
          'Certificación': 'CE EN 1078',
          'Tecnología': 'SPIN',
          'Ventilación': '22 vents',
        },
      },

      // 3. Jersey de ciclismo
      {
        'nombre': 'Jersey Castelli Aero Race 6.0',
        'descripcion':
            'Jersey aerodinámico profesional con tejido Velocity Rev2. Corte race fit para máxima velocidad.',
        'precio': 2800.0,
        'descuento': 20.0,
        'categoria': 'ropa',
        'vendedorId': vendedorId,
        'vendedorNombre': vendedorNombre,
        'imagenes': [
          'https://images.unsplash.com/photo-1581888227599-779811939961?w=800',
        ],
        'stock': 8,
        'destacado': false,
        'activo': true,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'tags': ['jersey', 'castelli', 'ropa', 'aero'],
        'especificaciones': {
          'Material': 'Velocity Rev2',
          'Tallas': 'XS, S, M, L, XL',
          'Corte': 'Race Fit',
          'Bolsillos': '3 traseros',
          'Cremallera': 'YKK Vislon',
        },
      },

      // 4. Pedales
      {
        'nombre': 'Pedales Shimano PD-M8100 XT',
        'descripcion':
            'Pedales automáticos de MTB de alta gama. Plataforma amplia y fácil enganche/desenganche.',
        'precio': 1800.0,
        'descuento': null,
        'categoria': 'componentes',
        'vendedorId': vendedorId,
        'vendedorNombre': vendedorNombre,
        'imagenes': [
          'https://images.unsplash.com/photo-1576778969066-5b59fc37e885?w=800',
        ],
        'stock': 15,
        'destacado': false,
        'activo': true,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'tags': ['pedales', 'shimano', 'xt', 'mtb'],
        'especificaciones': {
          'Peso': '310g (par)',
          'Eje': 'Cromoly',
          'Plataforma': 'Amplia',
          'Tensión': 'Ajustable',
        },
      },

      // 5. Luces
      {
        'nombre': 'Luz Delantera Lezyne Mega Drive 1800',
        'descripcion':
            'Luz delantera ultra potente de 1800 lúmenes. Recargable vía USB-C. Ideal para ciclismo nocturno.',
        'precio': 1500.0,
        'descuento': 10.0,
        'categoria': 'electronica',
        'vendedorId': vendedorId,
        'vendedorNombre': vendedorNombre,
        'imagenes': [
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
        ],
        'stock': 20,
        'destacado': true,
        'activo': true,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'tags': ['luz', 'lezyne', 'seguridad', 'nocturno'],
        'especificaciones': {
          'Lumens': '1800',
          'Batería': 'Li-ion recargable',
          'Autonomía': 'Hasta 50 horas',
          'Carga': 'USB-C',
          'Modos': '8',
        },
      },

      // 6. Botella
      {
        'nombre': 'Botella Elite Fly 750ml',
        'descripcion':
            'Botella ultraligera y ergonómica. Material biodegradable sin BPA.',
        'precio': 250.0,
        'descuento': null,
        'categoria': 'accesorios',
        'vendedorId': vendedorId,
        'vendedorNombre': vendedorNombre,
        'imagenes': [
          'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=800',
        ],
        'stock': 50,
        'destacado': false,
        'activo': true,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'tags': ['botella', 'elite', 'hidratación'],
        'especificaciones': {
          'Capacidad': '750ml',
          'Peso': '54g',
          'Material': 'Polipropileno biodegradable',
          'Sin BPA': 'Sí',
        },
      },

      // 7. Gel energético
      {
        'nombre': 'Gel SIS GO Isotonic (Pack 6)',
        'descripcion':
            'Pack de 6 geles isotónicos para energía rápida durante el ejercicio. Sabor frutas tropicales.',
        'precio': 180.0,
        'descuento': null,
        'categoria': 'nutricion',
        'vendedorId': vendedorId,
        'vendedorNombre': vendedorNombre,
        'imagenes': [
          'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=800',
        ],
        'stock': 100,
        'destacado': false,
        'activo': true,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'tags': ['gel', 'nutrición', 'energía', 'sis'],
        'especificaciones': {
          'Contenido': '6 geles x 60ml',
          'Calorías': '87 kcal por gel',
          'Carbohidratos': '22g',
          'Sabor': 'Frutas Tropicales',
        },
      },

      // 8. Multiherramienta
      {
        'nombre': 'Multiherramienta Topeak Mini 20 Pro',
        'descripcion':
            'Herramienta compacta con 20 funciones. Incluye llaves Allen, destornilladores y tronchacadenas.',
        'precio': 650.0,
        'descuento': null,
        'categoria': 'herramientas',
        'vendedorId': vendedorId,
        'vendedorNombre': vendedorNombre,
        'imagenes': [
          'https://images.unsplash.com/photo-1530435460869-d13625c69bbf?w=800',
        ],
        'stock': 25,
        'destacado': false,
        'activo': true,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'tags': ['herramienta', 'topeak', 'reparación'],
        'especificaciones': {
          'Funciones': '20',
          'Peso': '120g',
          'Incluye': 'Llaves Allen 2-8mm, destornilladores, tronchacadenas',
          'Material': 'Acero inoxidable',
        },
      },
    ];

    print('📦 Creando ${productos.length} productos de prueba...\n');

    int count = 0;
    for (var producto in productos) {
      await productosRef.add(producto);
      count++;
      print('✅ Producto $count/${productos.length}: ${producto['nombre']}');
    }

    print('\n🎉 ¡Productos creados exitosamente!');
    print('📊 Total: $count productos');
    print('\n💡 Ahora puedes:');
    print('   1. Abrir la app en Chrome');
    print('   2. Navegar a /store');
    print('   3. Ver los productos en la tienda');
  } catch (e) {
    print('\n❌ Error: $e');
    print('\n💡 Si el error persiste:');
    print('   1. Verifica que Firebase esté configurado');
    print('   2. Crea los productos manualmente en Firebase Console');
    print('   3. Usa los JSON de abajo como referencia\n');
  }
}
