import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import '../../domain/entities/ride_recommendation_entity.dart';
import '../providers/ride_recommendation_provider.dart';

class MyRecommendationsScreen extends StatefulWidget {
  const MyRecommendationsScreen({super.key});

  @override
  State<MyRecommendationsScreen> createState() => _MyRecommendationsScreenState();
}

class _MyRecommendationsScreenState extends State<MyRecommendationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideRecommendationProvider>().loadRecommendations();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        title: const Text('Recomendaciones',
          style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: ColorTokens.primary30,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Recibidas'),
            Tab(text: 'Enviadas'),
          ],
        ),
      ),
      body: Consumer<RideRecommendationProvider>(
        builder: (context, prov, _) {
          if (prov.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabs,
            children: [
              _buildList(prov.received, isReceived: true, prov: prov),
              _buildList(prov.sent, isReceived: false, prov: prov),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(
    List<RideRecommendationEntity> list, {
    required bool isReceived,
    required RideRecommendationProvider prov,
  }) {
    if (list.isEmpty) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.route_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            isReceived
              ? 'Sin recomendaciones recibidas'
              : 'No has enviado recomendaciones',
            style: TextStyle(color: Colors.grey[400], fontSize: 15)),
        ],
      ));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, i) => _RecommendationCard(
        rec: list[i],
        isReceived: isReceived,
        onMarkRead: () => prov.markAsRead(list[i].id),
        onDelete: () => prov.deleteRecommendation(list[i].id),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final RideRecommendationEntity rec;
  final bool isReceived;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const _RecommendationCard({
    required this.rec,
    required this.isReceived,
    required this.onMarkRead,
    required this.onDelete,
  });

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'hace ${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unread = !rec.isRead && isReceived;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unread
            ? ColorTokens.primary30.withOpacity(0.4)
            : Colors.grey[200]!,
          width: unread ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (unread) onMarkRead();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => _RecommendationDetailSheet(rec: rec),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: rec.fromUserPhoto != null
                    ? NetworkImage(rec.fromUserPhoto!) : null,
                  backgroundColor: Colors.grey[200],
                  child: rec.fromUserPhoto == null
                    ? Text(
                        rec.fromUserName.isNotEmpty
                          ? rec.fromUserName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13))
                    : null,
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isReceived ? rec.fromUserName : 'Enviada',
                      style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                    Text(_timeAgo(rec.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ],
                )),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ColorTokens.primary30.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(rec.type.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: ColorTokens.primary30,
                      fontWeight: FontWeight.w600)),
                ),
                if (unread) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: ColorTokens.primary30,
                      shape: BoxShape.circle)),
                ],
              ]),
              const SizedBox(height: 10),
              Text(rec.routeName,
                style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800)),
              if (rec.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(rec.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
              const SizedBox(height: 10),
              Wrap(spacing: 10, children: [
                _chip(Icons.straighten_rounded,
                  '${rec.totalKm.toStringAsFixed(1)} km'),
                _chip(Icons.timer_outlined, rec.estimatedTimeFormatted),
                _chip(Icons.speed_rounded,
                  '${rec.avgSpeed.toStringAsFixed(1)} km/h'),
                _chip(Icons.local_fire_department_rounded,
                  '${rec.calories} kcal'),
              ]),
              if (rec.highlights.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 6, children: rec.highlights.map((h) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber[200]!)),
                  child: Text('📍 $h',
                    style: const TextStyle(fontSize: 11)),
                )).toList()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: Colors.grey[500]),
      const SizedBox(width: 2),
      Text(text, style: TextStyle(
        fontSize: 11,
        color: Colors.grey[600],
        fontWeight: FontWeight.w600)),
    ],
  );
}

class _RecommendationDetailSheet extends StatelessWidget {
  final RideRecommendationEntity rec;
  const _RecommendationDetailSheet({required this.rec});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 0, 20, MediaQuery.of(context).padding.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
            )),
            Text(rec.routeName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('Recomendado por ${rec.fromUserName}',
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _detailStat('📏',
                    '${rec.totalKm.toStringAsFixed(1)} km', 'Distancia'),
                  _detailStat('⏱️', rec.estimatedTimeFormatted, 'Duracion'),
                  _detailStat('⚡',
                    '${rec.avgSpeed.toStringAsFixed(1)} km/h', 'Vel avg'),
                  _detailStat('🔥', '${rec.calories} kcal', 'Calorias'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ColorTokens.primary30.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(rec.type.label,
                style: TextStyle(
                  color: ColorTokens.primary30,
                  fontWeight: FontWeight.w700)),
            ),
            if (rec.description.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('Descripcion',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(rec.description,
                style: TextStyle(
                  fontSize: 14, color: Colors.grey[700], height: 1.5)),
            ],
            if (rec.highlights.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('Sitios destacados',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...rec.highlights.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: ColorTokens.primary30,
                      shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Text(h, style: const TextStyle(fontSize: 14)),
                ]),
              )),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Cerrar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[800],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailStat(String emoji, String value, String label) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 2),
      Text(value,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
      Text(label,
        style: TextStyle(fontSize: 11, color: Colors.grey[500])),
    ],
  );
}
