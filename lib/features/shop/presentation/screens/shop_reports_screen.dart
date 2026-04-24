import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/shop/domain/entities/report_entity.dart';

const _kPrimaryColor = Color(0xFF16242D);

/// Pantalla de informes y reportes de la tienda
class ShopReportsScreen extends StatefulWidget {
  final bool isAdmin;

  const ShopReportsScreen({super.key, this.isAdmin = false});

  @override
  State<ShopReportsScreen> createState() => _ShopReportsScreenState();
}

class _ShopReportsScreenState extends State<ShopReportsScreen>
    with SingleTickerProviderStateMixin {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.isAdmin ? 3 : 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l.t('reports_and_info'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(icon: Icon(Icons.add_circle), text: l.t('new_report')),
            Tab(icon: Icon(Icons.list_alt), text: l.t('my_reports')),
            if (widget.isAdmin)
              Tab(
                icon: Icon(Icons.admin_panel_settings),
                text: l.t('admin'),
              ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewReportTab(),
          _buildMyReportsTab(),
          if (widget.isAdmin) _buildAdminReportsTab(),
        ],
      ),
    );
  }

  Widget _buildNewReportTab() {
    final l = Provider.of<LocaleNotifier>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.t('what_to_report'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _kPrimaryColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            l.t('select_report_type'),
            style: TextStyle(color: Colors.grey.shade600),
          ),
          SizedBox(height: 20),
          _buildReportTypeCard(
            ReportType.productReport,
            Icons.inventory_2,
            l.t('report_product'),
            l.t('report_product_desc'),
            Colors.orange,
          ),
          _buildReportTypeCard(
            ReportType.sellerReport,
            Icons.person_off,
            l.t('report_seller'),
            l.t('report_seller_desc'),
            Colors.red,
          ),
          _buildReportTypeCard(
            ReportType.orderIssue,
            Icons.local_shipping,
            l.t('order_issue'),
            l.t('order_issue_desc'),
            Colors.blue,
          ),
          _buildReportTypeCard(
            ReportType.securityAlert,
            Icons.security,
            l.t('security_alert'),
            l.t('security_alert_desc'),
            Colors.red.shade800,
          ),
          _buildReportTypeCard(
            ReportType.suggestion,
            Icons.lightbulb,
            l.t('suggestion'),
            l.t('suggestion_desc'),
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeCard(
    ReportType type,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        onTap: () => _showCreateReportDialog(type),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyReportsTab() {
    final l = Provider.of<LocaleNotifier>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_outlined, size: 80, color: Colors.grey.shade300),
            SizedBox(height: 16),
            Text(
              l.t('no_reports'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              l.t('no_reports_created'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminReportsTab() {
    final l = Provider.of<LocaleNotifier>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16),
            Text(
              l.t('admin_reports_panel'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBadge(l.t('pending'), '0', Colors.orange),
                _buildStatBadge(l.t('in_review'), '0', Colors.blue),
                _buildStatBadge(l.t('resolved'), '0', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  void _showCreateReportDialog(ReportType type) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(ctx).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getReportTitle(type),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: l.t('report_title_field'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: l.t('detailed_description'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.attach_file),
                  label: Text(l.t('attach_evidence')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ ${l.t('report_sent_success')}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: Icon(Icons.send),
                    label: Text(l.t('send_report')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getReportTitle(ReportType type) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    switch (type) {
      case ReportType.productReport:
        return '🏷️ ${l.t('report_product')}';
      case ReportType.sellerReport:
        return '👤 ${l.t('report_seller')}';
      case ReportType.orderIssue:
        return '📦 ${l.t('order_issue')}';
      case ReportType.securityAlert:
        return '🔒 ${l.t('security_alert')}';
      case ReportType.suggestion:
        return '💡 ${l.t('suggestion')}';
    }
  }
}
