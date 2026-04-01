// lib/screens/home_screen.dart
// استبدل الملف الحالي بالكامل

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/coupon.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/coupon_card.dart';
import '../widgets/store_item.dart';
import '../widgets/filter_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ─── State ────────────────────────────────────────────────────────
  List<Store> _stores = [];
  List<Store> _offerStores = []; // للـ featured slider
  List<Coupon> _coupons = [];
  bool _loading = true;
  String? _error;

  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  final TextEditingController _searchController = TextEditingController();
  FilterOptions _filterOptions = FilterOptions();
  int _visibleCount = 8;
  int _sliderIndex = 0;

  static const int _loopMultiplier = 1000;
  late final PageController _pageController;
  Timer? _autoScrollTimer;

  // ─── Init ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // جرب /api/home الأول (full bundle)
      final bundle = await ApiService.fetchHome();
      setState(() {
        _stores = bundle.stores;
        _offerStores = bundle.offers.isNotEmpty ? bundle.offers : bundle.stores;
        _coupons = bundle.coupons;
        _loading = false;
      });
    } catch (_) {
      // لو /api/home فشلت، جيب كل حاجة لوحدها
      try {
        final results = await Future.wait([
          ApiService.fetchStores(),
          ApiService.fetchCoupons(type: 'latest'),
          ApiService.fetchOffers(),
        ]);
        setState(() {
          _stores = results[0] as List<Store>;
          _coupons = results[1] as List<Coupon>;
          final offers = results[2] as List<Store>;
          _offerStores = offers.isNotEmpty ? offers : _stores;
          _loading = false;
        });
      } catch (e) {
        setState(() {
          _error = 'تعذّر الاتصال بالسيرفر.\nتحقق من اتصال الإنترنت وحاول مجدداً.';
          _loading = false;
        });
      }
    }

    // ابدأ الـ slider بعد ما البيانات اتحملت
    if (_offerStores.isNotEmpty) _initSlider();
  }

  void _initSlider() {
    final initialPage = _offerStores.length * (_loopMultiplier ~/ 2);
    // لو الـ controller لسه مش attached، ما نقدرش نجمله
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(initialPage);
      }
      setState(() => _sliderIndex = initialPage % _offerStores.length);
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_pageController.page ?? 0).round() + 1;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  // ─── Categories (من الـ coupons الحقيقية) ────────────────────────
  List<String> get _categories {
    final cats = _coupons.map((c) => c.category).toSet().toList();
    return ['الكل', ...cats];
  }

  // ─── Filter ───────────────────────────────────────────────────────
  List<Coupon> get filteredCoupons => _coupons.where((c) {
        final matchSearch = _searchQuery.isEmpty ||
            c.title.contains(_searchQuery) ||
            c.storeName.contains(_searchQuery) ||
            c.code.contains(_searchQuery);
        final matchCategory =
            _selectedCategory == 'الكل' || c.category == _selectedCategory;
        final matchCompany = _filterOptions.company == 'جميع الشركات' ||
            c.storeName == _filterOptions.company;
        return matchSearch && matchCategory && matchCompany;
      }).toList();

  List<Coupon> get visibleCoupons =>
      filteredCoupons.take(_visibleCount).toList();
  bool get hasMore => _visibleCount < filteredCoupons.length;

  void _openFilter() async {
    final storeNames = ['جميع الشركات', ..._stores.map((s) => s.name)];
    final result = await showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(current: _filterOptions, companies: storeNames),
    );
    if (result != null) {
      setState(() {
        _filterOptions = result;
        _visibleCount = 8;
      });
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading();
    if (_error != null) return _buildError();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnnouncementBanner(),
                  _buildHeroSection(),
                  if (_offerStores.isNotEmpty) _buildFeaturedSection(),
                  _buildSectionHeader('🏪  أشهر المتاجر',
                      'تصفح مجموعة واسعة من المتاجر التي نقدم لها كوبونات خصم حصرية',
                      isRed: true),
                  _buildStoresList(),
                  _buildCategories(),
                  _buildCouponsHeader(),
                  _buildCouponsList(),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Loading & Error ──────────────────────────────────────────────
  Widget _buildLoading() => Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.primary),
              const SizedBox(height: 16),
              const Text('جاري تحميل العروض...',
                  style: TextStyle(fontFamily: 'Cairo', color: AppTheme.textSecondaryinWhite)),
            ],
          ),
        ),
      );

  Widget _buildError() => Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 64, color: AppTheme.textSecondaryinWhite),
                const SizedBox(height: 16),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.textSecondaryinWhite, height: 1.6)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  child: const Text('إعادة المحاولة',
                      style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );

  // ─── AppBar ───────────────────────────────────────────────────────
  Widget _buildAppBar() => SliverAppBar(
        floating: true,
        pinned: true,
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Image.asset('assets/images/logo.png',
            height: 45,
            errorBuilder: (_, __, ___) => const Text('CouponX',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.primary))),
        centerTitle: false,
        titleSpacing: 20,
        actions: [
          IconButton(
            icon: Stack(children: [
              const Icon(Icons.filter_alt_outlined, color: Colors.black),
              if (!_filterOptions.isDefault)
                Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppTheme.primary, shape: BoxShape.circle))),
            ]),
            onPressed: _openFilter,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      );

  Widget _buildAnnouncementBanner() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: const Color(0xFF111111),
        child: const Text('خصومات حصرية تنتظرك الآن!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Cairo')),
      );

  // ─── Hero ─────────────────────────────────────────────────────────
  Widget _buildHeroSection() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 420,
          child: Image.asset('assets/images/back.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A1A1A))),
        ),
        Container(height: 420, color: Colors.black.withOpacity(0.5)),
        SizedBox(
          height: 420,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Image.asset('assets/images/hero.png',
                      height: 200,
                      errorBuilder: (_, __, ___) => const SizedBox()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('وفر أكثر مع كوبون X!',
                        style: TextStyle(
                            color: Colors.white, fontSize: 22,
                            fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    const SizedBox(height: 8),
                    const Text(
                      'استمتع بخصومات تصل إلى 70% على مجموعة واسعة من المنتجات من متاجرك المفضلة.',
                      style: TextStyle(color: Colors.white60, fontSize: 12, fontFamily: 'Cairo', height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      cursorColor: AppTheme.primary,
                      controller: _searchController,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.black, fontFamily: 'Cairo'),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن كوبونات او متاجر...',
                        hintStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 13),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.search, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('بحث',
                                style: TextStyle(color: Colors.white, fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                          ]),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Featured Slider ──────────────────────────────────────────────
  Widget _buildFeaturedSection() {
    final totalPages = _offerStores.length * _loopMultiplier;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('🔥  عروض مميزة',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo', color: AppTheme.textPrimary)),
              ]),
              SizedBox(height: 4),
              Text('أفضل العروض والخصومات الحصرية',
                  style: TextStyle(fontSize: 12, fontFamily: 'Cairo',
                      color: AppTheme.textSecondaryinWhite)),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            onPageChanged: (i) => setState(() => _sliderIndex = i % _offerStores.length),
            itemBuilder: (context, i) {
              final store = _offerStores[i % _offerStores.length];
              return GestureDetector(
                onTap: () async {
                  if (store.url.isNotEmpty) {
                    final uri = Uri.parse(store.url);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
                        blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildStoreImage(store),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_offerStores.length.clamp(0, 10), (i) =>
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _sliderIndex == i ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _sliderIndex == i ? AppTheme.primary : const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── Store Image (Network + SVG + local) ──────────────────────────
  Widget _buildStoreImage(Store store) {
    final logo = store.logoUrl;
    if (logo.isEmpty) {
      return Center(
        child: Text(store.name,
            style: const TextStyle(fontSize: 18, fontFamily: 'Cairo',
                fontWeight: FontWeight.bold, color: AppTheme.primary)),
      );
    }
    // SVG من الـ network
    if (logo.endsWith('.svg')) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: SvgPicture.network(logo, fit: BoxFit.contain,
            placeholderBuilder: (_) => _storeNameFallback(store.name)),
      );
    }
    // Local asset
    if (!logo.startsWith('http')) {
      return Image.asset(logo, fit: BoxFit.cover,
          width: double.infinity, height: double.infinity,
          errorBuilder: (_, __, ___) => _storeNameFallback(store.name));
    }
    // Network image
    return Image.network(logo, fit: BoxFit.cover,
        width: double.infinity, height: double.infinity,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Center(child: CircularProgressIndicator(
                color: AppTheme.primary,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                    : null)),
        errorBuilder: (_, __, ___) => _storeNameFallback(store.name));
  }

  Widget _storeNameFallback(String name) => Center(
        child: Text(name,
            style: const TextStyle(fontSize: 18, fontFamily: 'Cairo',
                fontWeight: FontWeight.bold, color: AppTheme.primary)),
      );

  // ─── Section Header ───────────────────────────────────────────────
  Widget _buildSectionHeader(String title, String subtitle, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (isRed)
              Container(width: 4, height: 22, color: AppTheme.primary,
                  margin: const EdgeInsets.only(left: 8)),
            Text(title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo', color: AppTheme.textPrimary)),
          ]),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(fontSize: 12, fontFamily: 'Cairo',
                    color: isRed ? AppTheme.primary : AppTheme.textSecondaryinWhite)),
          ],
        ],
      ),
    );
  }

  // ─── Stores List ──────────────────────────────────────────────────
  Widget _buildStoresList() {
    if (_stores.isEmpty) return const SizedBox();
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _stores.length,
        itemBuilder: (context, i) => StoreItem(store: _stores[i]),
      ),
    );
  }

  // ─── Categories ───────────────────────────────────────────────────
  Widget _buildCategories() {
    final cats = _categories;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: cats.length,
          itemBuilder: (context, i) {
            final cat = cats[i];
            final selected = cat == _selectedCategory;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedCategory = cat;
                _visibleCount = 8;
              }),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : AppTheme.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 1.5,
                      color: selected ? AppTheme.primary : const Color(0xFFCCCCCC)),
                ),
                child: Text(cat,
                    style: TextStyle(
                        color: selected ? Colors.white : AppTheme.textSecondaryinWhite,
                        fontSize: 12, fontFamily: 'Cairo',
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Coupons Header ───────────────────────────────────────────────
  Widget _buildCouponsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('🏷️  كوبونات مميزة',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo', color: AppTheme.textPrimary)),
            SizedBox(height: 4),
            Text('أحدث العروض والكوبونات الحصرية',
                style: TextStyle(fontSize: 12, fontFamily: 'Cairo', color: AppTheme.primary)),
          ]),
          GestureDetector(
            onTap: _openFilter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _filterOptions.isDefault ? AppTheme.background : AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: _filterOptions.isDefault ? const Color(0xFFCCCCCC) : AppTheme.primary),
              ),
              child: Row(children: [
                Icon(Icons.filter_alt, size: 16,
                    color: _filterOptions.isDefault ? AppTheme.textSecondaryinWhite : Colors.white),
                const SizedBox(width: 4),
                Text('فلتر',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                        color: _filterOptions.isDefault ? AppTheme.textSecondaryinWhite : Colors.white,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Coupons List ─────────────────────────────────────────────────
  Widget _buildCouponsList() {
    if (filteredCoupons.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(children: [
            Icon(Icons.search_off, size: 60, color: AppTheme.textSecondaryinWhite),
            SizedBox(height: 12),
            Text('لا توجد نتائج',
                style: TextStyle(fontFamily: 'Cairo',
                    color: AppTheme.textSecondaryinWhite, fontSize: 16)),
          ]),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ...visibleCoupons.map((c) => ApiCouponCard(coupon: c)),
          if (hasMore) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _visibleCount += 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    color: AppTheme.primary, borderRadius: BorderRadius.circular(30)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('إظهار المزيد من الكوبونات',
                      style: TextStyle(color: Colors.white, fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      color: const Color(0xFF111111),
      child: Column(children: [
        Image.asset('assets/images/logo2.png',
            height: 40,
            errorBuilder: (_, __, ___) => const Text('CouponX',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold,
                    fontSize: 18, fontFamily: 'Cairo'))),
        const SizedBox(height: 8),
        const Text('منصتك لأفضل كوبونات الخصم والعروض الحصرية.',
            style: TextStyle(color: AppTheme.textSecondaryinBlack, fontSize: 12, fontFamily: 'Cairo'),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _socialIcon(Icons.facebook),
          const SizedBox(width: 16),
          _socialIcon(Icons.camera_alt_outlined),
          const SizedBox(width: 16),
          _socialIcon(Icons.telegram),
        ]),
        const SizedBox(height: 16),
        const Text('2025 عالم الخصومات. جميع الحقوق محفوظة.',
            style: TextStyle(color: AppTheme.textSecondaryinBlack, fontSize: 11, fontFamily: 'Cairo'),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _socialIcon(IconData icon) => Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2A2A2A))),
        child: Icon(icon, color: AppTheme.textSecondaryinBlack, size: 18),
      );
}