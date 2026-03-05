import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import '../../data/models/promotion_request_model.dart';
import '../providers/promotions_provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({Key? key}) : super(key: key);

  void _openRequestDialog(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String type = 'anuncio';
    DateTime? eventDate;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('request_publication')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: l.t('title_label')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: l.t('description_label'),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: type,
                items: [
                  DropdownMenuItem(
                    value: 'anuncio',
                    child: Text(l.t('announcement')),
                  ),
                  DropdownMenuItem(
                    value: 'evento',
                    child: Text(l.t('event_label')),
                  ),
                ],
                onChanged: (v) => type = v ?? 'anuncio',
                decoration: InputDecoration(labelText: l.t('type_label')),
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
                  child: Text(l.t('select_event_date')),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (title.isEmpty || desc.isEmpty) return;
              final req = PromotionRequestModel(
                title: title,
                description: desc,
                type: type,
                eventDate: eventDate,
              );
              context.read<PromotionsProvider>().addRequest(req);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.t('request_sent_admins'))),
              );
            },
            child: Text(l.t('send_request')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('community_promotions')),
        backgroundColor: ColorTokens.primary30,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<PromotionsProvider>(
        builder: (context, provider, child) {
          final items = provider.requests;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                color: Colors.grey[600],
                child: ListTile(
                  title: Text(
                    l.t('promote_question'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    l.t('promote_subtitle'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _openRequestDialog(context),
                    child: Text(
                      l.t('request_button'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty) ...[
                Center(
                  child: Text(
                    l.t('no_promotions_published'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ] else
                ...items.map(
                  (r) => Card(
                    child: ListTile(
                      title: Text(r.title),
                      subtitle: Text(
                        '${r.type.toUpperCase()} • ${r.description}\n${l.t('status_label')}: ${r.status}',
                      ),
                      isThreeLine: true,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
