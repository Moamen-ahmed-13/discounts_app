// lib/models/api_models.dart
// ملف جديد — حطه في lib/models/

import 'coupon.dart';

/// الـ response الكامل من /api/home
class HomeBundle {
  final List<Store> stores;
  final List<Store> offers; // للـ featured slider
  final List<Coupon> coupons;
  final SiteInfo? site;

  HomeBundle({
    required this.stores,
    required this.offers,
    required this.coupons,
    this.site,
  });

  factory HomeBundle.fromJson(Map<String, dynamic> json) {
    List<Store> parseStores(dynamic raw) {
      if (raw == null) return [];
      final list = raw is List ? raw : (raw['data'] ?? []);
      return (list as List).map((e) => Store.fromJson(e)).toList();
    }

    List<Coupon> parseCoupons(dynamic raw) {
      if (raw == null) return [];
      // ✅ الـ API بيرجع coupons كـ object فيه most_used/latest/high_discount
      if (raw is Map) {
        final latest = raw['latest'] ?? raw['most_used'] ?? raw['high_discount'] ?? [];
        return (latest as List).map((e) => Coupon.fromJson(e)).toList();
      }
      if (raw is List) return raw.map((e) => Coupon.fromJson(e)).toList();
      return [];
    }

    return HomeBundle(
      stores: parseStores(json['stores']),
      // ✅ offers بييجي كـ list مباشرة
      offers: parseStores(json['offers']),
      coupons: parseCoupons(json['coupons']),
      site: json['site'] != null ? SiteInfo.fromJson(json['site']) : null,
    );
  }
}

class SiteInfo {
  final String name;
  final String tagline;
  final String? logoUrl;

  SiteInfo({required this.name, required this.tagline, this.logoUrl});

  factory SiteInfo.fromJson(Map<String, dynamic> json) => SiteInfo(
        name: json['name'] ?? '',
        tagline: json['tagline'] ?? '',
        logoUrl: json['logo'],
      );
}