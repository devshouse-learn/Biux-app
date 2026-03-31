/// Estadísticas generales de la tienda
class ShopStatsEntity {
  final int totalProducts;
  final int totalSellers;
  final int totalOrders;
  final int pendingRequests;
  final int activeListings;
  final int soldProducts;
  final int reportedProducts;
  final int stolenBikes;
  final double totalRevenue;
  final Map<String, int> productsByCategory;
  final Map<String, int> salesByMonth;
  final List<TopSellerInfo> topSellers;
  final List<PopularProductInfo> popularProducts;

  const ShopStatsEntity({
    this.totalProducts = 0,
    this.totalSellers = 0,
    this.totalOrders = 0,
    this.pendingRequests = 0,
    this.activeListings = 0,
    this.soldProducts = 0,
    this.reportedProducts = 0,
    this.stolenBikes = 0,
    this.totalRevenue = 0.0,
    this.productsByCategory = const {},
    this.salesByMonth = const {},
    this.topSellers = const [],
    this.popularProducts = const [],
  });
}

class TopSellerInfo {
  final String sellerId;
  final String sellerName;
  final int productsSold;
  final double totalRevenue;
  final double rating;

  const TopSellerInfo({
    required this.sellerId,
    required this.sellerName,
    this.productsSold = 0,
    this.totalRevenue = 0.0,
    this.rating = 0.0,
  });
}

class PopularProductInfo {
  final String productId;
  final String productName;
  final String imageUrl;
  final int views;
  final int likes;
  final double price;

  const PopularProductInfo({
    required this.productId,
    required this.productName,
    this.imageUrl = '',
    this.views = 0,
    this.likes = 0,
    this.price = 0.0,
  });
}
