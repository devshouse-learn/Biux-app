import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/shop/presentation/providers/seller_request_provider.dart';

/// Diálogo para solicitar permiso para vender productos
class RequestSellerPermissionDialog extends StatefulWidget {
  const RequestSellerPermissionDialog({super.key});

  @override
  State<RequestSellerPermissionDialog> createState() =>
      _RequestSellerPermissionDialogState();
}

class _RequestSellerPermissionDialogState
    extends State<RequestSellerPermissionDialog> {
  late final TextEditingController _messageController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    _messageController = TextEditingController(
      text: l.t('default_seller_request_message'),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('please_write_message')),
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
          SnackBar(
            content: Text(l.t('user_not_found')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final success = await requestProvider.createRequest(
      userId: currentUser.uid,
      userName: currentUser.username ?? currentUser.name ?? l.t('no_name'),
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
                ? '✅ ${l.t('request_sent_success')}'
                : '❌ ${l.t('request_error')}',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.store, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(child: Text(l.t('request_sell_permission'))),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.t('sell_auth_needed'), style: TextStyle(fontSize: 14)),
            SizedBox(height: 16),
            Text(
              l.t('tell_us_why_sell'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: l.t('write_message_hint'),
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
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.t('admin_will_review'),
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
          child: Text(l.t('cancel')),
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
              : Icon(Icons.send),
          label: Text(_isLoading ? l.t('sending') : l.t('send_request')),
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
