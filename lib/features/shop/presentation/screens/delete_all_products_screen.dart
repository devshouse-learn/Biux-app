import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

/// Pantalla administrativa para limpiar todos los productos
/// Solo accesible por administradores
class DeleteAllProductsScreen extends StatefulWidget {
  const DeleteAllProductsScreen({Key? key}) : super(key: key);

  @override
  State<DeleteAllProductsScreen> createState() =>
      _DeleteAllProductsScreenState();
}

class _DeleteAllProductsScreenState extends State<DeleteAllProductsScreen> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

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

      if (!mounted) return;
      final l = Provider.of<LocaleNotifier>(context, listen: false);
      setState(() {
        _totalProducts = snapshot.docs.length;
        _status =
            '${l.t('there_are')} $_totalProducts ${l.t('products_in_database')}';
      });
    } catch (e) {
      if (!mounted) return;
      final l = Provider.of<LocaleNotifier>(context, listen: false);
      setState(() {
        _status = '${l.t('error_counting_products')}: $e';
      });
    }
  }

  Future<void> _deleteAllProducts() async {
    final messenger = ScaffoldMessenger.of(context);
    // Confirmación
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ ${l.t('confirm_deletion')}'),
        content: Text(
          '${l.t('delete_all_confirm')}\n\n'
          '${l.t('action_irreversible')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l.t('delete_all')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
      _deletedProducts = 0;
      _status = l.t('starting_deletion');
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
          _status =
              '${l.t('deleting_progress')} $_deletedProducts/$_totalProducts';
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
        _status = '✅ $_deletedProducts ${l.t('products_deleted_successfully')}';
        _totalProducts = 0;
      });

      // Mostrar mensaje de éxito
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('✅ $_deletedProducts ${l.t('products_eliminated')}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
        _status = '❌ ${l.t('error')}: $e';
      });

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('${l.t('error')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/shop'),
          tooltip: l.t('back_to_store'),
        ),
        title: Text(l.t('delete_all_products_title')),
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
            SizedBox(height: 24),

            // Título
            Text(
              '⚠️ ${l.t('danger_zone')}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // Descripción
            Text(
              l.t('danger_zone_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
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
              icon: Icon(Icons.refresh),
              label: Text(l.t('refresh_count')),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 16),

            // Botón de eliminar
            ElevatedButton.icon(
              onPressed: (_isDeleting || _totalProducts == 0)
                  ? null
                  : _deleteAllProducts,
              icon: Icon(Icons.delete_forever),
              label: Text(
                _totalProducts > 0
                    ? '${l.t('delete')} $_totalProducts ${l.t('products_label')}'
                    : l.t('no_products_to_delete'),
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
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '⚠️ ${l.t('action_irreversible')}',
                      style: const TextStyle(
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
