import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/shop/domain/entities/order_entity.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, provider, _) {
        final order = provider.userOrders.where((o) => o.id == orderId).firstOrNull;
        if (order == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalle del pedido'),
              backgroundColor: ColorTokens.primary30,
            ),
            body: const Center(child: Text('Pedido no encontrado')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Pedido #\${order.id.substring(0, 8)}'),
            backgroundColor: ColorTokens.primary30,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusCard(order: order),
                const SizedBox(height: 16),
                _ItemsCard(order: order),
                const SizedBox(height: 16),
                _SummaryCard(order: order),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  final OrderEntity order;
  const _StatusCard({required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.processing: return Colors.blue;
      case OrderStatus.completed: return Colors.green;
      case OrderStatus.cancelled: return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    final date = DateFormat("dd MMM yyyy, HH:mm", "es").format(order.createdAt);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estado del pedido',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color),
              ),
              child: Text(
                OrderStatus.getDisplayName(order.status).toUpperCase(),
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            Text('Fecha: $date',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final OrderEntity order;
  const _ItemsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Productos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item.product.name,
                      style: const TextStyle(fontSize: 14))),
                  Text("x\${item.quantity}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(width: 8),
                  Text('\${item.product.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final OrderEntity order;
  const _SummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              '\${order.total.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: ColorTokens.primary30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
