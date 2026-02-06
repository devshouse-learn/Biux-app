import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/promotion_request_model.dart';
import '../providers/promotions_provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({Key? key}) : super(key: key);

  void _openRequestDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String type = 'anuncio';
    DateTime? eventDate;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Solicitar publicación'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 3),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: 'anuncio', child: Text('Anuncio')),
                  DropdownMenuItem(value: 'evento', child: Text('Evento')),
                ],
                onChanged: (v) => type = v ?? 'anuncio',
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              if (type == 'evento') ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) eventDate = d;
                  },
                  child: const Text('Seleccionar fecha del evento'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (title.isEmpty || desc.isEmpty) return;
              final req = PromotionRequestModel(title: title, description: desc, type: type, eventDate: eventDate);
              context.read<PromotionsProvider>().addRequest(req);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud enviada a los admins')));
            },
            child: const Text('Enviar solicitud'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promociones de la comunidad'),
        backgroundColor: ColorTokens.primary30,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop(); else context.go('/stories');
          },
        ),
      ),
      body: Consumer<PromotionsProvider>(
        builder: (context, provider, child) {
          final items = provider.requests;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                color: Colors.yellow[50],
                child: ListTile(
                  title: const Text('¿Quieres promocionar tu anuncio o evento?'),
                  subtitle: const Text('Envía una solicitud y los admins la revisarán.'),
                  trailing: ElevatedButton(onPressed: () => _openRequestDialog(context), child: const Text('Solicitar')),
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty) ...[
                Center(child: Text('No hay promociones publicadas.', style: TextStyle(color: Colors.grey[600]))),
              ] else ...items.map((r) => Card(
                child: ListTile(
                  title: Text(r.title),
                  subtitle: Text('${r.type.toUpperCase()} • ${r.description}\nEstado: ${r.status}'),
                  isThreeLine: true,
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}
