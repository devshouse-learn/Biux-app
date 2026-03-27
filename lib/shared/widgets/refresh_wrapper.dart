import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';

class RefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const RefreshWrapper({Key? key, required this.child, required this.onRefresh})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: ColorTokens.primary30,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      strokeWidth: 2.5,
      displacement: 40,
      child: child,
    );
  }
}
