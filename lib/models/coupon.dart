// lib/models/coupon.dart
// استبدل الملف الحالي بالكامل

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
  final String country;

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
    this.country = '',
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    final store = json['store'] as Map<String, dynamic>?;

    // ✅ logo من store.logo_url
    final storeLogo = store?['logo_url']?.toString() ?? '';

    // ✅ صورة الكوبون من card_image أو image_url
    final couponImage =
        json['card_image']?.toString() ?? json['image_url']?.toString() ?? '';

    // ✅ رابط المتجر من store.url أو link
    final storeUrl =
        store?['url']?.toString() ?? json['link']?.toString() ?? '';

    // ✅ نسبة الخصم من discount (string مثل "20%")
    final discountRaw =
        (json['discount'] ?? '0').toString().replaceAll('%', '').trim();
    final discountPercent = int.tryParse(discountRaw) ?? 0;

    return Coupon(
      id: (json['id'] ?? '').toString(),
      storeId: (json['store_id'] ?? store?['id'] ?? '').toString(),
      storeName: store?['name']?.toString() ?? '',
      storeLogo: storeLogo,
      storeImage: couponImage.isNotEmpty ? couponImage : storeLogo,
      title: json['title']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      expiryText: json['duration_label']?.toString() ?? 'غير محدد',
      badge: json['badge']?.toString() ?? 'مميز',
      storeUrl: storeUrl,
      discountPercent: discountPercent,
      category: store?['category']?.toString() ?? 'عام',
      country: json['country_label']?.toString() ??
          store?['country']?.toString() ??
          '',
    );
  }
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

  factory Store.fromJson(Map<String, dynamic> json) {
    // ✅ offers بيستخدموا image_url — stores بيستخدموا logo_url
    final logo = json['image_url']?.toString() ??
        json['logo_url']?.toString() ??
        json['logo']?.toString() ??
        '';

    return Store(
      id: (json['id'] ?? '').toString(),
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      logoUrl: logo,
      url: json['url']?.toString() ?? json['link']?.toString() ?? '',
    );
  }
}
