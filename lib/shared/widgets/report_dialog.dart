import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/social/data/datasources/report_datasource.dart';

class ReportDialog extends StatefulWidget {
  final String reporterId;
  final String reportedUserId;
  final String contentId;
  final String contentType;

  const ReportDialog({
    Key? key,
    required this.reporterId,
    required this.reportedUserId,
    required this.contentId,
    required this.contentType,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String reporterId,
    required String reportedUserId,
    required String contentId,
    required String contentType,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ReportDialog(
        reporterId: reporterId,
        reportedUserId: reportedUserId,
        contentId: contentId,
        contentType: contentType,
      ),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _reason;
  final _detailsCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reason == null) return;
    setState(() => _submitting = true);
    try {
      await ReportDatasource().reportContent(
        reporterId: widget.reporterId,
        reportedUserId: widget.reportedUserId,
        contentId: widget.contentId,
        type: widget.contentType,
        reason: _reason!,
        details: _detailsCtrl.text.trim().isEmpty
            ? null
            : _detailsCtrl.text.trim(),
      );
      if (!mounted) return;
      final l = Provider.of<LocaleNotifier>(context, listen: false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('report_sent_review')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final l = Provider.of<LocaleNotifier>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l.t('error_generic')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final reasons = [
      l.t('report_reason_inappropriate'),
      l.t('report_reason_spam'),
      l.t('report_reason_harassment'),
      l.t('report_reason_false_info'),
      l.t('report_reason_impersonation'),
      l.t('report_reason_violence'),
      l.t('report_reason_illegal_sales'),
      l.t('report_reason_other'),
    ];
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(
                l.t('report_content_title'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.t('report_reason_question'),
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...reasons.map(
            (r) => ListTile(
              title: Text(r, style: const TextStyle(fontSize: 14)),
              leading: Icon(
                _reason == r
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: _reason == r ? ColorTokens.primary30 : Colors.grey,
                size: 20,
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              onTap: () => setState(() => _reason = r),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _detailsCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l.t('report_additional_details'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _reason != null && !_submitting ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l.t('report_submit'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
