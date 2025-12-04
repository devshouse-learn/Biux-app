import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Widget de etiqueta de precio con formato
class PriceTag extends StatelessWidget {
  final double price;
  final bool showCurrency;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const PriceTag({
    Key? key,
    required this.price,
    this.showCurrency = true,
    this.fontSize = 20,
    this.fontWeight = FontWeight.bold,
    this.color,
  }) : super(key: key);

  String _formatPrice(double price) {
    // Formato colombiano: $45.000
    final parts = price.toStringAsFixed(0).split('');
    final reversed = parts.reversed.toList();
    final withDots = <String>[];
    
    for (var i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        withDots.add('.');
      }
      withDots.add(reversed[i]);
    }
    
    return withDots.reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      showCurrency ? '\$${_formatPrice(price)}' : _formatPrice(price),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? ColorTokens.secondary50,
      ),
    );
  }
}

/// Etiqueta de precio pequeña para tarjetas
class SmallPriceTag extends StatelessWidget {
  final double price;

  const SmallPriceTag({
    Key? key,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PriceTag(
      price: price,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
  }
}

/// Etiqueta de precio grande para detalles
class LargePriceTag extends StatelessWidget {
  final double price;

  const LargePriceTag({
    Key? key,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PriceTag(
      price: price,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    );
  }
}
