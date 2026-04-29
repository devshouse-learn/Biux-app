import 'package:flutter/material.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:provider/provider.dart';

class PollResult {
  final String question;
  final List<String> options;
  final bool allowMultiple;

  PollResult({
    required this.question,
    required this.options,
    required this.allowMultiple,
  });
}

class PollCreationSheet extends StatefulWidget {
  const PollCreationSheet({super.key});

  @override
  State<PollCreationSheet> createState() => _PollCreationSheetState();
}

class _PollCreationSheetState extends State<PollCreationSheet> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _allowMultiple = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length >= 10) return;
    setState(() => _optionControllers.add(TextEditingController()));
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return;
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  void _submit() {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('write_question'))));
      return;
    }
    final options = _optionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (options.length < 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('add_at_least_2_options'))));
      return;
    }
    Navigator.pop(
      context,
      PollResult(
        question: question,
        options: options,
        allowMultiple: _allowMultiple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Text(
                l.t('create_poll'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16),

              // Question
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  hintText: l.t('write_your_question'),
                  prefixIcon: const Icon(Icons.help_outline, size: 20),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 8),

              // Options label
              Text(
                l.t('options_section'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Option fields
              ..._optionControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: '${l.t('option_n')} ${index + 1}',
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          maxLength: 100,
                          buildCounter:
                              (
                                _, {
                                required currentLength,
                                required isFocused,
                                maxLength,
                              }) => null,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      if (_optionControllers.length > 2)
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                            size: 22,
                          ),
                          onPressed: () => _removeOption(index),
                        ),
                    ],
                  ),
                );
              }),

              // Add option button
              if (_optionControllers.length < 10)
                TextButton.icon(
                  onPressed: _addOption,
                  icon: Icon(Icons.add_circle_outline, size: 20),
                  label: Text(l.t('add_option')),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1E8BC3),
                  ),
                ),

              const SizedBox(height: 8),

              // Allow multiple votes
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l.t('allow_multiple_votes'),
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  l.t('participants_choose_multiple'),
                  style: const TextStyle(fontSize: 12),
                ),
                value: _allowMultiple,
                activeThumbColor: const Color(0xFF4CAF50),
                onChanged: (v) => setState(() => _allowMultiple = v),
              ),

              const SizedBox(height: 12),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E8BC3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 20),
                  label: Text(
                    l.t('send_poll'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
