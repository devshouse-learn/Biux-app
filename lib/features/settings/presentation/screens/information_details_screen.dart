import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/design_system/locale_notifier.dart';
import '../widgets/settings_shared_widgets.dart';

class InformationDetailsScreen extends StatelessWidget {
  const InformationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = Provider.of<LocaleNotifier>(context);

    return Scaffold(
      backgroundColor: SettingsWidgets.scaffoldBackground(isDark),
      appBar: SettingsWidgets.buildAppBar(context, l.t('information')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsWidgets.buildSectionTitle(l.t('about_app'), isDark),
          const SizedBox(height: 12),
          SettingsWidgets.buildOptionCard(
            context: context,
            icon: Icons.info_outline,
            title: l.t('app_version'),
            subtitle: 'v1.0.0',
            isDark: isDark,
            onTap: () {},
          ),
          const SizedBox(height: 24),
          SettingsWidgets.buildSectionTitle(l.t('legal_policies'), isDark),
          const SizedBox(height: 12),
          SettingsWidgets.buildOptionCard(
            context: context,
            icon: Icons.description,
            title: l.t('terms_conditions'),
            subtitle: l.t('terms_subtitle'),
            isDark: isDark,
            onTap: () => _showTermsDialog(context, isDark, l),
          ),
          const SizedBox(height: 24),
          SettingsWidgets.buildSectionTitle(l.t('support'), isDark),
          const SizedBox(height: 12),
          SettingsWidgets.buildOptionCard(
            context: context,
            icon: Icons.support_agent,
            title: l.t('tech_support'),
            subtitle: l.t('tech_support_subtitle'),
            isDark: isDark,
            onTap: () => _showSupportDialog(context, isDark, l),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context, bool isDark, LocaleNotifier l) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF16242D) : Colors.white,
        title: Text(
          l.t('terms_conditions'),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Text(
            l.t('terms_content'),
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('understood')),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context, bool isDark, LocaleNotifier l) {
    final emailController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF16242D) : Colors.white,
        title: Text(
          l.t('tech_support'),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.t('tell_us_problem'),
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: l.t('your_email'),
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l.t('describe_problem'),
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('cancel')),
          ),
          TextButton(
            onPressed: () {
              if (emailController.text.isNotEmpty &&
                  messageController.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.t('ticket_sent')),
                    backgroundColor: Colors.green.shade600,
                  ),
                );
                Navigator.pop(context);
                emailController.clear();
                messageController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.t('fill_all_fields')),
                    backgroundColor: Colors.red.shade600,
                  ),
                );
              }
            },
            child: Text(l.t('send')),
          ),
        ],
      ),
    );
  }
}
