import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const ProductCard({Key? key, required this.product, required this.onTap})
    : super(key: key);

  Widget _buildImage() {
    final url = product.mainImage;
    if (url.isEmpty) {
      return Container(color: Colors.grey[200], child: const Icon(Icons.shopping_bag, size: 50, color: Colors.grey));
    }
    if (url.startsWith('asset://')) {
      return Image.asset(url.replaceFirst('asset://', ''), width: double.infinity, height: double.infinity, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.shopping_bag, size: 50, color: Colors.grey)));
    }
    if (url.startsWith('mock://')) {
      return Container(color: Colors.grey[200], child: const Icon(Icons.shopping_bag, size: 50, color: Colors.grey));
    }
    return CachedNetworkImage(imageUrl: url, width: double.infinity, fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
      errorWidget: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.shopping_bag, size: 50, color: Colors.grey)));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'local_user';
    debugPrint('LIKE_CARD>>> uid=$uid');
    debugPrint('LIKE_CARD>>> uid=$uid');

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: SizedBox(width: double.infinity, height: double.infinity, child: _buildImage()),
                  ),
                  // Boton de like
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _LikeButton(product: product, userId: uid),
                    ),
                  if (product.stock < 5 && product.stock > 0)
                    Positioned(top: 8, left: 8, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                      child: Text('Ultimas ${product.stock}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    )),
                  if (product.stock == 0)
                    Positioned(top: 8, left: 8, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                      child: const Text('Agotado', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    )),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${product.price.toStringAsFixed(0)}', style: TextStyle(color: ColorTokens.secondary50, fontWeight: FontWeight.bold, fontSize: 16)),
                        if (product.sizes.isNotEmpty)
                          Text('Tallas', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget separado para el boton de like - usa Consumer para reactividad
class _LikeButton extends StatelessWidget {
  final ProductEntity product;
  final String userId;

  const _LikeButton({required this.product, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, _) {
        // Obtener el producto actualizado del provider
        final updatedProduct = shopProvider.products
            .where((p) => p.id == product.id)
            .firstOrNull;
        final isLiked = updatedProduct?.isLikedBy(userId) ?? product.isLikedBy(userId);

        return GestureDetector(
          onTap: () {
            shopProvider.toggleProductLike(product.id, userId);
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)],
            ),
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.grey,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}
