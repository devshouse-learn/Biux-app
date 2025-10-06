import 'package:flutter/material.dart';
import 'color_tokens.dart';

enum BiuxButtonType { primary, secondary, danger, success }

enum BiuxButtonSize { small, medium, large }

class BiuxButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final BiuxButtonType type;
  final BiuxButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const BiuxButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = BiuxButtonType.primary,
    this.size = BiuxButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color foregroundColor;
    switch (type) {
      case BiuxButtonType.primary:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
      case BiuxButtonType.secondary:
        backgroundColor = colorScheme.secondary;
        foregroundColor = colorScheme.onSecondary;
        break;
      case BiuxButtonType.danger:
        backgroundColor = colorScheme.error;
        foregroundColor = colorScheme.onError;
        break;
      case BiuxButtonType.success:
        backgroundColor = ColorTokens.success40;
        foregroundColor = Colors.white;
        break;
    }

    double verticalPadding;
    double horizontalPadding;
    double fontSize;
    double iconSize;
    double minHeight;
    switch (size) {
      case BiuxButtonSize.small:
        verticalPadding = 8;
        horizontalPadding = 16;
        fontSize = 14;
        iconSize = 18;
        minHeight = 32;
        break;
      case BiuxButtonSize.medium:
        verticalPadding = 12;
        horizontalPadding = 24;
        fontSize = 16;
        iconSize = 20;
        minHeight = 44;
        break;
      case BiuxButtonSize.large:
        verticalPadding = 16;
        horizontalPadding = 32;
        fontSize = 18;
        iconSize = 24;
        minHeight = 56;
        break;
    }

    final buttonChild = isLoading
        ? SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: iconSize, color: foregroundColor),
                SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
              if (trailingIcon != null) ...[
                SizedBox(width: 8),
                Icon(trailingIcon, size: iconSize, color: foregroundColor),
              ],
            ],
          );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: Size(isFullWidth ? double.infinity : 0, minHeight),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
      ),
      child: buttonChild,
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
