import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../users/presentation/providers/user_provider.dart';
import '../providers/seller_request_provider.dart';

/// Diálogo para solicitar permiso para vender productos
class RequestSellerPermissionDialog extends StatefulWidget {
  const RequestSellerPermissionDialog({super.key});

  @override
  State<RequestSellerPermissionDialog> createState() =>
      _RequestSellerPermissionDialogState();
}

class _RequestSellerPermissionDialogState
    extends State<RequestSellerPermissionDialog> {
  final _messageController = TextEditingController(
    text:
        'Me gustaría vender productos en la tienda de Biux. '
        'Tengo experiencia en ciclismo y productos de calidad para ofrecer.',
  );
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escribe un mensaje'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();
    final requestProvider = context.read<SellerRequestProvider>();
    final currentUser = userProvider.user;

    if (currentUser == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Usuario no encontrado'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final success = await requestProvider.createRequest(
      userId: currentUser.uid,
      userName: currentUser.username ?? currentUser.name ?? 'Sin nombre',
      userPhoto: currentUser.photoUrl ?? '',
      userEmail: currentUser.email ?? '',
      message: _messageController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Solicitud enviada. Un administrador la revisará pronto.'
                : '❌ Error al enviar la solicitud. Intenta de nuevo.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.store, color: Colors.blue),
          const SizedBox(width: 8),
          const Expanded(child: Text('Solicitar Permiso para Vender')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para vender productos en la tienda de Biux, necesitas autorización de un administrador.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cuéntanos por qué quieres vender:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje aquí...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Un administrador revisará tu solicitud y te notificará.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _submitRequest,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send),
          label: Text(_isLoading ? 'Enviando...' : 'Enviar Solicitud'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Muestra el diálogo de solicitud de permiso para vender
Future<void> showRequestSellerPermissionDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => const RequestSellerPermissionDialog(),
  );
}
