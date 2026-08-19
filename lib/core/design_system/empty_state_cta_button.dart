import 'package:flutter/material.dart';
import 'package:biux/core/design_system/biux_button.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Botón CTA especializado para empty states.
/// Diseñado para ser visualmente prominente y atractivo.
class EmptyStateCTAButton extends StatefulWidget {
  /// Texto del botón
  final String text;

  /// Callback al presionar
  final VoidCallback onPressed;

  /// Icono del botón
  final IconData? icon;

  /// Si está en estado de carga
  final bool isLoading;

  /// Tipo de botón (primary, secondary, danger, success)
  final BiuxButtonType type;

  const EmptyStateCTAButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.type = BiuxButtonType.primary,
  }) : super(key: key);

  @override
  State<EmptyStateCTAButton> createState() => _EmptyStateCTAButtonState();
}

class _EmptyStateCTAButtonState extends State<EmptyStateCTAButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: _getColorForType().withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: BiuxButton(
          text: widget.text,
          onPressed: widget.isLoading
              ? null
              : () {
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                  widget.onPressed();
                },
          type: widget.type,
          size: BiuxButtonSize.large,
          isLoading: widget.isLoading,
          leadingIcon: widget.icon,
          isFullWidth: true,
        ),
      ),
    );
  }

  Color _getColorForType() {
    switch (widget.type) {
      case BiuxButtonType.primary:
        return ColorTokens.primary30;
      case BiuxButtonType.secondary:
        return ColorTokens.primary50;
      case BiuxButtonType.danger:
        return ColorTokens.error50;
      case BiuxButtonType.success:
        return ColorTokens.success40;
    }
  }
}
