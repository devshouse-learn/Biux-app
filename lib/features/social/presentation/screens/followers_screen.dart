import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class FollowersScreen extends StatefulWidget {
  final String userId;
  final bool showFollowers; // true = followers, false = following

  const FollowersScreen({
    Key? key,
    required this.userId,
    this.showFollowers = true,
  }) : super(key: key);
  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.showFollowers ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        title: Text(l.t('connections_title')),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: l.t('followers_tab')),
            Tab(text: l.t('following_tab')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildUserList('followers', l),
          _buildUserList('following', l),
        ],
      ),
    );
  }

  Widget _buildUserList(String collection, LocaleNotifier l) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection(collection)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  collection == 'followers'
                      ? Icons.people_outline
                      : Icons.person_add_alt,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  collection == 'followers'
                      ? l.t('no_followers_yet')
                      : l.t('not_following_anyone'),
                  style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: snap.data!.docs.length,
          itemBuilder: (ctx, i) {
            final uid = snap.data!.docs[i].id;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get(),
              builder: (ctx, userSnap) {
                if (!userSnap.hasData) return const SizedBox(height: 64);
                final data =
                    userSnap.data!.data() as Map<String, dynamic>? ?? {};
                final name =
                    data['name'] as String? ?? l.t('cyclist_default_name');
                final photo = data['photoUrl'] as String? ?? '';
                final userName = data['userName'] as String? ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: ColorTokens.primary30.withValues(
                        alpha: 0.1,
                      ),
                      backgroundImage: photo.isNotEmpty
                          ? CachedNetworkImageProvider(photo)
                          : null,
                      child: photo.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: ColorTokens.primary30,
                            )
                          : null,
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: userName.isNotEmpty
                        ? Text(
                            '@$userName',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          )
                        : null,
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => context.push('/user-profile/$uid'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
