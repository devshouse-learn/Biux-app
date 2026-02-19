import 'package:flutter/material.dart';

const _kPrimaryColor = Color(0xFF16242D);

/// Widget de información general de la tienda, políticas y ayuda
class ShopInfoWidget extends StatelessWidget {
  const ShopInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16242D), Color(0xFF2A4A5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Tienda Biux',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.white, size: 8),
                    SizedBox(width: 4),
                    Text(
                      'Abierta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Compra y vende accesorios, repuestos y equipamiento para ciclismo. Todo verificado por nuestra comunidad.',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoBadge(Icons.verified_user, 'Verificados'),
              const SizedBox(width: 8),
              _buildInfoBadge(Icons.security, 'Compra Segura'),
              const SizedBox(width: 8),
              _buildInfoBadge(Icons.group, 'Comunidad'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showPoliciesDialog(context),
                  icon: const Icon(Icons.policy, size: 16),
                  label: const Text(
                    'Políticas',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showHelpDialog(context),
                  icon: const Icon(Icons.help_outline, size: 16),
                  label: const Text('Ayuda', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _showPoliciesDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const Text(
                '📋 Políticas de la Tienda',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _kPrimaryColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildPolicySection('🛒 Compras', [
                'Las transacciones se realizan directamente entre compradores y vendedores.',
                'Biux actúa como intermediario de contacto, no procesamos pagos.',
                'Verifica los productos antes de completar la compra.',
              ]),
              _buildPolicySection('📦 Envíos', [
                'Los envíos son coordinados entre comprador y vendedor.',
                'Se recomienda usar servicios de envío con seguimiento.',
                'El vendedor es responsable del empaque adecuado.',
              ]),
              _buildPolicySection('🔄 Devoluciones', [
                'Aplica política de devolución de cada vendedor.',
                'Reporta cualquier problema dentro de las 48 horas.',
                'Se recomienda documentar el estado del producto al recibirlo.',
              ]),
              _buildPolicySection('🚫 Prohibiciones', [
                'No se permite vender productos falsificados.',
                'No se permiten productos ilegales o robados.',
                'Las cuentas fraudulentas serán eliminadas.',
              ]),
              _buildPolicySection('🔐 Privacidad', [
                'Tu información personal está protegida.',
                'No compartimos datos con terceros.',
                'Puedes eliminar tu cuenta en cualquier momento.',
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _kPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('  •  ', style: TextStyle(color: Colors.grey)),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const Text(
              '❓ Centro de Ayuda',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _kPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              Icons.shopping_bag,
              '¿Cómo comprar?',
              'Navega por categorías, selecciona un producto y contacta al vendedor.',
            ),
            _buildHelpItem(
              Icons.sell,
              '¿Cómo vender?',
              'Solicita permiso de vendedor desde el menú. Un admin aprobará tu solicitud.',
            ),
            _buildHelpItem(
              Icons.report,
              '¿Cómo reportar?',
              'Usa la sección de Reportes para informar productos o vendedores.',
            ),
            _buildHelpItem(
              Icons.security,
              '¿Es seguro?',
              'Todos los vendedores son verificados y los productos son revisados.',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kPrimaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _kPrimaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
