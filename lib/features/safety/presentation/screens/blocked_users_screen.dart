import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/safety/presentation/providers/safety_provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      context.read<SafetyProvider>().loadBlockedUsers(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(l.t('blocked_users')),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SafetyProvider>(
        builder: (context, safetyProvider, _) {
          if (safetyProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: ColorTokens.primary30),
            );
          }

          final blocked = safetyProvider.blockedUsers;

          if (blocked.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block, size: 64, color: Colors.grey.shade400),
                  SizedBox(height: 16),
                  Text(
                    l.t('no_blocked_users'),
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: blocked.length,
            itemBuilder: (context, index) {
              final blockedId = blocked[index];
              return _BlockedUserTile(
                blockedUserId: blockedId,
                isDark: isDark,
                onUnblock: () => _confirmUnblock(blockedId),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmUnblock(String blockedId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('unblock_user_title')),
        content: Text(l.t('unblock_user_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.t('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
              await context.read<SafetyProvider>().unblockUser(uid, blockedId);
            },
            child: Text(l.t('unblock')),
          ),
        ],
      ),
    );
  }
}

class _BlockedUserTile extends StatelessWidget {
  final String blockedUserId;
  final bool isDark;
  final VoidCallback onUnblock;

  const _BlockedUserTile({
    required this.blockedUserId,
    required this.isDark,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(blockedUserId)
          .get(),
      builder: (context, snapshot) {
        String name = l.t('user_default');
        String? photoUrl;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            name = data['username'] ?? data['name'] ?? l.t('user_default');
            photoUrl = data['profileImageUrl'] ?? data['photoUrl'];
          }
        }

        return Card(
          color: isDark ? const Color(0xFF1A2B3C) : Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
              backgroundColor: Colors.grey.shade400,
            ),
            title: Text(
              name,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: TextButton(
              onPressed: onUnblock,
              child: Text(
                l.t('unblock'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        );
      },
    );
  }
}
