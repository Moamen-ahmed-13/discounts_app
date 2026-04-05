import 'coupon.dart';

class HomeBundle {
  final List<Store> stores;
  final List<Store> offers;
  final List<Coupon> coupons;
  final SiteInfo? site;
  final HeroData? hero;

  HomeBundle({required this.stores, required this.offers, required this.coupons, this.site, this.hero});

  factory HomeBundle.fromJson(Map<String, dynamic> json) {
    List<Store> parseStores(dynamic raw) {
      if (raw == null) return [];
      final list = raw is List ? raw : (raw['data'] ?? []);
      return (list as List).map((e) => Store.fromJson(e)).toList();
    }

    List<Coupon> parseCoupons(dynamic raw) {
      if (raw == null) return [];
      if (raw is Map) {
        final all = <Coupon>[];
        final seen = <String>{};
        for (final key in ['latest', 'most_used', 'high_discount']) {
          final items = raw[key];
          if (items is List) {
            for (final e in items) {
              final c = Coupon.fromJson(e);
              if (seen.add(c.id)) all.add(c);
            }
          }
        }
        return all;
      }
      if (raw is List) return raw.map((e) => Coupon.fromJson(e)).toList();
      return [];
    }

    return HomeBundle(
      stores: parseStores(json['stores']),
      offers: parseStores(json['offers']),
      coupons: parseCoupons(json['coupons']),
      site: json['site'] != null ? SiteInfo.fromJson(json['site']) : null,
      hero: json['hero'] != null ? HeroData.fromJson(json['hero']) : null,
    );
  }
}

// ─── Site Info (/api/site) ────────────────────────────────────────
class SiteInfo {
  final String name;
  final String tagline;
  final String? logoUrl;
  final String? logoWhiteUrl;
  // السوشيال ميديا من الـ site
  final String? facebookUrl;
  final String? instagramUrl;
  final String? tiktokUrl;
  final String? whatsappUrl;
  final String? twitterUrl;

  SiteInfo({
    required this.name,
    required this.tagline,
    this.logoUrl,
    this.logoWhiteUrl,
    this.facebookUrl,
    this.instagramUrl,
    this.tiktokUrl,
    this.whatsappUrl,
    this.twitterUrl,
  });

  factory SiteInfo.fromJson(Map<String, dynamic> json) {
    // السوشيال ميديا ممكن تيجي nested في social_links أو مباشرة
    final social = json['social_links'] as Map<String, dynamic>? ??
        json['social'] as Map<String, dynamic>? ?? {};

    return SiteInfo(
      name: json['name']?.toString() ?? json['site_name']?.toString() ?? '',
      tagline: json['tagline']?.toString() ?? json['description']?.toString() ?? '',
      logoUrl: json['logo']?.toString() ?? json['logo_url']?.toString(),
      logoWhiteUrl: json['logo_white']?.toString() ?? json['logo_w']?.toString(),
      facebookUrl: social['facebook']?.toString() ?? json['facebook']?.toString() ?? json['facebook_url']?.toString(),
      instagramUrl: social['instagram']?.toString() ?? json['instagram']?.toString() ?? json['instagram_url']?.toString(),
      tiktokUrl: social['tiktok']?.toString() ?? json['tiktok']?.toString() ?? json['tiktok_url']?.toString(),
      whatsappUrl: social['whatsapp']?.toString() ?? json['whatsapp']?.toString() ?? json['whatsapp_url']?.toString(),
      twitterUrl: social['twitter']?.toString() ?? json['twitter']?.toString() ?? json['twitter_url']?.toString(),
    );
  }
}

// ─── Hero Data (/api/hero - also footer) ─────────────────────────
class HeroData {
  final String title;
  final String description;
  final String? imageUrl;
  final String? bgImageUrl;
  // البانر messages اللي بتتدور
  final List<String> announcementMessages;
  // footer data
  final String? footerDescription;
  // السوشيال ميديا من الـ footer
  final String? facebookUrl;
  final String? instagramUrl;
  final String? tiktokUrl;
  final String? whatsappUrl;
  final String? twitterUrl;
  // footer logo
  final String? logoUrl;
  final String? logoWhiteUrl;

  HeroData({
    required this.title,
    required this.description,
    this.imageUrl,
    this.bgImageUrl,
    this.announcementMessages = const [],
    this.footerDescription,
    this.facebookUrl,
    this.instagramUrl,
    this.tiktokUrl,
    this.whatsappUrl,
    this.twitterUrl,
    this.logoUrl,
    this.logoWhiteUrl,
  });

  factory HeroData.fromJson(Map<String, dynamic> json) {
    // البانر ممكن يكون list في 'announcements' أو 'banners' أو 'marquee'
    List<String> parseMessages(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e['text']?.toString() ?? e['message']?.toString() ?? e.toString()).where((s) => s.isNotEmpty).toList();
      if (raw is String && raw.isNotEmpty) return [raw];
      return [];
    }

    // السوشيال ميديا ممكن تكون nested في social_links أو مباشرة
    final social = json['social_links'] as Map<String, dynamic>? ??
        json['social'] as Map<String, dynamic>? ?? {};

    return HeroData(
      title: json['title']?.toString() ?? json['heading']?.toString() ?? 'وفر أكثر مع كوبون X!',
      description: json['description']?.toString() ?? json['subtitle']?.toString() ?? json['text']?.toString() ?? '',
      imageUrl: json['image']?.toString() ?? json['image_url']?.toString() ?? json['hero_image']?.toString(),
      bgImageUrl: json['bg_image']?.toString() ?? json['background']?.toString() ?? json['background_image']?.toString(),
      announcementMessages: parseMessages(
        json['announcements'] ?? json['banners'] ?? json['marquee'] ?? json['messages'] ?? json['ticker'],
      ),
      footerDescription: json['footer_description']?.toString() ?? json['footer_text']?.toString(),
      facebookUrl: social['facebook']?.toString() ?? json['facebook']?.toString() ?? json['facebook_url']?.toString(),
      instagramUrl: social['instagram']?.toString() ?? json['instagram']?.toString() ?? json['instagram_url']?.toString(),
      tiktokUrl: social['tiktok']?.toString() ?? json['tiktok']?.toString() ?? json['tiktok_url']?.toString(),
      whatsappUrl: social['whatsapp']?.toString() ?? json['whatsapp']?.toString() ?? json['whatsapp_url']?.toString(),
      twitterUrl: social['twitter']?.toString() ?? json['twitter']?.toString() ?? json['twitter_url']?.toString(),
      logoUrl: json['logo']?.toString() ?? json['logo_url']?.toString(),
      logoWhiteUrl: json['logo_white']?.toString() ?? json['logo_w']?.toString(),
    );
  }
}

// ─── App Labels (/api/labels) ─────────────────────────────────────
class AppLabels {
  final List<String> countries;
  final List<String> durations;

  AppLabels({required this.countries, required this.durations});

  factory AppLabels.fromJson(Map<String, dynamic> json) {
    List<String> parse(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e['name']?.toString() ?? e['label']?.toString() ?? e.toString()).where((s) => s.isNotEmpty).toList();
      return [];
    }
    return AppLabels(
      countries: parse(json['countries'] ?? json['country']),
      durations: parse(json['durations'] ?? json['duration']),
    );
  }
}