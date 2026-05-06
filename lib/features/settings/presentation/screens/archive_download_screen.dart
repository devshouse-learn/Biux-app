import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/theme_notifier.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class ArchiveDownloadScreen extends StatefulWidget {
  const ArchiveDownloadScreen({super.key});

  @override
  State<ArchiveDownloadScreen> createState() => _ArchiveDownloadScreenState();
}

class _ArchiveDownloadScreenState extends State<ArchiveDownloadScreen> {
  bool _saveStories = false;
  bool _savePosts = false;

  @override
  void initState() {
    super.initState();
    _loadSavePreferences();
  }

  Future<void> _loadSavePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _saveStories = prefs.getBool('save_stories_to_phone') ?? false;
        _savePosts = prefs.getBool('save_posts_to_phone') ?? false;
      });
    }
  }

  Future<void> _toggleSaveStories(bool value) async {
    setState(() => _saveStories = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('save_stories_to_phone', value);
  }

  Future<void> _toggleSavePosts(bool value) async {
    setState(() => _savePosts = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('save_posts_to_phone', value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeNotifier>(context).isDark;
    final l = Provider.of<LocaleNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('archive_download')),
        backgroundColor: const Color(0xFF16242D),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l.t('save_to_phone'),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.t('save_to_phone_subtitle'),
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: const EdgeInsets.only(left: 4),
            title: Text(
              l.t('save_stories'),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              l.t('save_stories_subtitle'),
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            value: _saveStories,
            activeThumbColor: ColorTokens.primary30,
            onChanged: _toggleSaveStories,
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.only(left: 4),
            title: Text(
              l.t('save_posts'),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              l.t('save_posts_subtitle'),
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            value: _savePosts,
            activeThumbColor: ColorTokens.primary30,
            onChanged: _toggleSavePosts,
          ),
        ],
      ),
    );
  }
}
