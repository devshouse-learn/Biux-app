import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:biux/features/achievements/domain/entities/achievement_entity.dart';
import 'package:share_plus/share_plus.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);
  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  String _selectedCategory = 'all';
  late TabController _tabCtrl;

  final _categories = [
    {'id': 'all', 'label': 'Todos', 'icon': '🏆'},
    {'id': 'distance', 'label': 'Distancia', 'icon': '🚴'},
    {'id': 'rides', 'label': 'Rodadas', 'icon': '🏁'},
    {'id': 'speed', 'label': 'Velocidad', 'icon': '🚀'},
    {'id': 'streak', 'label': 'Racha', 'icon': '🔥'},
    {'id': 'social', 'label': 'Social', 'icon': '👥'},
    {'id': 'special', 'label': 'Especiales', 'icon': '⭐'},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _categories.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _selectedCategory = _categories[_tabCtrl.index]['id']!);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<AchievementsProvider>().loadAchievements(uid);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AchievementsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = _selectedCategory == 'all'
              ? provider.achievements
              : provider.achievements
                    .where((a) => a.category == _selectedCategory)
                    .toList();

          final unlocked = provider.unlockedCount;
          final total = provider.achievements.length;
          final progress = total > 0 ? unlocked / total : 0.0;

          return CustomScrollView(
            slivers: [
              // AppBar con resumen
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: Colors.amber[800],
                foregroundColor: Colors.white,
                title: const Text('Mis Logros'),
                actions: [
                  IconButton(
                    icon: provider.isSyncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.sync),
                    tooltip: 'Sincronizar logros',
                    onPressed: provider.isSyncing
                        ? null
                        : () {
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid != null) {
                              provider.forceSync(uid);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Sincronizando logros...'),
                                    ],
                                  ),
                                  backgroundColor: Colors.amber,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareAchievements(provider),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: _showInfo,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.amber[700]!, Colors.orange[800]!],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 60,
                          left: 20,
                          right: 20,
                          bottom: 12,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Circulo de progreso
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 6,
                                      backgroundColor: Colors.white24,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$unlocked / $total Logros desbloqueados',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Stats rapidos
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _statBadge(
                                  '🥇',
                                  '${_countByCategory(provider, 'distance')}',
                                  'Distancia',
                                ),
                                _statBadge(
                                  '🏁',
                                  '${_countByCategory(provider, 'rides')}',
                                  'Rodadas',
                                ),
                                _statBadge(
                                  '🚀',
                                  '${_countByCategory(provider, 'speed')}',
                                  'Velocidad',
                                ),
                                _statBadge(
                                  '🔥',
                                  '${_countByCategory(provider, 'streak')}',
                                  'Racha',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Banner de sincronizacion
              if (provider.isSyncing)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    color: Colors.amber.withValues(alpha: 0.15),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.amber[800]!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sincronizando logros con tus rodadas...',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.amber[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Tabs de categorias
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabCtrl,
                    isScrollable: true,
                    labelColor: Colors.amber[800],
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: Colors.amber[800],
                    indicatorWeight: 3,
                    tabAlignment: TabAlignment.start,
                    tabs: _categories
                        .map((c) => Tab(text: '${c['icon']} ${c['label']}'))
                        .toList(),
                  ),
                ),
              ),

              // Info de categoria
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Text(
                        '${filtered.length} logros',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Text(
                        '${filtered.where((a) => a.isUnlocked).length} desbloqueados',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Lista de logros
              filtered.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _categories.firstWhere(
                                (c) => c['id'] == _selectedCategory,
                              )['icon']!,
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No hay logros en esta categoría',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) =>
                              _buildAchievementCard(filtered[i], provider),
                          childCount: filtered.length,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  int _countByCategory(AchievementsProvider p, String cat) {
    return p.achievements
        .where((a) => a.category == cat && a.isUnlocked)
        .length;
  }

  Widget _statBadge(String emoji, String count, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    AchievementEntity a,
    AchievementsProvider provider,
  ) {
    final isUnlocked = a.isUnlocked;
    return GestureDetector(
      onTap: () => _showAchievementDetail(a),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnlocked
              ? Colors.amber.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isUnlocked
              ? Border.all(
                  color: Colors.amber.withValues(alpha: 0.4),
                  width: 1.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icono
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: isUnlocked
                    ? LinearGradient(
                        colors: [Colors.amber[300]!, Colors.amber[600]!],
                      )
                    : null,
                color: isUnlocked ? null : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  a.icon,
                  style: TextStyle(
                    fontSize: 30,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          a.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isUnlocked
                                ? Colors.black87
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      if (isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Logrado',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    a.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  // Barra de progreso
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: a.progress,
                            minHeight: 8,
                            backgroundColor: Colors.grey.withValues(
                              alpha: 0.12,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isUnlocked ? Colors.amber : ColorTokens.primary30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isUnlocked
                            ? '100%'
                            : '${a.currentValue.toInt()} / ${a.targetValue.toInt()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked
                              ? Colors.amber[800]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetail(AchievementEntity a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              // Icono grande
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: a.isUnlocked
                      ? LinearGradient(
                          colors: [Colors.amber[200]!, Colors.amber[600]!],
                        )
                      : null,
                  color: a.isUnlocked ? null : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(a.icon, style: const TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 16),
              // Titulo
              Text(
                a.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                a.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Categoria
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _categoryLabel(a.category),
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 20),
              // Progreso
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${a.currentValue.toInt()}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: a.isUnlocked
                          ? Colors.amber[800]
                          : ColorTokens.primary30,
                    ),
                  ),
                  Text(
                    ' / ${a.targetValue.toInt()}',
                    style: TextStyle(fontSize: 28, color: Colors.grey[400]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: a.progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    a.isUnlocked ? Colors.amber : ColorTokens.primary30,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(a.progress * 100).toInt()}% completado',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              // Estado
              if (a.isUnlocked) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Logro desbloqueado',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.green,
                              ),
                            ),
                            if (a.unlockedAt != null)
                              Text(
                                'Obtenido el ${a.unlockedAt?.day ?? 0}/${a.unlockedAt?.month ?? 0}/${a.unlockedAt?.year ?? 0}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      SharePlus.instance.share(
                        ShareParams(
                          text:
                              'Desbloqueé el logro "${a.title}" (${a.icon}) en Biux - App para Ciclistas.',
                        ),
                      );
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Compartir logro'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        color: Colors.blue,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Aún no desbloqueado',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              _getHint(a),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.pedal_bike, size: 18),
                    label: const Text('Seguir pedaleando'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorTokens.primary30,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: ColorTokens.primary30),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(String cat) => switch (cat) {
    'distance' => '🚴 Distancia',
    'rides' => '🏁 Rodadas',
    'speed' => '🚀 Velocidad',
    'streak' => '🔥 Racha',
    'social' => '👥 Social',
    'special' => '⭐ Especiales',
    _ => '🏆 General',
  };

  String _getHint(AchievementEntity a) {
    final remaining = (a.targetValue - a.currentValue).toInt();
    return switch (a.category) {
      'distance' => 'Te faltan $remaining km. ¡Sigue pedaleando!',
      'rides' => 'Te faltan $remaining rodadas. ¡Sal a rodar!',
      'speed' => 'Necesitas alcanzar ${a.targetValue.toInt()} km/h',
      'streak' => 'Pedalea $remaining días más seguidos',
      'social' => 'Únete a $remaining grupos más',
      'special' => 'Completa este reto especial',
      _ => '¡Sigue así, lo lograrás!',
    };
  }

  void _shareAchievements(AchievementsProvider provider) {
    final unlocked = provider.unlockedCount;
    final total = provider.achievements.length;
    final names = provider.unlockedAchievements
        .map((a) => '${a.icon} ${a.title}')
        .join('\n');
    final text =
        'Mis logros en Biux: $unlocked/$total desbloqueados\n\n$names\n\n¡Descarga Biux y empieza a pedalear!';
    SharePlus.instance.share(ShareParams(text: text));
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (dc) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text('Cómo funcionan los logros'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Los logros se desbloquean automáticamente al cumplir los objetivos:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              '🚴 Distancia — Acumula kilómetros',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 4),
            Text(
              '🏁 Rodadas — Completa recorridos',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 4),
            Text(
              '🚀 Velocidad — Alcanza velocidades máximas',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 4),
            Text(
              '🔥 Racha — Pedalea varios días seguidos',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 4),
            Text('👥 Social — Únete a grupos', style: TextStyle(fontSize: 13)),
            SizedBox(height: 4),
            Text('⭐ Especiales — Retos únicos', style: TextStyle(fontSize: 13)),
            SizedBox(height: 12),
            Text(
              'Los logros se sincronizan automáticamente cada semana.\nTambién puedes sincronizar manualmente con el botón \ud83d\udd04',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dc),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
