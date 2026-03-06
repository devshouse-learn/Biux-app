
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({Key? key}) : super(key: key);
  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;
  String _query = '';
  bool _isSearching = false;

  // Results
  List<DocumentSnapshot> _userResults = [];
  List<DocumentSnapshot> _groupResults = [];
  List<DocumentSnapshot> _rideResults = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _userResults = [];
        _groupResults = [];
        _rideResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final fs = FirebaseFirestore.instance;
      final q = query.trim();

      // Buscar usuarios
      final usersSnap = await fs.collection('users')
          .where('name', isGreaterThanOrEqualTo: q)
          .where('name', isLessThanOrEqualTo: '$q\uf8ff')
          .limit(15).get();

      // Buscar grupos
      final groupsSnap = await fs.collection('groups')
          .where('name', isGreaterThanOrEqualTo: q)
          .where('name', isLessThanOrEqualTo: '$q\uf8ff')
          .limit(15).get();

      // Buscar rodadas
      final ridesSnap = await fs.collection('rides')
          .where('title', isGreaterThanOrEqualTo: q)
          .where('title', isLessThanOrEqualTo: '$q\uf8ff')
          .limit(15).get();

      if (mounted) {
        setState(() {
          _userResults = usersSnap.docs;
          _groupResults = groupsSnap.docs;
          _rideResults = ridesSnap.docs;
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('Error searching: $e');
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.neutral99,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Buscar usuarios, grupos, rodadas...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            border: InputBorder.none,
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70, size: 20),
                    onPressed: () {
                      _searchCtrl.clear();
                      _search('');
                    },
                  )
                : null,
          ),
          onChanged: (v) {
            setState(() => _query = v);
            _search(v);
          },
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Usuarios (${_userResults.length})'),
            Tab(text: 'Grupos (${_groupResults.length})'),
            Tab(text: 'Rodadas (${_rideResults.length})'),
          ],
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _query.trim().length < 2
              ? _buildEmptySearch()
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildUserResults(),
                    _buildGroupResults(),
                    _buildRideResults(),
                  ],
                ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Busca en BiUX', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Escribe al menos 2 caracteres', style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 32),
          // Sugerencias rápidas
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: ['Rodadas MTB', 'Grupos Bogotá', 'Ciclismo urbano', 'Ruta nocturna'].map((s) =>
              ActionChip(
                label: Text(s, style: const TextStyle(fontSize: 13)),
                avatar: const Icon(Icons.trending_up, size: 16),
                onPressed: () {
                  _searchCtrl.text = s;
                  _search(s);
                },
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserResults() {
    if (_userResults.isEmpty) return _buildNoResults('usuarios');
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _userResults.length,
      itemBuilder: (ctx, i) {
        final data = _userResults[i].data() as Map<String, dynamic>;
        final name = data['name'] as String? ?? 'Ciclista';
        final photo = data['photoUrl'] as String? ?? '';
        final userName = data['userName'] as String? ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: ColorTokens.primary30.withValues(alpha: 0.1),
              backgroundImage: photo.isNotEmpty ? CachedNetworkImageProvider(photo) : null,
              child: photo.isEmpty ? const Icon(Icons.person, color: ColorTokens.primary30) : null,
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: userName.isNotEmpty ? Text('@$userName', style: TextStyle(color: Colors.grey[500], fontSize: 13)) : null,
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => context.push('/user-profile/${_userResults[i].id}'),
          ),
        );
      },
    );
  }

  Widget _buildGroupResults() {
    if (_groupResults.isEmpty) return _buildNoResults('grupos');
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _groupResults.length,
      itemBuilder: (ctx, i) {
        final data = _groupResults[i].data() as Map<String, dynamic>;
        final name = data['name'] as String? ?? 'Grupo';
        final city = data['city'] as String? ?? '';
        final logo = data['logoUrl'] as String? ?? '';
        final memberCount = (data['memberCount'] as num?)?.toInt() ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              backgroundImage: logo.isNotEmpty ? CachedNetworkImageProvider(logo) : null,
              child: logo.isEmpty ? const Icon(Icons.group, color: Colors.blue) : null,
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${city.isNotEmpty ? "$city • " : ""}$memberCount miembros', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => context.push('/groups/${_groupResults[i].id}'),
          ),
        );
      },
    );
  }

  Widget _buildRideResults() {
    if (_rideResults.isEmpty) return _buildNoResults('rodadas');
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _rideResults.length,
      itemBuilder: (ctx, i) {
        final data = _rideResults[i].data() as Map<String, dynamic>;
        final title = data['title'] as String? ?? 'Rodada';
        final date = data['date'] as Timestamp?;
        final difficulty = data['difficulty'] as String? ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              child: const Icon(Icons.directions_bike, color: Colors.green),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${date != null ? "${date.toDate().day}/${date.toDate().month}/${date.toDate().year}" : ""}${difficulty.isNotEmpty ? " • $difficulty" : ""}',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => context.push('/rides/${_rideResults[i].id}'),
          ),
        );
      },
    );
  }

  Widget _buildNoResults(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('No se encontraron $type', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          Text('para "$_query"', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
    );
  }
}
