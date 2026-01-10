import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Pantalla administrativa para limpiar todos los productos
/// Solo accesible por administradores
class DeleteAllProductsScreen extends StatefulWidget {
  const DeleteAllProductsScreen({Key? key}) : super(key: key);

  @override
  State<DeleteAllProductsScreen> createState() =>
      _DeleteAllProductsScreenState();
}

class _DeleteAllProductsScreenState extends State<DeleteAllProductsScreen> {
  bool _isDeleting = false;
  int _totalProducts = 0;
  int _deletedProducts = 0;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _countProducts();
  }

  Future<void> _countProducts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      setState(() {
        _totalProducts = snapshot.docs.length;
        _status = 'Hay $_totalProducts productos en la base de datos';
      });
    } catch (e) {
      setState(() {
        _status = 'Error al contar productos: $e';
      });
    }
  }

  Future<void> _deleteAllProducts() async {
    // Confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar TODOS los $_totalProducts productos?\n\n'
          'Esta acción NO se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar Todo'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
      _deletedProducts = 0;
      _status = 'Iniciando eliminación...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('products').get();

      // Eliminar en lotes de 500 (límite de Firestore)
      final batch = firestore.batch();
      int count = 0;

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
        count++;

        setState(() {
          _deletedProducts = count;
          _status = 'Eliminando... $_deletedProducts/$_totalProducts';
        });

        // Ejecutar batch cada 500 productos
        if (count % 500 == 0) {
          await batch.commit();
        }
      }

      // Ejecutar el último batch
      if (count % 500 != 0) {
        await batch.commit();
      }

      setState(() {
        _isDeleting = false;
        _status = '✅ Eliminados $_deletedProducts productos exitosamente';
        _totalProducts = 0;
      });

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $_deletedProducts productos eliminados'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
        _status = '❌ Error: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eliminar Todos los Productos'),
        backgroundColor: ColorTokens.primary30,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icono de advertencia
            const Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),

            // Título
            const Text(
              '⚠️ ZONA PELIGROSA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Descripción
            const Text(
              'Esta acción eliminará TODOS los productos de la base de datos de Firebase. '
              'Solo úsala si estás seguro de que quieres limpiar todos los productos de prueba.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Estado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isDeleting) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _totalProducts > 0
                          ? _deletedProducts / _totalProducts
                          : 0,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        ColorTokens.secondary50,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botón de actualizar conteo
            OutlinedButton.icon(
              onPressed: _isDeleting ? null : _countProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar Conteo'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Botón de eliminar
            ElevatedButton.icon(
              onPressed: (_isDeleting || _totalProducts == 0)
                  ? null
                  : _deleteAllProducts,
              icon: const Icon(Icons.delete_forever),
              label: Text(
                _totalProducts > 0
                    ? 'Eliminar $_totalProducts Productos'
                    : 'No hay productos para eliminar',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Advertencia final
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '⚠️ Esta acción NO se puede deshacer',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
