import 'package:flutter/material.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';
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
                  if (product.stock < 5 && product.stock > 0)
                    Positioned(top: 8, right: 8, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                      child: Text('Ultimas ${product.stock}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    )),
                  if (product.stock == 0)
                    Positioned(top: 8, right: 8, child: Container(
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
                        if (product.likesCount > 0)
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.favorite, color: Colors.red, size: 14),
                            const SizedBox(width: 2),
                            Text('${product.likesCount}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ])
                        else if (product.sizes.isNotEmpty)
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
