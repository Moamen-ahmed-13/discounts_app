
class Coupon {
  final String id;
  final String storeId;
  final String storeName;
  final String storeLogo;
  final String storeImage;
  final String title;
  final String code;
  final String expiryText;
  final String badge; 
  final String storeUrl;
  final int discountPercent;
  final String category;

  Coupon({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.storeLogo,
    required this.storeImage,
    required this.title,
    required this.code,
    required this.expiryText,
    required this.badge,
    required this.storeUrl,
    required this.discountPercent,
    required this.category,
  });
}

class Store {
  final String id;
  final String name;
  final String logoUrl;
  final String url;

  Store({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.url,
  });
}
