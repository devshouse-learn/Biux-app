import 'package:biux/features/maps/data/models/meeting_point.dart';
import 'package:biux/features/maps/presentation/providers/meeting_point_provider.dart';
import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/features/rides/presentation/providers/ride_provider.dart';
import 'package:biux/features/rides/presentation/widgets/ride_attendance_button.dart';
import 'package:biux/features/rides/presentation/widgets/ride_attendees_list_optimized.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:biux/core/services/deep_link_service.dart';
import 'package:biux/features/social/presentation/widgets/ride_social_actions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/chat/data/datasources/chat_datasource.dart';
import 'package:biux/features/chat/presentation/providers/chat_provider.dart';
import 'package:biux/features/chat/presentation/screens/chat_screen.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class RideDetailScreen extends StatefulWidget {
  final String rideId;
  final bool openComments;

  const RideDetailScreen({
    Key? key,
    required this.rideId,
    this.openComments = false,
  }) : super(key: key);

  @override
  _RideDetailScreenState createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen>
    with TickerProviderStateMixin {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  TabController? _tabController;
  String? _rideChatId;
  bool _loadingChat = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RideProvider>(
        context,
        listen: false,
      ).selectRideById(widget.rideId);
      Provider.of<MeetingPointProvider>(
        context,
        listen: false,
      ).startListening();

      // Si viene desde notificación, abrir comentarios automáticamente
      if (widget.openComments) {
        _openComments();
      }
    });

    _tabController = TabController(length: 2, vsync: this);
  }

  void _openComments() {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final ride = rideProvider.selectedRide;
    if (ride != null) {
      context.push(
        '/rides/${widget.rideId}/comments?ownerId=${ride.createdBy}',
      );
    }
  }

  void _navigateToEdit(BuildContext context, RideModel ride) {
    context.push('/groups/${ride.groupId}/rides/edit', extra: ride);
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Scaffold(
      body: Consumer2<RideProvider, MeetingPointProvider>(
        builder: (context, rideProvider, meetingPointProvider, child) {
          if (rideProvider.isLoading) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: ColorTokens.neutral100,
              ),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final ride = rideProvider.selectedRide;
          if (ride == null) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: ColorTokens.neutral100,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: ColorTokens.error50),
                    SizedBox(height: 16),
                    Text(l.t('ride_not_found')),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: Text(l.t('go_back')),
                    ),
                  ],
                ),
              ),
            );
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: ColorTokens.primary30,
                  foregroundColor: ColorTokens.neutral100,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: ColorTokens.neutral100,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/groups/${ride.groupId}');
                      }
                    },
                  ),
                  actions: [
                    // Botón de editar (solo para el creador)
                    if (ride.createdBy == rideProvider.currentUserId &&
                        ride.status != RideStatus.cancelled &&
                        ride.status != RideStatus.completed)
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _navigateToEdit(context, ride),
                        tooltip: l.t('edit_ride'),
                      ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      ride.name,
                      style: TextStyle(
                        color: ColorTokens.neutral100,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: ride.status == RideStatus.cancelled
                              ? [ColorTokens.error50, const Color(0xFF8B0000)]
                              : [
                                  _getDifficultyColor(ride.difficulty),
                                  ColorTokens.primary30,
                                ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          ride.status == RideStatus.cancelled
                              ? Icons.cancel
                              : Icons.directions_bike,
                          size: 80,
                          color: ColorTokens.neutral100.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                // TabBar
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: ColorTokens.primary30,
                    unselectedLabelColor: ColorTokens.neutral60,
                    indicatorColor: ColorTokens.primary30,
                    tabs: [
                      Tab(icon: Icon(Icons.info_outline), text: l.t('info')),
                      Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chat'),
                    ],
                  ),
                ),
                // TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Info (contenido original)
                      _buildInfoTab(
                        ride,
                        rideProvider,
                        meetingPointProvider,
                        l,
                      ),
                      // Tab 2: Chat
                      _buildRideChatTab(ride),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTab(
    RideModel ride,
    RideProvider rideProvider,
    MeetingPointProvider meetingPointProvider,
    LocaleNotifier l,
  ) {
    final meetingPoint = meetingPointProvider.meetingPoints
        .where((mp) => mp.id == ride.meetingPointId)
        .firstOrNull;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de cancelación
          if (ride.status == RideStatus.cancelled)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: ColorTokens.error50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ColorTokens.error50.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.cancel, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.t('ride_cancelled'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Esta rodada ha sido cancelada por el organizador.',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Información del grupo organizador
          GroupInfoWidget(ride: ride),
          SizedBox(height: 16),

          // Información básica
          BasicInfoWidget(ride: ride),
          SizedBox(height: 16),

          // Punto de encuentro
          if (meetingPoint != null)
            MeetingPointInfoWidget(meetingPoint: meetingPoint),
          SizedBox(height: 24),

          // Instrucciones
          InfoSectionWidget(
            title: l.t('instructions'),
            content: ride.instructions,
            icon: Icons.info_outline,
          ),
          SizedBox(height: 16),

          // Recomendaciones
          InfoSectionWidget(
            title: l.t('recommendations'),
            content: ride.recommendations,
            icon: Icons.lightbulb_outline,
          ),
          SizedBox(height: 24),

          // Acciones sociales (Comentarios)
          RideSocialActions(rideId: ride.id, rideOwnerId: ride.createdBy),
          SizedBox(height: 24),

          // Participantes + botón de asistencia
          ParticipantsSectionWidget(ride: ride),
          SizedBox(height: 24),

          // Botón de compartir
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _shareRide(context, ride),
              icon: Icon(Icons.share),
              label: Text(l.t('share_ride')),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorTokens.primary50,
                side: BorderSide(color: ColorTokens.primary50, width: 2),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // Si es el creador, botón de cancelar
          if (ride.createdBy == rideProvider.currentUserId &&
              ride.status != RideStatus.cancelled &&
              ride.status != RideStatus.completed) ...[
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(ride.id, rideProvider),
                icon: Icon(Icons.cancel),
                label: Text(l.t('cancel_ride')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorTokens.error50,
                  side: BorderSide(color: ColorTokens.error50, width: 2),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<String> _getOrCreateRideChat(RideModel ride) async {
    if (_rideChatId != null) return _rideChatId!;
    setState(() => _loadingChat = true);
    final chatProvider = context.read<ChatProvider>();

    // Buscar chat existente de tipo ride
    final existing = chatProvider.chats
        .where((c) => c.type == ChatType.ride && c.name == ride.name)
        .firstOrNull;

    if (existing != null) {
      _rideChatId = existing.id;
      chatProvider.openChat(existing.id);
      setState(() => _loadingChat = false);
      return existing.id;
    }

    // Crear nuevo chat de rodada
    final chatId = await chatProvider.createGroupChat(
      participantIds: [...ride.participants, ...ride.maybeParticipants],
      name: ride.name,
      photoUrl: ride.imageUrl,
      rideId: ride.id,
    );
    chatProvider.openChat(chatId);
    _rideChatId = chatId;
    setState(() => _loadingChat = false);
    return chatId;
  }

  Widget _buildRideChatTab(RideModel ride) {
    final l = Provider.of<LocaleNotifier>(context);
    final currentUid = context.read<ChatProvider>().currentUid;
    final isParticipant =
        ride.participants.contains(currentUid) ||
        ride.maybeParticipants.contains(currentUid);

    if (!isParticipant) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              l.t('join_to_chat'),
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Confirma tu asistencia para acceder al chat',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_loadingChat) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<String>(
      future: _getOrCreateRideChat(ride),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                SizedBox(height: 12),
                Text(
                  l.t('chat_error'),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => setState(() => _rideChatId = null),
                  child: Text(l.t('retry')),
                ),
              ],
            ),
          );
        }
        final chatId = snapshot.data!;
        final chat = ChatEntity(
          id: chatId,
          name: ride.name,
          photoUrl: ride.imageUrl,
          type: ChatType.ride,
          participantIds: [...ride.participants, ...ride.maybeParticipants],
          updatedAt: DateTime.now(),
          unreadCount: const {},
        );
        return ChatScreen(chat: chat, embedded: true);
      },
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return ColorTokens.success50;
      case DifficultyLevel.medium:
        return ColorTokens.warning50;
      case DifficultyLevel.hard:
        return ColorTokens.error50;
      case DifficultyLevel.expert:
        return ColorTokens.primary60;
    }
  }

  Future<void> _shareRide(BuildContext context, RideModel ride) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    try {
      // Obtener información del grupo
      final provider = Provider.of<RideProvider>(context, listen: false);
      final groupInfo = await provider.getGroupInfo(ride.groupId);
      final groupName = groupInfo?['name'] ?? l.t('a_cycling_group');

      // Generar texto de compartir con deep link
      final shareText = DeepLinkService.generateShareText(
        rideName: ride.name,
        rideId: ride.id,
        groupName: groupName,
      );

      // Si hay imagen, compartirla con el texto
      if ((ride.imageUrl ?? '').isNotEmpty) {
        try {
          // Descargar la imagen temporalmente
          final response = await http.get(Uri.parse(ride.imageUrl!));
          if (response.statusCode == 200) {
            final tempDir = await getTemporaryDirectory();
            final file = File('${tempDir.path}/ride_${ride.id}.jpg');
            await file.writeAsBytes(response.bodyBytes);

            // Compartir con imagen
            await SharePlus.instance.share(
              ShareParams(files: [XFile(file.path)], text: shareText),
            );

            // Limpiar archivo temporal después de compartir
            await file.delete();
          } else {
            // Si falla la descarga, compartir solo texto
            await SharePlus.instance.share(ShareParams(text: shareText));
          }
        } catch (e) {
          // Si hay error con la imagen, compartir solo texto
          debugPrint('Error compartiendo imagen: $e');
          await SharePlus.instance.share(ShareParams(text: shareText));
        }
      } else {
        // Sin imagen, compartir solo texto
        await SharePlus.instance.share(ShareParams(text: shareText));
      }
    } catch (e) {
      debugPrint('Error al compartir: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('error_sharing_ride')),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _showCancelDialog(String rideId, RideProvider provider) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.t('cancel_ride')),
        content: Text(l.t('cancel_ride_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l.t('no_label')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final success = await provider.cancelRide(rideId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.t('ride_cancelled')),
                    backgroundColor: ColorTokens.error50,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.error50,
            ),
            child: Text(
              l.t('yes_cancel'),
              style: TextStyle(color: ColorTokens.neutral100),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupInfoWidget extends StatelessWidget {
  final RideModel ride;

  const GroupInfoWidget({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, provider, child) {
        final l = Provider.of<LocaleNotifier>(context);
        return FutureBuilder<Map<String, dynamic>?>(
          future: provider.getGroupInfo(ride.groupId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: ColorTokens.neutral60,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ColorTokens.primary30,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        l.t('loading_group_info'),
                        style: TextStyle(color: ColorTokens.neutral60),
                      ),
                    ],
                  ),
                ),
              );
            }

            final groupInfo = snapshot.data;
            if (groupInfo == null) {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: ColorTokens.neutral60,
                        child: Icon(Icons.group, color: ColorTokens.neutral60),
                      ),
                      SizedBox(width: 12),
                      Text(
                        l.t('group_not_found'),
                        style: TextStyle(color: ColorTokens.neutral60),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Card(
              child: InkWell(
                onTap: () {
                  context.push('/groups/${groupInfo['id']}');
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      groupInfo['imageUrl'] != null
                          ? ClipOval(
                              child: OptimizedNetworkImage(
                                imageUrl: groupInfo['imageUrl'],
                                width: 50,
                                height: 50,
                                imageType:
                                    'avatar', // Cache de larga duración para logos
                                fit: BoxFit.cover,
                              ),
                            )
                          : CircleAvatar(
                              radius: 25,
                              backgroundColor: ColorTokens.primary30,
                              child: Icon(
                                Icons.group,
                                color: ColorTokens.neutral100,
                                size: 28,
                              ),
                            ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.group,
                                  size: 16,
                                  color: ColorTokens.neutral60,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  l.t('organized_by'),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              groupInfo['name'],
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (groupInfo['memberCount'] > 0) ...[
                              SizedBox(height: 2),
                              Text(
                                '${groupInfo['memberCount']} ${l.t('members')}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            // Mostrar líder de la rodada
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 14,
                                  color: ColorTokens.primary50,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  l.t('ride_leader'),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: ColorTokens.primary50,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: ColorTokens.neutral60,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class BasicInfoWidget extends StatelessWidget {
  final RideModel ride;

  const BasicInfoWidget({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.t('ride_info'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            InfoRowWidget(
              icon: Icons.calendar_today,
              label: l.t('date_and_time'),
              value: _formatDateTime(context, ride.dateTime),
            ),
            SizedBox(height: 12),
            InfoRowWidget(
              icon: Icons.straighten,
              label: l.t('distance'),
              value: '${ride.kilometers} km',
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.trending_up, color: ColorTokens.neutral60),
                SizedBox(width: 12),
                Flexible(
                  child: Text(
                    '${l.t('difficulty')}: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: ColorTokens.neutral60,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(ride.difficulty),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDifficultyName(context, ride.difficulty),
                    style: TextStyle(
                      color: ColorTokens.neutral100,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            InfoRowWidget(
              icon: Icons.flag,
              label: l.t('status_label'),
              value: _getStatusName(context, ride.status),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final weekdays = [
      l.t('weekday_mon'),
      l.t('weekday_tue'),
      l.t('weekday_wed'),
      l.t('weekday_thu'),
      l.t('weekday_fri'),
      l.t('weekday_sat'),
      l.t('weekday_sun'),
    ];
    final months = [
      l.t('month_january_full'),
      l.t('month_february_full'),
      l.t('month_march_full'),
      l.t('month_april_full'),
      l.t('month_may_full'),
      l.t('month_june_full'),
      l.t('month_july_full'),
      l.t('month_august_full'),
      l.t('month_september_full'),
      l.t('month_october_full'),
      l.t('month_november_full'),
      l.t('month_december_full'),
    ];

    final weekday = weekdays[dateTime.weekday - 1];
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$weekday, $day ${l.t('date_of')} $month - $hour:$minute';
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return ColorTokens.success50;
      case DifficultyLevel.medium:
        return ColorTokens.warning50;
      case DifficultyLevel.hard:
        return ColorTokens.error50;
      case DifficultyLevel.expert:
        return ColorTokens.primary60;
    }
  }

  String _getDifficultyName(BuildContext context, DifficultyLevel difficulty) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    switch (difficulty) {
      case DifficultyLevel.easy:
        return l.t('difficulty_easy');
      case DifficultyLevel.medium:
        return l.t('difficulty_medium');
      case DifficultyLevel.hard:
        return l.t('difficulty_hard');
      case DifficultyLevel.expert:
        return l.t('difficulty_expert');
    }
  }

  String _getStatusName(BuildContext context, RideStatus status) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    switch (status) {
      case RideStatus.upcoming:
        return l.t('status_upcoming');
      case RideStatus.ongoing:
        return l.t('status_ongoing');
      case RideStatus.completed:
        return l.t('status_completed');
      case RideStatus.cancelled:
        return l.t('status_cancelled');
    }
  }
}

class MeetingPointInfoWidget extends StatelessWidget {
  final MeetingPoint meetingPoint;

  const MeetingPointInfoWidget({Key? key, required this.meetingPoint})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.t('meeting_point'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            InfoRowWidget(
              icon: Icons.location_on,
              label: meetingPoint.name,
              value: meetingPoint.description,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/map'),
                    icon: Icon(Icons.map),
                    label: Text(l.t('view_on_map')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.primary30,
                      foregroundColor: ColorTokens.neutral100,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openInGoogleMaps(
                      meetingPoint.latitude,
                      meetingPoint.longitude,
                      meetingPoint.name,
                    ),
                    icon: Icon(Icons.map_outlined),
                    label: Text('Google Maps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.secondary50,
                      foregroundColor: ColorTokens.neutral100,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openInGoogleMaps(double lat, double lng, String label) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

class InfoSectionWidget extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const InfoSectionWidget({
    Key? key,
    required this.title,
    required this.content,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: ColorTokens.neutral60),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(content, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class ParticipantsSectionWidget extends StatelessWidget {
  final RideModel ride;

  const ParticipantsSectionWidget({Key? key, required this.ride})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.t('participants'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // ⭐ Botón de asistencia - visible para todos
            RideAttendanceButton(ride: ride),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ParticipantStatWidget(
                    label: l.t('confirmed_count'),
                    count: ride.participants.length,
                    color: ColorTokens.success40,
                    icon: Icons.check_circle,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ParticipantStatWidget(
                    label: l.t('maybe_count'),
                    count: ride.maybeParticipants.length,
                    color: ColorTokens.warning50,
                    icon: Icons.help,
                  ),
                ),
              ],
            ),
            if (ride.participants.isEmpty &&
                ride.maybeParticipants.isEmpty) ...[
              SizedBox(height: 16),
              Text(
                l.t('no_participants_yet'),
                style: TextStyle(
                  color: ColorTokens.neutral60,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ] else ...[
              SizedBox(height: 16),
              // Lista OPTIMIZADA de participantes usando metadata (sin consultas adicionales)
              RideAttendeesListOptimized(
                rideId: ride.id,
                confirmedMetadata: ride.participantsMetadata,
                maybeMetadata: ride.maybeParticipantsMetadata,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ParticipantStatWidget extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const ParticipantStatWidget({
    Key? key,
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

class InfoRowWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRowWidget({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ColorTokens.neutral60),
        SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: ColorTokens.neutral60,
          ),
        ),
        Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
      ],
    );
  }
}
