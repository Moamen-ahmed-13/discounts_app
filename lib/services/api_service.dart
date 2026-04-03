import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coupon.dart';
import '../models/api_models.dart';

class ApiService {
  static const String baseUrl = 'https://couponey.net';
  static const String _oldBaseUrl = 'https://coupons.bioagency.net';

  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // ─── Full bundle ──────────────────────────────────────────────────
  static Future<HomeBundle> fetchHome() async {
    final res = await http
        .get(Uri.parse('$baseUrl/api/home'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) return HomeBundle.fromJson(jsonDecode(res.body));
    throw Exception('فشل تحميل البيانات (${res.statusCode})');
  }

  // ─── Stores ───────────────────────────────────────────────────────
  static Future<List<Store>> fetchStores() async {
    final res = await http
        .get(Uri.parse('$baseUrl/api/stores'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] ?? data['stores'] ?? []);
      return (list as List).map((e) => Store.fromJson(e)).toList();
    }
    throw Exception('فشل تحميل المتاجر (${res.statusCode})');
  }

  // ─── Coupons ──────────────────────────────────────────────────────
  static Future<List<Coupon>> fetchCoupons({String type = 'latest'}) async {
    final res = await http
        .get(Uri.parse('$baseUrl/api/coupons/$type'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final list =
          data is List ? data : (data['data'] ?? data['coupons'] ?? []);
      return (list as List).map((e) => Coupon.fromJson(e)).toList();
    }
    throw Exception('فشل تحميل الكوبونات (${res.statusCode})');
  }

  // ─── Offers ───────────────────────────────────────────────────────
  static Future<List<Store>> fetchOffers() async {
    final res = await http
        .get(Uri.parse('$baseUrl/api/offers'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] ?? data['offers'] ?? []);
      return (list as List).map((e) => Store.fromJson(e)).toList();
    }
    throw Exception('فشل تحميل العروض (${res.statusCode})');
  }

  // ─── Stores for filters ───────────────────────────────────────────
  static Future<List<String>> fetchStoresForFilters() async {
    final res = await http
        .get(Uri.parse('$baseUrl/api/stores/for-filters'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] ?? []);
      return (list as List).map((e) => e['name']?.toString() ?? '').toList();
    }
    throw Exception('فشل تحميل فلاتر المتاجر (${res.statusCode})');
  }

  // ─── Newsletter Subscribe ─────────────────────────────────────────
  // بيجرب الـ domains الاتنين
  static Future<bool> subscribeNewsletter(String email) async {
    final urls = [
      '$baseUrl/api/newsletter/subscribe',
      '$_oldBaseUrl/api/newsletter/subscribe',
      '$baseUrl/api/subscribers',
      '$_oldBaseUrl/api/subscribers',
      '$baseUrl/api/subscribe',
      '$_oldBaseUrl/api/subscribe',
    ];

    for (final url in urls) {
      try {
        final res = await http
            .post(
              Uri.parse(url),
              headers: _headers,
              body: jsonEncode({'email': email}),
            )
            .timeout(const Duration(seconds: 8));

        if (res.statusCode == 200 || res.statusCode == 201) {
          return true;
        }
        if (res.statusCode == 404 || res.statusCode == 405) continue;

        // status آخر - اقرأ الـ message
        try {
          final data = jsonDecode(res.body);
          final msg = data['message']?.toString() ?? '';
          if (msg.isNotEmpty && !msg.toLowerCase().contains('not found')) {
            throw Exception(msg);
          }
        } catch (_) {}
        continue;
      } catch (e) {
        final err = e.toString().toLowerCase();
        if (err.contains('not found') ||
            err.contains('404') ||
            err.contains('timeout')) {
          continue;
        }
        rethrow;
      }
    }

    // كل الـ endpoints فشلت - الـ route مش موجود في الـ backend
    // ابعت رسالة للـ developer عشان يضيف الـ route
    throw Exception('backend_missing_route');
  }

  // ─── Labels ───────────────────────────────────────────────────────
  static Future<Map<String, List<String>>> fetchLabels() async {
    final res = await http
        .get(Uri.parse('$baseUrl/api/labels'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      List<String> parseList(dynamic v) {
        if (v == null) return [];
        if (v is List)
          return v.map((e) => e['name']?.toString() ?? e.toString()).toList();
        return [];
      }

      return {
        'countries': parseList(data['countries'] ?? data['country']),
        'durations': parseList(data['durations'] ?? data['duration']),
      };
    }
    throw Exception('فشل تحميل التصنيفات (${res.statusCode})');
  }
}
