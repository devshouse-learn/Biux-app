import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';

class BirthDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final Color? borderColor;

  const BirthDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.borderColor,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = selectedDate ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 5),
      helpText: 'Selecciona tu fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorTokens.primary30,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onDateSelected(picked);
  }

  String get _displayText {
    if (selectedDate == null) return 'Fecha de nacimiento *';
    final d = selectedDate!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? ColorTokens.neutral60),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, color: ColorTokens.neutral60),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _displayText,
                style: TextStyle(
                  fontSize: 14,
                  color: selectedDate == null
                      ? ColorTokens.neutral60
                      : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: ColorTokens.neutral60,
            ),
          ],
        ),
      ),
    );
  }
}
