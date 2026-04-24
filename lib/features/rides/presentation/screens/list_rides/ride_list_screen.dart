import 'package:biux/features/groups/data/models/group_model.dart';
import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/features/rides/presentation/providers/ride_provider.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/features/maps/presentation/providers/meeting_point_provider.dart';
import 'package:biux/features/maps/data/models/meeting_point.dart';
import 'package:biux/shared/widgets/shimmer_loading.dart';

class RideListScreen extends StatefulWidget {
  final String? groupId;
  const RideListScreen({super.key, this.groupId});

  @override
  State<RideListScreen> createState() => _RideListScreenState();
}

class _RideListScreenState extends State<RideListScreen>
    with SingleTickerProviderStateMixin {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    if (widget.groupId != null) {
      // Si viene de un grupo específico, mostrar rodadas de ese grupo
      rideProvider.loadGroupRides(widget.groupId!);
    } else {
      groupProvider.loadUserGroups();
      groupProvider.loadAdminGroups();
      groupProvider.loadAllGroups();
      rideProvider.loadAllRides();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Si viene con groupId, mostrar rodadas de ese grupo
    if (widget.groupId != null) {
      return _buildGroupRidesView(l);
    }

    // Vista principal: solo grupos
    return Consumer2<GroupProvider, RideProvider>(
      builder: (context, groupProvider, rideProvider, child) {
        return Stack(
          children: [
            Column(
              children: [
                // ── Barra de búsqueda ──
                if (_showSearch) _buildSearchBar(l),

                // ── Tabs: Mis Grupos / Explorar ──
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: ColorTokens.neutral60.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: ColorTokens.primary30,
                    indicatorWeight: 3,
                    labelColor: ColorTokens.primary30,
                    unselectedLabelColor: ColorTokens.neutral60,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    isScrollable: false,
                    tabAlignment: TabAlignment.fill,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.groups, size: 16),
                            SizedBox(width: 6),
                            Text(l.t('my_groups')),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.explore, size: 16),
                            SizedBox(width: 6),
                            Text(l.t('explore_more')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Contenido ──
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMyGroupsList(groupProvider, rideProvider, l),
                      _buildExploreGroupsList(groupProvider, rideProvider, l),
                    ],
                  ),
                ),
              ],
            ),
            // ── FAB Crear Grupo ──
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                heroTag: 'createGroup',
                onPressed: () => context.push(AppRoutes.groupCreate),
                backgroundColor: ColorTokens.primary30,
                icon: Icon(Icons.group_add, color: Colors.white),
                label: Text(
                  l.t('create_group'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // ── Vista de rodadas de un grupo específico ──────────────────────
  // ══════════════════════════════════════════════════════════════════
  Widget _buildGroupRidesView(LocaleNotifier l) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        title: Text(l.t('rides')),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) _searchController.clear();
            }),
          ),
        ],
      ),
      body: Consumer<RideProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const ShimmerListLoading();
          }

          var rides = provider.rides;

          // Filtro de búsqueda
          if (_searchController.text.isNotEmpty) {
            final q = _searchController.text.toLowerCase();
            rides = rides
                .where((r) => r.name.toLowerCase().contains(q))
                .toList();
          }

          // Separar próximas y pasadas
          final now = DateTime.now();
          final upcoming =
              rides
                  .where(
                    (r) =>
                        r.dateTime.isAfter(now) &&
                        r.status != RideStatus.cancelled &&
                        r.status != RideStatus.completed,
                  )
                  .toList()
                ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
          final past =
              rides
                  .where(
                    (r) =>
                        r.dateTime.isBefore(now) ||
                        r.status == RideStatus.completed ||
                        r.status == RideStatus.cancelled,
                  )
                  .toList()
                ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

          return Column(
            children: [
              if (_showSearch) _buildSearchBar(l),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    children: [
                      if (upcoming.isNotEmpty) ...[
                        _buildSectionHeader(
                          l.t('upcoming'),
                          Icons.upcoming,
                          ColorTokens.primary30,
                        ),
                        SizedBox(height: 8),
                        ...upcoming.map(
                          (ride) => _buildRideCard(ride, provider, l),
                        ),
                      ],
                      if (past.isNotEmpty) ...[
                        SizedBox(height: 20),
                        _buildSectionHeader(
                          l.t('finished'),
                          Icons.history,
                          ColorTokens.neutral60,
                        ),
                        SizedBox(height: 8),
                        ...past.map(
                          (ride) =>
                              _buildRideCard(ride, provider, l, isPast: true),
                        ),
                      ],
                      if (upcoming.isEmpty && past.isEmpty)
                        _buildEmptyState(
                          Icons.event_available,
                          l.t('no_rides_available'),
                          l.t('rides_will_appear_here'),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/rides/create/${widget.groupId}'),
        backgroundColor: ColorTokens.primary30,
        child: const Icon(Icons.add, color: ColorTokens.neutral100),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // ── Tab 1: Mis Grupos ────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════
  Widget _buildMyGroupsList(
    GroupProvider groupProvider,
    RideProvider rideProvider,
    LocaleNotifier l,
  ) {
    if (groupProvider.isLoading) {
      return const ShimmerListLoading();
    }

    var groups = groupProvider.userGroups;

    // Filtro de búsqueda
    if (_searchController.text.isNotEmpty) {
      final q = _searchController.text.toLowerCase();
      groups = groups.where((g) => g.name.toLowerCase().contains(q)).toList();
    }

    if (groups.isEmpty) {
      return _buildEmptyState(
        Icons.groups_outlined,
        l.t('no_groups_joined'),
        l.t('join_group_to_see_rides'),
        onAction: () => _tabController.animateTo(1),
        actionText: l.t('explore_groups'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return _buildGroupCard(group, rideProvider, l);
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // ── Tab 2: Explorar Grupos ───────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════
  Widget _buildExploreGroupsList(
    GroupProvider groupProvider,
    RideProvider rideProvider,
    LocaleNotifier l,
  ) {
    if (groupProvider.isLoading) {
      return const ShimmerListLoading();
    }

    var groups = groupProvider.allGroups;

    // Excluir grupos del usuario
    final userGroupIds = groupProvider.userGroups.map((g) => g.id).toSet();
    groups = groups.where((g) => !userGroupIds.contains(g.id)).toList();

    // Filtro de búsqueda
    if (_searchController.text.isNotEmpty) {
      final q = _searchController.text.toLowerCase();
      groups = groups.where((g) => g.name.toLowerCase().contains(q)).toList();
    }

    if (groups.isEmpty) {
      return _buildEmptyState(
        Icons.explore_outlined,
        l.t('no_groups_available'),
        l.t('check_back_later'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return _buildGroupCard(group, rideProvider, l, isExplore: true);
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // ── Card de Grupo ────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════
  Widget _buildGroupCard(
    GroupModel group,
    RideProvider rideProvider,
    LocaleNotifier l, {
    bool isExplore = false,
  }) {
    // Contar rodadas próximas de este grupo
    final now = DateTime.now();
    final upcomingRides = rideProvider.rides
        .where(
          (r) =>
              r.groupId == group.id &&
              r.dateTime.isAfter(now) &&
              r.status != RideStatus.cancelled &&
              r.status != RideStatus.completed,
        )
        .length;

    final isAdmin = Provider.of<GroupProvider>(
      context,
      listen: false,
    ).adminGroups.any((g) => g.id == group.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => context.push('/groups/${group.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // ── Logo del grupo ──
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: group.logoUrl != null && group.logoUrl!.isNotEmpty
                    ? OptimizedNetworkImage(
                        imageUrl: group.logoUrl!,
                        width: 56,
                        height: 56,
                        imageType: 'avatar',
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: ColorTokens.primary30.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.groups,
                          size: 28,
                          color: ColorTokens.primary30,
                        ),
                      ),
              ),
              const SizedBox(width: 14),

              // ── Info del grupo ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAdmin)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ColorTokens.warning50.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ColorTokens.warning50.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            child: Text(
                              'Admin',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: ColorTokens.warning50,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Descripción
                    if (group.description.isNotEmpty)
                      Text(
                        group.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: ColorTokens.neutral60,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 8),

                    // ── Stats row ──
                    Row(
                      children: [
                        // Miembros
                        _buildGroupStat(
                          Icons.people,
                          '0',
                          ColorTokens.neutral60,
                        ),
                        SizedBox(width: 16),
                        // Rodadas próximas
                        if (upcomingRides > 0 && !isExplore)
                          _buildGroupStat(
                            Icons.directions_bike,
                            '$upcomingRides ${l.t('upcoming').toLowerCase()}',
                            ColorTokens.success40,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Flecha ──
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: ColorTokens.neutral60, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // ── Card de Rodada (para vista de grupo específico) ──────────────
  // ══════════════════════════════════════════════════════════════════
  Widget _buildRideCard(
    RideModel ride,
    RideProvider provider,
    LocaleNotifier l, {
    bool isPast = false,
  }) {
    final participationStatus = provider.getParticipationStatus(ride);
    final isCreator = provider.isCreator(ride);

    return Opacity(
      opacity: isPast ? 0.65 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: isPast ? 1 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => context.push('/rides/${ride.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Nombre + dificultad
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(ride.difficulty),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              decoration: isPast
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              _buildMiniChip(
                                l.t(ride.difficultyDisplayName),
                                _getDifficultyColor(ride.difficulty),
                              ),
                              SizedBox(width: 6),
                              Text(
                                '${ride.kilometers} km',
                                style: TextStyle(
                                  color: ColorTokens.neutral60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isCreator)
                      _buildMiniChip(l.t('organizer'), ColorTokens.warning50),
                  ],
                ),
                const SizedBox(height: 8),

                // Row 2: Fecha + participantes
                Row(
                  children: [
                    _buildInfoItem(
                      Icons.schedule,
                      _formatDateTime(ride.dateTime),
                    ),
                    const SizedBox(width: 16),
                    _buildInfoItem(
                      Icons.group,
                      '${ride.participantCount}${ride.maybeParticipantCount > 0 ? ' +${ride.maybeParticipantCount}?' : ''}',
                    ),
                  ],
                ),

                // Row 3: Punto de encuentro
                FutureBuilder<MeetingPoint?>(
                  future: Provider.of<MeetingPointProvider>(
                    context,
                    listen: false,
                  ).getMeetingPoint(ride.meetingPointId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null)
                      return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: _buildInfoItem(
                        Icons.location_on,
                        snapshot.data!.name,
                      ),
                    );
                  },
                ),

                // Row 4: Acciones (solo futuras y no creador)
                if (!isPast && !isCreator) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (participationStatus !=
                          RideParticipationStatus.notParticipating)
                        _buildParticipationChip(participationStatus, l),
                      const Spacer(),
                      _buildActionButton(
                        ride,
                        participationStatus,
                        provider,
                        l,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // ── Widgets auxiliares ───────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════

  Widget _buildSearchBar(LocaleNotifier l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: l.t('search_groups'),
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ColorTokens.neutral60.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ColorTokens.neutral60.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: ColorTokens.primary30,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupStat(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: ColorTokens.neutral60),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: ColorTokens.neutral60,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipationChip(
    RideParticipationStatus status,
    LocaleNotifier l,
  ) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case RideParticipationStatus.participating:
        color = ColorTokens.success40;
        text = l.t('going_to_attend');
        icon = Icons.check_circle;
        break;
      case RideParticipationStatus.maybeParticipating:
        color = ColorTokens.warning50;
        text = l.t('maybe_going');
        icon = Icons.help;
        break;
      case RideParticipationStatus.notParticipating:
        return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    RideModel ride,
    RideParticipationStatus status,
    RideProvider provider,
    LocaleNotifier l,
  ) {
    if (ride.status == RideStatus.completed ||
        ride.status == RideStatus.cancelled ||
        ride.dateTime.isBefore(DateTime.now())) {
      return const SizedBox.shrink();
    }

    switch (status) {
      case RideParticipationStatus.participating:
        return _buildSmallButton(
          l.t('not_going'),
          Icons.cancel,
          ColorTokens.error50,
          () => _leaveRide(ride.id, provider),
        );
      case RideParticipationStatus.maybeParticipating:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSmallButton(
              l.t('confirm'),
              Icons.check,
              ColorTokens.success40,
              () => _joinRide(ride.id, provider),
            ),
            SizedBox(width: 6),
            _buildSmallButton(
              l.t('no_label'),
              Icons.close,
              ColorTokens.error50,
              () => _leaveRide(ride.id, provider),
            ),
          ],
        );
      case RideParticipationStatus.notParticipating:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSmallButton(
              l.t('going'),
              Icons.directions_bike,
              ColorTokens.success40,
              () => _joinRide(ride.id, provider),
            ),
            SizedBox(width: 6),
            _buildSmallButton(
              l.t('maybe'),
              Icons.help_outline,
              ColorTokens.warning50,
              () => _maybeJoinRide(ride.id, provider),
            ),
          ],
        );
    }
  }

  Widget _buildSmallButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onAction,
    String? actionText,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ColorTokens.primary30.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 48,
                        color: ColorTokens.primary30.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorTokens.neutral60,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (onAction != null && actionText != null) ...[
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: onAction,
                        icon: const Icon(Icons.explore, size: 18),
                        label: Text(actionText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorTokens.primary30,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // ── Helpers ──────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return ColorTokens.success50;
      case DifficultyLevel.medium:
        return ColorTokens.warning50;
      case DifficultyLevel.hard:
        return ColorTokens.error50;
      case DifficultyLevel.expert:
        return ColorTokens.secondary60;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final months = [
      l.t('month_jan'),
      l.t('month_feb'),
      l.t('month_mar'),
      l.t('month_apr'),
      l.t('month_may'),
      l.t('month_jun'),
      l.t('month_jul'),
      l.t('month_aug'),
      l.t('month_sep'),
      l.t('month_oct'),
      l.t('month_nov'),
      l.t('month_dec'),
    ];
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day $month - $hour:$minute';
  }

  // ══════════════════════════════════════════════════════════════════
  // ── Acciones ─────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════

  void _joinRide(String rideId, RideProvider provider) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final success = await provider.joinRide(rideId);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('joined_ride')),
          backgroundColor: ColorTokens.success40,
        ),
      );
    }
  }

  void _maybeJoinRide(String rideId, RideProvider provider) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final success = await provider.maybeJoinRide(rideId);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('marked_maybe')),
          backgroundColor: ColorTokens.warning60,
        ),
      );
    }
  }

  void _leaveRide(String rideId, RideProvider provider) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final success = await provider.leaveRide(rideId);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('left_ride')),
          backgroundColor: ColorTokens.neutral60,
        ),
      );
    }
  }
}
