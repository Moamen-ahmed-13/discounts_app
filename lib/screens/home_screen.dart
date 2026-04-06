import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  // ─── Data ──────────────────────────────────────────────────────────
  List<Store> _stores = [];
  List<Store> _offerStores = [];
  List<Coupon> _coupons = [];
  SiteInfo? _site;
  HeroData? _hero;
  AppLabels? _labels; // من /api/labels
  List<String> _filterStores = []; // من /api/stores/for-filters
  bool _loading = true;
  String? _error;

  // ─── UI State ──────────────────────────────────────────────────────
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  FilterOptions _filterOptions = FilterOptions();
  int _visibleCount = 8;
  int _sliderIndex = 0;
  bool _emailSubmitting = false;
  bool _emailSent = false;
  String? _emailError;

  // ─── Social (fallback static if API doesn't return) ──────────────
  static const String _defaultTiktokUrl =
      'https://www.tiktok.com/@3rood_saudia?_r=1&_t=ZS-94wTAUGvh7o';
  static const String _defaultInstagramUrl =
      'https://www.instagram.com/couponat_5sm?igsh=MWp6ZHJ2NnczZmJhZA==';
  static const String _defaultFacebookUrl =
      'https://www.facebook.com/share/1CLo9ZBNup/';

  String get _tiktokUrl => _hero?.tiktokUrl?.isNotEmpty == true
      ? _hero!.tiktokUrl!
      : _defaultTiktokUrl;
  String get _instagramUrl => _hero?.instagramUrl?.isNotEmpty == true
      ? _hero!.instagramUrl!
      : _defaultInstagramUrl;
  String get _facebookUrl => _hero?.facebookUrl?.isNotEmpty == true
      ? _hero!.facebookUrl!
      : _defaultFacebookUrl;

  // ─── Banner ────────────────────────────────────────────────────────
  static const List<String> _staticBannerMessages = [
    'وفر أكثر تسوق بذكاء!',
    'لا تفوت أفضل العروض اليومية!',
    'خصومات حصرية تنتظرك الآن!',
    'كل يوم توفير جديد معنا!',
  ];
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  // بيستخدم messages من API لو متاحة، وإلا الـ static
  List<String> get _bannerMessages =>
      (_hero?.announcementMessages.isNotEmpty == true)
          ? _hero!.announcementMessages
          : _staticBannerMessages;

  // ─── Slider ────────────────────────────────────────────────────────
  static const int _loopMultiplier = 1000;
  late final PageController _pageController;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadData();
    _bannerTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (mounted) {
        setState(
            () => _bannerIndex = (_bannerIndex + 1) % _bannerMessages.length);
      }
    });
  }

  // ─── Load All Data ─────────────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // جيب كل البيانات بالتوازي
      final results = await Future.wait([
        ApiService.fetchHome(), // 0
        ApiService.fetchLabels()
            .catchError((_) => AppLabels(countries: [], durations: [])), // 1
        ApiService.fetchStoresForFilters().catchError((_) => <String>[]), // 2
      ]);

      final bundle = results[0] as HomeBundle;

      print('=== HERO ===');
      print('title: ${bundle.hero?.title}');
      print('description: ${bundle.hero?.description}');
      print('bgImage: ${bundle.hero?.bgImageUrl}');
      print('sideImage: ${bundle.hero?.imageUrl}');
      print('hero is null: ${bundle.hero == null}');
      print('=== SITE ===');
      print('name: ${bundle.site?.name}');
      final labels = results[1] as AppLabels;
      final filterStores = results[2] as List<String>;

      // لو الـ bundle ما جبتش كوبونات كافية، جيب من الـ endpoints المنفصلة
      List<Coupon> coupons = bundle.coupons;
      if (coupons.isEmpty) {
        coupons = await ApiService.fetchAllCoupons();
      }

      setState(() {
        _stores = bundle.stores;
        _offerStores = bundle.offers.isNotEmpty ? bundle.offers : bundle.stores;
        _coupons = coupons;
        _site = bundle.site;
        _hero = bundle.hero;
        _labels = labels;
        _filterStores = filterStores;
        _loading = false;
      });
    } catch (e) {
      // Fallback: جيب كل حاجة لوحدها
      try {
        final results = await Future.wait([
          ApiService.fetchStores().catchError((_) => <Store>[]),
          ApiService.fetchAllCoupons().catchError((_) => <Coupon>[]),
          ApiService.fetchOffers().catchError((_) => <Store>[]),
          ApiService.fetchLabels()
              .catchError((_) => AppLabels(countries: [], durations: [])),
          ApiService.fetchStoresForFilters().catchError((_) => <String>[]),
          ApiService.fetchHero()
              .catchError((_) => HeroData(title: '', description: '')),
          ApiService.fetchSite()
              .catchError((_) => SiteInfo(name: '', tagline: '')),
        ]);
        setState(() {
          _stores = results[0] as List<Store>;
          _coupons = results[1] as List<Coupon>;
          final offers = results[2] as List<Store>;
          _offerStores = offers.isNotEmpty ? offers : _stores;
          _labels = results[3] as AppLabels;
          _filterStores = results[4] as List<String>;
          final heroFallback = results[5] as HeroData;
          final siteFallback = results[6] as SiteInfo;
          _hero = heroFallback.title.isNotEmpty ? heroFallback : null;
          _site = siteFallback.name.isNotEmpty ? siteFallback : null;
          _loading = false;
        });
      } catch (e2) {
        setState(() {
          _error =
              'تعذّر الاتصال بالسيرفر.\nتحقق من اتصال الإنترنت وحاول مجدداً.';
          _loading = false;
        });
      }
    }
    if (_offerStores.isNotEmpty) _initSlider();
  }

  void _initSlider() {
    final initialPage = _offerStores.length * (_loopMultiplier ~/ 2);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) _pageController.jumpToPage(initialPage);
      setState(() => _sliderIndex = initialPage % _offerStores.length);
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_pageController.page ?? 0).round() + 1;
      _pageController.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ─── Filter ────────────────────────────────────────────────────────
  List<String> get _categories {
    final cats = _coupons
        .map((c) => c.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    return ['الكل', ...cats];
  }

  List<Coupon> get filteredCoupons => _coupons.where((c) {
        final matchSearch = _searchQuery.isEmpty ||
            c.title.contains(_searchQuery) ||
            c.storeName.contains(_searchQuery) ||
            c.code.contains(_searchQuery);
        final matchCompany = _filterOptions.company == 'جميع الشركات' ||
            c.storeName == _filterOptions.company;
        final matchCountry = _filterOptions.country == 'جميع الدول' ||
            c.country == _filterOptions.country;
        final matchDuration = _filterOptions.duration == 'جميع المدد' ||
            c.expiryText == _filterOptions.duration;
        return matchSearch && matchCompany && matchCountry && matchDuration;
      }).toList();

  List<Coupon> get visibleCoupons =>
      filteredCoupons.take(_visibleCount).toList();
  bool get hasMore => _visibleCount < filteredCoupons.length;

  void _openFilter() async {
    // استخدم /api/stores/for-filters إذا متاح، وإلا استخدم أسماء المتاجر
    final companies = _filterStores.isNotEmpty
        ? ['جميع الشركات', ..._filterStores]
        : ['جميع الشركات', ..._stores.map((s) => s.name)];

    // استخدم /api/labels للدول والمدد إذا متاح
    final countries = _labels?.countries.isNotEmpty == true
        ? ['جميع الدول', ..._labels!.countries]
        : null;
    final durations = _labels?.durations.isNotEmpty == true
        ? ['جميع المدد', ..._labels!.durations]
        : null;

    final result = await showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        current: _filterOptions,
        companies: companies,
        countries: countries,
        durations: durations,
      ),
    );
    if (result != null) {
      setState(() {
        _filterOptions = result;
        _visibleCount = 8;
      });
    }
  }

  // ─── Newsletter ────────────────────────────────────────────────────
  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => _emailError = 'الرجاء إدخال بريد إلكتروني صحيح');
      return;
    }
    setState(() {
      _emailSubmitting = true;
      _emailError = null;
    });
    try {
      await ApiService.subscribeNewsletter(email);
      setState(() {
        _emailSubmitting = false;
        _emailSent = true;
      });
      _emailController.clear();
    } catch (e) {
      final err = e.toString().replaceAll('Exception: ', '');
      if (err == 'backend_missing_route') {
        setState(() {
          _emailSubmitting = false;
          _emailError = 'خدمة الاشتراك غير متاحة حالياً، يرجى المحاولة لاحقاً';
        });
      } else {
        setState(() {
          _emailSubmitting = false;
          _emailError = err;
        });
      }
    }
  }

  Future<void> _launch(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _buildError();
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _loadData,
        child: CustomScrollView(slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(),
              _buildHeroSection(),
              if (_offerStores.isNotEmpty) _buildFeaturedSection(),
              _buildSectionHeader('🏪  أشهر المتاجر',
                  'تصفح مجموعة واسعة من المتاجر التي نقدم لها كوبونات خصم حصرية',
                  isRed: true),
              _buildStoresList(),
              _buildCouponsHeader(),
              _buildCouponsList(),
              _buildFooter(),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _buildLoading() => Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(color: AppTheme.primary),
          const SizedBox(height: 16),
          Text('جاري تحميل العروض...',
              style: AppTheme.tajawal(color: AppTheme.textSecondaryinWhite)),
        ])),
      );

  Widget _buildError() => Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off,
                        size: 64, color: AppTheme.textSecondaryinWhite),
                    const SizedBox(height: 16),
                    Text(_error!,
                        textAlign: TextAlign.center,
                        style: AppTheme.tajawal(
                            color: AppTheme.textSecondaryinWhite, height: 1.6)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14)),
                      child: Text('إعادة المحاولة',
                          style: AppTheme.tajawal(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ))),
      );

  Widget _buildAppBar() => SliverAppBar(
        floating: true,
        pinned: true,
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: _site?.logoUrl != null && _site!.logoUrl!.isNotEmpty
            ? Image.network(_site!.logoUrl!,
                height: 40,
                errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/Logo_B.png',
                    height: 40,
                    errorBuilder: (_, __, ___) => Text('COUPONEY',
                        style: AppTheme.tajawal(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.primary))))
            : Image.asset('assets/images/Logo_B.png',
                height: 40,
                errorBuilder: (_, __, ___) => Text('COUPONEY',
                    style: AppTheme.tajawal(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.primary))),
        centerTitle: false,
        titleSpacing: 25,
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
            child: Container(height: 1, color: const Color(0xFFEEEEEE))),
      );

  Widget _buildBanner() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: const Color(0xFF111111),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0, 0.3), end: Offset.zero)
                      .animate(anim),
                  child: child)),
          child: Text(_bannerMessages[_bannerIndex],
              key: ValueKey(_bannerIndex),
              textAlign: TextAlign.center,
              style: AppTheme.tajawal(color: Colors.white70, fontSize: 12)),
        ),
      );

  Widget _buildHeroSection() {
    final title = (_hero?.title != null && _hero!.title.isNotEmpty)
        ? _hero!.title
        : 'وفر أكثر مع كوبوني';
    final desc = (_hero?.description != null && _hero!.description.isNotEmpty)
        ? _hero!.description
        : 'استمتع بخصومات تصل إلى 50% على مجموعة واسعة من المنتجات من متاجرك المفضلة.';
    final heroImage = _hero?.imageUrl;
    final bgImage = _hero?.bgImageUrl;

    // ── Background: API bg image أو asset fallback ──
    Widget bgWidget;
    if (bgImage != null && bgImage.isNotEmpty) {
      bgWidget = Image.network(
        bgImage,
        width: double.infinity,
        height: 420,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/back.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: const Color(0xFF1A1A1A)),
        ),
      );
    } else {
      bgWidget = Image.asset(
        'assets/images/back.png',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A1A1A)),
      );
    }

    return Stack(children: [
      SizedBox(width: double.infinity, height: 320, child: bgWidget),
      Container(height: 320, color: Colors.black.withOpacity(0.5)),
      SizedBox(
          height: 320,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // Expanded(
            // child: Center(
            //     child: _loading
            //         ? const CircularProgressIndicator(
            //             color: AppTheme.primary)
            //         : heroImage != null && heroImage.isNotEmpty
            //             ? Image.network(heroImage,
            //                 height: 200,
            //                 errorBuilder: (_, __, ___) => Image.asset(
            //                     'assets/images/hero.png',
            //                     height: 200,
            //                     errorBuilder: (_, __, ___) =>
            //                         const SizedBox()))
            //             : Image.asset('assets/images/hero.png',
            //                 height: 200,
            //                 errorBuilder: (_, __, ___) =>
            //                     const SizedBox()))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(title,
                        style: AppTheme.tajawal(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Text(
                      desc,
                      style: AppTheme.tajawal(
                          color: Colors.white60, fontSize: 12, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      cursorColor: AppTheme.primary,
                      controller: _searchController,
                      textDirection: TextDirection.rtl,
                      style: AppTheme.tajawal(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن كوبونات او متاجر...',
                        hintStyle:
                            AppTheme.tajawal(color: Colors.grey, fontSize: 13),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.search,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text('بحث',
                                style: AppTheme.tajawal(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ]),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ]),
            ),
          ])),
    ]);
  }

  Widget _buildFeaturedSection() {
    final totalPages = _offerStores.length * _loopMultiplier;
    return Column(children: [
      _buildSectionHeader('🔥  عروض مميزة', 'أفضل العروض والخصومات الحصرية'),
      SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            onPageChanged: (i) =>
                setState(() => _sliderIndex = i % _offerStores.length),
            itemBuilder: (context, i) {
              final store = _offerStores[i % _offerStores.length];
              return GestureDetector(
                onTap: () async {
                  if (store.url.isNotEmpty) await _launch(store.url);
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ]),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildStoreImage(store)),
                ),
              );
            },
          )),
      const SizedBox(height: 10),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              _offerStores.length.clamp(0, 10),
              (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _sliderIndex == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: _sliderIndex == i
                          ? AppTheme.primary
                          : const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(4))))),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildStoreImage(Store store) {
    final logo = store.logoUrl;
    if (logo.isEmpty) {
      return Center(
          child: Text(store.name,
              style: AppTheme.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary)));
    }
    if (logo.endsWith('.svg')) {
      return Padding(
          padding: const EdgeInsets.all(24),
          child: SvgPicture.network(logo,
              fit: BoxFit.contain,
              placeholderBuilder: (_) => Center(
                  child: Text(store.name,
                      style: AppTheme.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary)))));
    }
    if (!logo.startsWith('http')) {
      return Image.asset(logo,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => Center(
              child: Text(store.name,
                  style: AppTheme.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary))));
    }
    return Image.network(logo,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (_, child, p) => p == null
            ? child
            : Center(
                child: CircularProgressIndicator(
                    color: AppTheme.primary,
                    value: p.expectedTotalBytes != null
                        ? p.cumulativeBytesLoaded / p.expectedTotalBytes!
                        : null)),
        errorBuilder: (_, __, ___) => Center(
            child: Text(store.name,
                style: AppTheme.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary))));
  }

  Widget _buildSectionHeader(String title, String subtitle,
          {bool isRed = false}) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (isRed)
              Container(
                  width: 4,
                  height: 22,
                  color: AppTheme.primary,
                  margin: const EdgeInsets.only(left: 8)),
            Text(title,
                style: AppTheme.tajawal(
                    fontSize: 17, fontWeight: FontWeight.bold)),
          ]),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: AppTheme.tajawal(fontSize: 12, color: AppTheme.primary)),
          ],
        ]),
      );

  Widget _buildStoresList() {
    if (_stores.isEmpty) return const SizedBox();
    return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _stores.length,
          itemBuilder: (context, i) => StoreItem(
            store: _stores[i],
            index: i,
            totalItems: _stores.length,
          ),
        ));
  }

  Widget _buildCouponsHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('🏷️  كوبونات مميزة',
                style: AppTheme.tajawal(
                    fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('أحدث العروض والكوبونات الحصرية',
                style: AppTheme.tajawal(fontSize: 12, color: AppTheme.primary)),
          ]),
          GestureDetector(
            onTap: _openFilter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _filterOptions.isDefault
                    ? AppTheme.background
                    : AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: _filterOptions.isDefault
                        ? const Color(0xFFCCCCCC)
                        : AppTheme.primary),
              ),
              child: Row(children: [
                Icon(Icons.filter_alt,
                    size: 16,
                    color: _filterOptions.isDefault
                        ? AppTheme.textSecondaryinWhite
                        : Colors.white),
                const SizedBox(width: 4),
                Text('فلتر',
                    style: AppTheme.tajawal(
                        fontSize: 13,
                        color: _filterOptions.isDefault
                            ? AppTheme.textSecondaryinWhite
                            : Colors.white,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ]),
      );

  Widget _buildCouponsList() {
    if (filteredCoupons.isEmpty) {
      return Center(
        child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(children: [
              const Icon(Icons.search_off,
                  size: 60, color: AppTheme.textSecondaryinWhite),
              const SizedBox(height: 12),
              Text('لا توجد نتائج',
                  style: AppTheme.tajawal(
                      color: AppTheme.textSecondaryinWhite, fontSize: 16)),
            ])),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: [
        ...visibleCoupons.asMap().entries.map((entry) {
          final i = entry.key;
          final c = entry.value;
          return ApiCouponCard(
            coupon: c,
            index: i,
            totalItems: visibleCoupons.length,
          );
        }),
        if (hasMore) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _visibleCount += 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(30)),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.add_circle_outline,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('إظهار المزيد من الكوبونات',
                    style: AppTheme.tajawal(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ]),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ]),
    );
  }

  Widget _buildFooter() {
    final footerLogo = _hero?.logoWhiteUrl ?? _site?.logoWhiteUrl;
    return Container(
      margin: const EdgeInsets.only(
        top: 24,
      ),
      color: const Color(0xFF111111),
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              // Logo - من API لو متاح، وإلا الـ local
              footerLogo != null && footerLogo.isNotEmpty
                  ? Image.network(footerLogo,
                      height: 50,
                      errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/Logo_w.png',
                          height: 50,
                          errorBuilder: (_, __, ___) => Text('COUPONEY',
                              style: AppTheme.tajawal(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20))))
                  : Image.asset('assets/images/Logo_w.png',
                      height: 50,
                      errorBuilder: (_, __, ___) => Text('COUPONEY',
                          style: AppTheme.tajawal(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20))),
              const SizedBox(height: 8),
              Text(
                  _site?.tagline ??
                      'منصتك لأفضل كوبونات الخصم والعروض الحصرية.',
                  style: AppTheme.tajawal(
                      color: AppTheme.textSecondaryinBlack, fontSize: 12),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _socialIcon(
                    const FaIcon(FontAwesomeIcons.whatsapp,
                        color: Colors.white60, size: 18),
                    'https://wa.me/201203994799'),
                const SizedBox(width: 16),
                _socialIcon(
                    const FaIcon(FontAwesomeIcons.tiktok,
                        color: Colors.white60, size: 18),
                    _tiktokUrl),
                const SizedBox(width: 16),
                _socialIcon(
                    const FaIcon(FontAwesomeIcons.instagram,
                        color: Colors.white60, size: 18),
                    _instagramUrl),
                const SizedBox(width: 16),
                _socialIcon(
                    const FaIcon(FontAwesomeIcons.facebookF,
                        color: Colors.white60, size: 18),
                    _facebookUrl),
              ]),
            ])),
        // Newsletter
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)))),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.email_outlined,
                  color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('النشرة البريدية',
                  style: AppTheme.tajawal(
                      color: AppTheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            Text(
                'اشترك الآن واحصل على أحدث الكوبونات والعروض الحصرية مباشرة على بريدك الإلكتروني.',
                style: AppTheme.tajawal(
                    color: AppTheme.textSecondaryinBlack,
                    fontSize: 12,
                    height: 1.6),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (_emailSent)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.4))),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Text('تم الاشتراك بنجاح! شكراً لك 🎉',
                      style: AppTheme.tajawal(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                ]),
              )
            else
              Column(children: [
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _emailError != null
                              ? Colors.red.withOpacity(0.5)
                              : Colors.white.withOpacity(0.1))),
                  child: Row(children: [
                    Expanded(
                        child: TextField(
                      controller: _emailController,
                      textDirection: TextDirection.rtl,
                      keyboardType: TextInputType.emailAddress,
                      style:
                          AppTheme.tajawal(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'أدخل بريدك الإلكتروني',
                        hintStyle: AppTheme.tajawal(
                            color: Colors.white38, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      onSubmitted: (_) => _submitEmail(),
                      onChanged: (_) {
                        if (_emailError != null) {
                          setState(() => _emailError = null);
                        }
                      },
                    )),
                    GestureDetector(
                      onTap: _emailSubmitting ? null : _submitEmail,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(8)),
                        child: _emailSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.send,
                                color: Colors.white, size: 18),
                      ),
                    ),
                  ]),
                ),
                if (_emailError != null) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(_emailError!,
                            style: AppTheme.tajawal(
                                color: Colors.red, fontSize: 12))),
                  ]),
                ],
              ]),
          ]),
        ),

        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text('© 2026 كوبوني . جميع الحقوق محفوظة.',
              style: AppTheme.tajawal(
                  color: AppTheme.textSecondaryinBlack, fontSize: 11),
              textAlign: TextAlign.center),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text('تم التصميم والتطوير بواسطة',
              style: AppTheme.tajawal(
                  color: AppTheme.textSecondaryinBlack, fontSize: 11),
              textAlign: TextAlign.center),
        ),
        // Bioagency small logo at the bottom
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(),
          child: Center(
            child: GestureDetector(
              onTap: () async {
                try {
                  await launchUrl(Uri.parse('https://bioagency.net/'),
                      mode: LaunchMode.externalApplication);
                } catch (_) {}
              },
              child: Image.asset('assets/images/Bio.webp',
                  height: 25, errorBuilder: (_, __, ___) => const SizedBox()),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _socialIcon(Widget icon, String url) => GestureDetector(
        onTap: () => _launch(url),
        child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.15))),
            child: Center(child: icon)),
      );
}

// Helper extension to avoid null check repetition
extension on Widget {
  Widget get errorWidget => this;
}
