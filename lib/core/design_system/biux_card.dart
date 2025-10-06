import 'package:flutter/material.dart';

class BiuxCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool showBorder;

  const BiuxCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.showBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    return Container(
      margin: margin,
      child: Material(
        color: backgroundColor ?? colorScheme.surface,
        elevation: elevation ?? (theme.brightness == Brightness.dark ? 2 : 1),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: Container(
            decoration: showBorder
                ? BoxDecoration(
                    borderRadius: borderRadius ?? BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  )
                : null,
            child: cardContent,
          ),
        ),
      ),
    );
  }
}
