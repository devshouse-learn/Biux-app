import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/settings/presentation/widgets/settings_shared_widgets.dart';

class PrivacyDetailsScreen extends StatefulWidget {
  const PrivacyDetailsScreen({super.key});

  @override
  State<PrivacyDetailsScreen> createState() => _PrivacyDetailsScreenState();
}

class _PrivacyDetailsScreenState extends State<PrivacyDetailsScreen>
    with WidgetsBindingObserver {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  String _profileVisibilityKey = 'public';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Recargar permisos cuando el usuario vuelve de la configuración del sistema
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPermissions();
    }
  }

  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileVisibilityKey =
          prefs.getString('profile_visibility_key') ?? 'public';
    });
  }

  Future<void> _saveProfileVisibility(String visibilityKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_visibility_key', visibilityKey);
    setState(() => _profileVisibilityKey = visibilityKey);

    // Guardar también en Firestore para que otros usuarios puedan verlo
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileVisibility': visibilityKey,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = Provider.of<LocaleNotifier>(context);

    return Scaffold(
      backgroundColor: SettingsWidgets.scaffoldBackground(isDark),
      appBar: SettingsWidgets.buildAppBar(context, l.t('privacy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsWidgets.buildSectionTitle(l.t('privacy_control'), isDark),
          SizedBox(height: 12),
          SettingsWidgets.buildOptionCard(
            context: context,
            icon: Icons.visibility,
            title: l.t('who_can_see_profile'),
            subtitle: '${l.t('current')}: ${l.t(_profileVisibilityKey)}',
            isDark: isDark,
            onTap: () => _showProfileVisibilityDialog(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showProfileVisibilityDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = context.read<LocaleNotifier>();
    final optionKeys = ['public', 'private'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? ColorTokens.primary30 : Colors.white,
        title: Text(
          l.t('who_can_see_profile'),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: optionKeys.map((key) {
            final isSelected = _profileVisibilityKey == key;
            return ListTile(
              title: Text(
                l.t(key),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                l.t('${key}_desc'),
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              leading: isSelected
                  ? const Icon(Icons.check_circle, color: ColorTokens.primary30)
                  : Icon(
                      Icons.circle_outlined,
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
              onTap: () {
                _saveProfileVisibility(key);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
