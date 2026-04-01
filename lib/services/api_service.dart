import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coupon.dart';
import '../models/api_models.dart';

class ApiService {
  static const String baseUrl = 'https://coupons.bioagency.net';

  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // ─── Full bundle (كل البيانات دفعة واحدة) ───────────────────────
  static Future<HomeBundle> fetchHome() async {
    final res = await http
        .get(Uri.parse('$baseUrl/api/home'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      return HomeBundle.fromJson(jsonDecode(res.body));
    }
    throw Exception('فشل تحميل البيانات (${res.statusCode})');
  }

  // ─── Stores ──────────────────────────────────────────────────────
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

  // ─── Coupons ─────────────────────────────────────────────────────
  static Future<List<Coupon>> fetchCoupons({String type = 'latest'}) async {
    // type: latest | most-used | high-discount
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

  // ─── Offers (للـ featured slider) ────────────────────────────────
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
}