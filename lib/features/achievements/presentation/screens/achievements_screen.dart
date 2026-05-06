import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:biux/features/achievements/domain/entities/achievement_entity.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/chat/presentation/providers/chat_provider.dart';
import 'package:biux/shared/widgets/shimmer_loading.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);
  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  String _selectedCategory = 'all';
  late TabController _tabCtrl;

  List<Map<String, String>> get _categories => [
    {'id': 'all', 'label': l.t('all'), 'icon': '🏆'},
    {'id': 'distance', 'label': l.t('distance'), 'icon': '🚴'},
    {'id': 'rides', 'label': l.t('rides'), 'icon': '🏁'},
    {'id': 'speed', 'label': l.t('speed'), 'icon': '🚀'},
    {'id': 'streak', 'label': l.t('streak'), 'icon': '🔥'},
    {'id': 'social', 'label': 'Social', 'icon': '👥'},
    {'id': 'special', 'label': l.t('special'), 'icon': '⭐'},
    {'id': 'aventura', 'label': l.t('adventure'), 'icon': '🏔️'},
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
            return const ShimmerListLoading();
          }

          final allInCategory = _selectedCategory == 'all'
              ? provider.achievements
              : provider.achievements
                    .where((a) => a.category == _selectedCategory)
                    .toList();

          final filtered = allInCategory;

          final unlocked = provider.unlockedCount;
          final total = provider.achievements.length;
          final progress = total > 0 ? unlocked / total : 0.0;

          return CustomScrollView(
            slivers: [
              // AppBar con resumen
              SliverAppBar(
                expandedHeight: 310,
                pinned: true,
                backgroundColor: Colors.amber[800],
                foregroundColor: Colors.white,
                title: Text(l.t('my_achievements')),
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
                        : Icon(Icons.sync),
                    tooltip: l.t('sync_achievements'),
                    onPressed: provider.isSyncing
                        ? null
                        : () {
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid != null) {
                              provider.forceSync(uid);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const SizedBox(
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
                                      const SizedBox(width: 12),
                                      Text(l.t('syncing_achievements')),
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
                              '$unlocked / $total ${l.t('achievements_unlocked')}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            // Stats rapidos — fila 1
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _statBadge(
                                  '🚴',
                                  '${_countByCategory(provider, 'distance')}',
                                  l.t('distance'),
                                ),
                                _statBadge(
                                  '🏁',
                                  '${_countByCategory(provider, 'rides')}',
                                  l.t('rides'),
                                ),
                                _statBadge(
                                  '🚀',
                                  '${_countByCategory(provider, 'speed')}',
                                  l.t('speed'),
                                ),
                                _statBadge(
                                  '🔥',
                                  '${_countByCategory(provider, 'streak')}',
                                  l.t('streak'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Stats rapidos — fila 2
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _statBadge(
                                  '👥',
                                  '${_countByCategory(provider, 'social')}',
                                  'Social',
                                ),
                                _statBadge(
                                  '⭐',
                                  '${_countByCategory(provider, 'special')}',
                                  l.t('special'),
                                ),
                                _statBadge(
                                  '🏔️',
                                  '${_countByCategory(provider, 'aventura')}',
                                  l.t('adventure'),
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
                            l.t('syncing_achievements'),
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
                    labelColor: Colors.amber[700],
                    unselectedLabelColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? ColorTokens.neutral90
                        : Colors.grey[600],
                    indicatorColor: Colors.amber[700],
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
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? ColorTokens.neutral90
                              : Colors.grey[600],
                        ),
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
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? ColorTokens.neutral90
                                    : Colors.grey[500],
                              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnlocked = a.isUnlocked;
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final title = l.t(a.title);
    final description = l.t(a.description);
    return GestureDetector(
      onTap: () => _showAchievementDetail(a, provider),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnlocked
              ? Colors.amber.withValues(alpha: isDark ? 0.15 : 0.08)
              : (isDark ? ColorTokens.primary20 : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: isUnlocked
              ? Border.all(
                  color: Colors.amber.withValues(alpha: isDark ? 0.5 : 0.4),
                  width: 1.5,
                )
              : (isDark ? Border.all(color: ColorTokens.primary40) : null),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
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
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isUnlocked
                                ? (isDark ? Colors.amber[300] : Colors.black87)
                                : (isDark ? Colors.white : Colors.grey[600]),
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
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? ColorTokens.neutral90 : Colors.grey[500],
                    ),
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
                            : () {
                                final unit = _unitLabel(a.category);
                                final cur = a.currentValue.toInt();
                                final tgt = a.targetValue.toInt();
                                return unit.isEmpty
                                    ? '$cur / $tgt'
                                    : '$cur $unit / $tgt $unit';
                              }(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked
                              ? Colors.amber[800]
                              : (isDark
                                    ? ColorTokens.neutral90
                                    : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white54 : Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetail(
    AchievementEntity a,
    AchievementsProvider provider,
  ) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);

    // Los 5 niveles internos del logro tocado
    final levels = a.levels;
    const tierNames = ['Bronce', 'Plata', 'Oro', 'Platino', 'Diamante'];

    final pageCtrl = PageController(initialPage: 0);
    int currentPage = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.78,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Barra de arrastre
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
                    // Indicadores de pagina (solo si tiene mas de 1 nivel)
                    if (levels.length > 1) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(levels.length, (i) {
                          final isActive = i == currentPage;
                          final levelUnlocked =
                              a.currentValue >= levels[i].targetValue;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: isActive ? 20 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: levelUnlocked
                                    ? (isActive
                                          ? Colors.amber[800]
                                          : Colors.amber[300])
                                    : (isActive
                                          ? Colors.grey[600]
                                          : Colors.grey[300]),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a.isUnlocked
                            ? '¡Todos los niveles completados! 🏆'
                            : 'Desliza para ver todos los niveles 👉',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                    SizedBox(height: 4),
                    // Paginas deslizables — una por nivel
                    Expanded(
                      child: PageView.builder(
                        controller: pageCtrl,
                        itemCount: levels.length,
                        onPageChanged: (i) =>
                            setStateModal(() => currentPage = i),
                        itemBuilder: (_, i) {
                          final level = levels[i];
                          final tierName = i < tierNames.length
                              ? tierNames[i]
                              : 'Nivel ${i + 1}';
                          final levelUnlocked =
                              a.currentValue >= level.targetValue;
                          final levelProgress = level.targetValue > 0
                              ? (a.currentValue / level.targetValue).clamp(
                                  0.0,
                                  1.0,
                                )
                              : 0.0;
                          final titleText = l.t(a.title);
                          final descText = l.t(a.description);
                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Icono del nivel
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    gradient: levelUnlocked
                                        ? LinearGradient(
                                            colors: [
                                              Colors.amber[200]!,
                                              Colors.amber[600]!,
                                            ],
                                          )
                                        : null,
                                    color: levelUnlocked
                                        ? null
                                        : Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      levelUnlocked ? level.icon : '🔒',
                                      style: const TextStyle(fontSize: 48),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Etiqueta del nivel (Bronce, Plata, Oro…)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: levelUnlocked
                                        ? Colors.amber.withValues(alpha: 0.15)
                                        : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: levelUnlocked
                                          ? Colors.amber.withValues(alpha: 0.5)
                                          : Colors.grey.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    tierName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: levelUnlocked
                                          ? Colors.amber[800]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Titulo del logro
                                Text(
                                  titleText,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: levelUnlocked
                                        ? null
                                        : Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                // Descripcion
                                Text(
                                  levelUnlocked
                                      ? descText
                                      : 'Alcanza ${level.targetValue.toInt()} ${_unitLabel(a.category)} para desbloquear este nivel.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _categoryLabel(a.category),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Progreso hacia este nivel
                                Builder(
                                  builder: (_) {
                                    final unit = _unitLabel(a.category);
                                    final cur = a.currentValue.toInt();
                                    final tgt = level.targetValue.toInt();
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          unit.isEmpty ? '$cur' : '$cur $unit',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: levelUnlocked
                                                ? Colors.amber[800]
                                                : ColorTokens.primary30,
                                          ),
                                        ),
                                        Text(
                                          unit.isEmpty
                                              ? ' / $tgt'
                                              : ' / $tgt $unit',
                                          style: TextStyle(
                                            fontSize: 28,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: levelProgress,
                                    minHeight: 12,
                                    backgroundColor: Colors.grey.withValues(
                                      alpha: 0.12,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      levelUnlocked
                                          ? Colors.amber
                                          : ColorTokens.primary30,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(levelProgress * 100).toInt()}% completado',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Estado y acciones
                                if (levelUnlocked) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.green.withValues(
                                          alpha: 0.3,
                                        ),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '¡Nivel $tierName desbloqueado!',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              if (a.isUnlocked &&
                                                  a.unlockedAt != null)
                                                Text(
                                                  'Completado el ${a.unlockedAt!.day}/${a.unlockedAt!.month}/${a.unlockedAt!.year}',
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
                                  SizedBox(height: 12),
                                  if (a.isUnlocked)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          SharePlus.instance.share(
                                            ShareParams(
                                              text:
                                                  'Desbloqueé el nivel $tierName de "${l.t(a.title)}" (${level.icon}) en Biux - App para Ciclistas.',
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.share, size: 18),
                                        label: Text(l.t('share_achievement')),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber[800],
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ] else ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(
                                        alpha: 0.05,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.blue.withValues(
                                          alpha: 0.2,
                                        ),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l.t('not_unlocked_yet'),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              Text(
                                                _getLevelHint(a, level),
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
                                      icon: const Icon(
                                        Icons.pedal_bike,
                                        size: 18,
                                      ),
                                      label: const Text('Seguir pedaleando'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: ColorTokens.primary30,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: ColorTokens.primary30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Devuelve una pista para el nivel pendiente del logro
  String _getLevelHint(AchievementEntity a, AchievementLevel level) {
    final remaining = (level.targetValue - a.currentValue);
    final unit = _unitLabel(a.category);
    if (remaining <= 0) return '¡Casi lo tienes!';
    final rem = remaining % 1 == 0
        ? remaining.toInt().toString()
        : remaining.toStringAsFixed(1);
    return unit.isEmpty ? 'Te faltan $rem más' : 'Te faltan $rem $unit';
  }

  String _unitLabel(String cat) => switch (cat) {
    'distance' => 'km',
    'rides' => l.t('rides'),
    'speed' => 'km/h',
    'streak' => l.t('days_unit'),
    'social' => l.t('groups'),
    'aventura' => 'km',
    _ => '',
  };

  String _categoryLabel(String cat) => switch (cat) {
    'distance' => '🚴 ${l.t('distance')}',
    'rides' => '🏁 ${l.t('rides')}',
    'speed' => '🚀 ${l.t('speed')}',
    'streak' => '🔥 ${l.t('streak')}',
    'social' => '👥 Social',
    'special' => '⭐ ${l.t('special')}',
    'aventura' => '🏔️ ${l.t('adventure')}',
    _ => '🏆 ${l.t('general')}',
  };

  void _shareAchievements(AchievementsProvider provider) {
    final unlocked = provider.unlockedCount;
    final total = provider.achievements.length;
    final names = provider.unlockedAchievements
        .map((a) => '${a.icon} ${a.title}')
        .join('\n');
    final text =
        'Mis logros en Biux: $unlocked/$total desbloqueados\n\n$names\n\n¡Descarga Biux y empieza a pedalear!';
    _showShareOptions(text);
  }

  void _showShareOptions(String text) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
            Text(
              l.t('share_achievements'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              l.t('choose_how_share'),
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () {
                Navigator.pop(ctx);
                _shareInApp(text);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.amber[800],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.people_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Compartir con amigos en Biux',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            l.t('send_achievements_chat'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                Navigator.pop(ctx);
                SharePlus.instance.share(ShareParams(text: text));
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.share_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Compartir fuera de Biux',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            l.t('share_outside_biux'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _shareInApp(String text) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => _AchievementsShareInAppSheet(statsText: text),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (dc) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text(l.t('how_achievements_work')),
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

// WIDGET: Compartir logros dentro de la app
class _AchievementsShareInAppSheet extends StatefulWidget {
  final String statsText;
  const _AchievementsShareInAppSheet({required this.statsText});

  @override
  State<_AchievementsShareInAppSheet> createState() =>
      _AchievementsShareInAppSheetState();
}

class _AchievementsShareInAppSheetState
    extends State<_AchievementsShareInAppSheet> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _contacts = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  final Set<String> _sent = {};

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final chatProvider = context.read<ChatProvider>();
      final chats = chatProvider.chats
          .where((c) => c.typeString == 'direct')
          .toList();
      final contacts = <Map<String, dynamic>>[];
      for (final chat in chats) {
        final otherId = chat.participantIds.firstWhere(
          (id) => id != currentUser.uid,
          orElse: () => '',
        );
        if (otherId.isEmpty) continue;
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherId)
            .get();
        final data = doc.data();
        contacts.add({
          'userId': otherId,
          'name':
              data?['fullName'] ?? data?['userName'] ?? l.t('cyclist_label'),
          'photo': data?['photo'] ?? '',
          'chatId': chat.id,
        });
      }
      setState(() {
        _contacts = contacts;
        _filtered = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _contacts
          .where((c) => (c['name'] as String).toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _sendToContact(Map<String, dynamic> contact) async {
    final chatProvider = context.read<ChatProvider>();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    try {
      await chatProvider.sendMessage(
        contact['chatId'] as String,
        senderId: currentUser.uid,
        senderName: currentUser.displayName ?? l.t('user_default'),
        content: widget.statsText,
        participants: [currentUser.uid, contact['userId'] as String], // legacy
      );
      setState(() => _sent.add(contact['userId'] as String));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.t('sent_to')} ${contact['name'] as String}'),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('error_sending_message')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enviar a amigos en Biux',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 14),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l.t('search_friend'),
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No tienes chats aun',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.push('/users/search');
                            },
                            child: Text(l.t('search_cyclists')),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final contact = _filtered[index];
                        final alreadySent = _sent.contains(contact['userId']);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber.withValues(
                              alpha: 0.15,
                            ),
                            backgroundImage:
                                (contact['photo'] as String).isNotEmpty
                                ? NetworkImage(contact['photo'] as String)
                                : null,
                            child: (contact['photo'] as String).isEmpty
                                ? Text(
                                    (contact['name'] as String)[0]
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            contact['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            alreadySent ? 'Enviado' : 'Toca para enviar',
                            style: TextStyle(
                              fontSize: 12,
                              color: alreadySent
                                  ? Colors.green[600]
                                  : Colors.grey[400],
                            ),
                          ),
                          trailing: alreadySent
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green[600],
                                )
                              : ElevatedButton(
                                  onPressed: () => _sendToContact(contact),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber[800],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Enviar',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
