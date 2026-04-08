import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/shop/domain/entities/seller_request_entity.dart';
import 'package:biux/features/shop/presentation/providers/seller_request_provider.dart';

/// Pantalla para gestionar solicitudes de vendedores (solo admins)
class SellerRequestsScreen extends StatefulWidget {
  const SellerRequestsScreen({super.key});

  @override
  State<SellerRequestsScreen> createState() => _SellerRequestsScreenState();
}

class _SellerRequestsScreenState extends State<SellerRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Inicializar el provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerRequestProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.user;

    // Verificar que sea admin
    if (currentUser?.isAdmin != true) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l.t('access_denied')),
          backgroundColor: ColorTokens.neutral0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l.t('admin_only_access'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(l.t('go_back')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shop'),
          tooltip: l.t('back_to_store'),
        ),
        title: Text(l.t('seller_requests')),
        backgroundColor: ColorTokens.neutral0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ColorTokens.secondary50,
          tabs: [
            Consumer<SellerRequestProvider>(
              builder: (context, provider, _) {
                if (provider.pendingCount > 0) {
                  return Badge(
                    label: Text('${provider.pendingCount}'),
                    child: Tab(
                      icon: const Icon(Icons.pending_actions),
                      text: l.t('pending'),
                    ),
                  );
                }
                return Tab(
                  icon: const Icon(Icons.pending_actions),
                  text: l.t('pending'),
                );
              },
            ),
            Tab(icon: const Icon(Icons.check_circle), text: l.t('approved')),
            Tab(icon: const Icon(Icons.cancel), text: l.t('rejected_tab')),
          ],
        ),
      ),
      body: Consumer<SellerRequestProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.requests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Pendientes
              _buildRequestsList(
                provider.requests.where((r) => r.isPending).toList(),
                currentUser!.uid,
                true,
              ),
              // Aprobadas
              _buildRequestsList(
                provider.requests.where((r) => r.isApproved).toList(),
                currentUser.uid,
                false,
              ),
              // Rechazadas
              _buildRequestsList(
                provider.requests.where((r) => r.isRejected).toList(),
                currentUser.uid,
                false,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestsList(
    List<SellerRequestEntity> requests,
    String adminId,
    bool canReview,
  ) {
    final l = Provider.of<LocaleNotifier>(context);
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l.t('no_requests'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // El provider ya se actualiza automáticamente con streams
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(request, adminId, canReview);
        },
      ),
    );
  }

  Widget _buildRequestCard(
    SellerRequestEntity request,
    String adminId,
    bool canReview,
  ) {
    final l = Provider.of<LocaleNotifier>(context);
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: request.isPending
              ? Colors.orange
              : request.isApproved
              ? Colors.green
              : Colors.red,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con foto y nombre
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: request.userPhoto.isNotEmpty
                      ? NetworkImage(request.userPhoto)
                      : null,
                  child: request.userPhoto.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        request.userEmail,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Badge de estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: request.isPending
                        ? Colors.orange
                        : request.isApproved
                        ? Colors.green
                        : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        request.status.emoji,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l.t(request.status.displayName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mensaje
            Text(
              l.t('message_label'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                request.message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),

            // Fecha de creación
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${l.t('requested_on')} ${dateFormat.format(request.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            // Si fue revisada, mostrar info
            if (request.reviewedAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    request.isApproved ? Icons.check : Icons.close,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${l.t('reviewed_on')} ${dateFormat.format(request.reviewedAt!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (request.reviewComment != null) ...[
                const SizedBox(height: 8),
                Text(
                  l.t('admin_comment'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.reviewComment!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],

            // Botones de acción (solo si está pendiente)
            if (canReview && request.isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApproveDialog(request, adminId),
                      icon: const Icon(Icons.check),
                      label: Text(l.t('approve')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRejectDialog(request, adminId),
                      icon: const Icon(Icons.close),
                      label: Text(l.t('reject')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(SellerRequestEntity request, String adminId) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final commentController = TextEditingController(
      text: l.t('default_approve_comment'),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('approve_request')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l.t('confirm_approve_request_of')} ${request.userName}?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l.t('comment_optional'),
                border: const OutlineInputBorder(),
                hintText: l.t('add_comment_hint'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<SellerRequestProvider>();
              final success = await provider.approveRequest(
                requestId: request.id,
                adminId: adminId,
                comment: commentController.text.trim(),
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '✅ ${l.t('request_approved')}'
                          : '❌ ${l.t('error_approving')}',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(l.t('approve')),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(SellerRequestEntity request, String adminId) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('reject_request')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l.t('confirm_reject_request_of')} ${request.userName}?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l.t('rejection_reason'),
                border: const OutlineInputBorder(),
                hintText: l.t('indicate_reason_hint'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (commentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.t('indicate_rejection_reason')),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              final provider = context.read<SellerRequestProvider>();
              final success = await provider.rejectRequest(
                requestId: request.id,
                adminId: adminId,
                comment: commentController.text.trim(),
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '❌ ${l.t('request_rejected')}'
                          : '❌ ${l.t('error_rejecting')}',
                    ),
                    backgroundColor: success ? Colors.orange : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l.t('reject')),
          ),
        ],
      ),
    );
  }
}
