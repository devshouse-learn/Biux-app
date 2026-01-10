import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Botón del carrito con badge de cantidad
class CartButton extends StatelessWidget {
  final int itemCount;
  final VoidCallback onPressed;

  const CartButton({Key? key, required this.itemCount, required this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            itemCount > 0 ? Icons.shopping_cart : Icons.shopping_cart_outlined,
            color: Colors.white,
          ),
          if (itemCount > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ColorTokens.secondary50,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  itemCount > 99 ? '99+' : itemCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
