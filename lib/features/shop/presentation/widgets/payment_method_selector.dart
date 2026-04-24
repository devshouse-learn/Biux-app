import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

/// Enum de métodos de pago disponibles
enum PaymentMethod {
  pse('payment_pse', Icons.account_balance, 'payment_pse_desc'),
  creditCard(
    'payment_credit_card',
    Icons.credit_card,
    'payment_credit_card_desc',
  ),
  debitCard('payment_debit_card', Icons.payment, 'payment_debit_card_desc'),
  nequi('payment_nequi', Icons.phone_android, 'payment_nequi_desc'),
  daviplata('payment_daviplata', Icons.phone_iphone, 'payment_daviplata_desc');

  final String labelKey;
  final IconData icon;
  final String descriptionKey;

  const PaymentMethod(this.labelKey, this.icon, this.descriptionKey);
}

/// Widget para seleccionar método de pago
class PaymentMethodSelector extends StatefulWidget {
  final PaymentMethod? selectedMethod;
  final ValueChanged<PaymentMethod> onMethodSelected;

  const PaymentMethodSelector({
    Key? key,
    this.selectedMethod,
    required this.onMethodSelected,
  }) : super(key: key);

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            l.t('payment_method_label'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        // Lista de métodos de pago
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: PaymentMethod.values.asMap().entries.map((entry) {
              final index = entry.key;
              final method = entry.value;
              final isFirst = index == 0;
              final isLast = index == PaymentMethod.values.length - 1;
              final isSelected = widget.selectedMethod == method;

              return _buildPaymentOption(
                method: method,
                isSelected: isSelected,
                isFirst: isFirst,
                isLast: isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Construye una opción de método de pago
  Widget _buildPaymentOption({
    required PaymentMethod method,
    required bool isSelected,
    required bool isFirst,
    required bool isLast,
  }) {
    final l = Provider.of<LocaleNotifier>(context);
    return Material(
      color: isSelected
          ? ColorTokens.primary30.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(11) : Radius.zero,
        bottom: isLast ? const Radius.circular(11) : Radius.zero,
      ),
      child: InkWell(
        onTap: () => widget.onMethodSelected(method),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(11) : Radius.zero,
          bottom: isLast ? const Radius.circular(11) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: !isLast
                ? Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1))
                : null,
          ),
          child: Row(
            children: [
              // Icono del método
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? ColorTokens.primary30 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  method.icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 24,
                ),
              ),

              SizedBox(width: 16),

              // Información del método
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.t(method.labelKey),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isSelected
                            ? ColorTokens.primary30
                            : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      l.t(method.descriptionKey),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Indicador de selección
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? ColorTokens.primary30
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected
                      ? ColorTokens.primary30
                      : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget simplificado para usar en diálogos
class CompactPaymentMethodSelector extends StatelessWidget {
  final PaymentMethod? selectedMethod;
  final ValueChanged<PaymentMethod?> onChanged;

  const CompactPaymentMethodSelector({
    Key? key,
    this.selectedMethod,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return DropdownButtonFormField<PaymentMethod>(
      initialValue: selectedMethod,
      decoration: InputDecoration(
        labelText: l.t('payment_method_label'),
        prefixIcon: Icon(Icons.payment),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      hint: Text(l.t('select_method')),
      items: PaymentMethod.values.map((method) {
        return DropdownMenuItem(
          value: method,
          child: Row(
            children: [
              Icon(method.icon, size: 20),
              SizedBox(width: 12),
              Text(l.t(method.labelKey)),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return l.t('select_payment_method_error');
        }
        return null;
      },
    );
  }
}
