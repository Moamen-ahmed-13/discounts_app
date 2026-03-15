import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/coupon.dart';
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
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  final TextEditingController _searchController = TextEditingController();
  FilterOptions _filterOptions = FilterOptions();
  int _visibleCount = 4;

  List<Coupon> get filteredCoupons => mockCoupons.where((c) {
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
    final result = await showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(current: _filterOptions),
    );
    if (result != null) {
      setState(() {
        _filterOptions = result;
        _visibleCount = 4;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: AppTheme.background,
            elevation: 0,
            title: Image.asset('assets/images/logo.png',
                height: 36,
                errorBuilder: (_, __, ___) => const Text('CouponX',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFFFF6B35)))),
            centerTitle: true,
            actions: [
              // Filter icon in AppBar
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
                                color: AppTheme.primary,
                                shape: BoxShape.circle))),
                ]),
                onPressed: _openFilter,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppTheme.divider),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: const Color(0xFF111111),
                  child: const Text('لا تفوت أفضل العروض اليومية!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSecondaryinBlack,
                          fontSize: 12,
                          fontFamily: 'Cairo')),
                ),
                _buildHeroSection(),
                _buildSearchBar(),
                _buildSectionHeader('🏪  أشهر المتاجر',
                    'تضم مجموعة واسعة من المتاجر التي نقدم لها كوبونات خصم حصرية'),
                _buildStoresList(),
                _buildCategories(),

                // Coupons header + filter button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 30, 16, 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🏷️  كوبونات مميزة',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                  color: AppTheme.textPrimary)),
                          SizedBox(height: 4),
                          Text('أحدث العروض والكوبونات الحصرية',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Cairo',
                                  color: AppTheme.textSecondaryinWhite)),
                        ],
                      ),
                      // Filter button
                      GestureDetector(
                        onTap: _openFilter,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
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
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: _filterOptions.isDefault
                                      ? AppTheme.textSecondaryinWhite
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                )),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),

                _buildCouponsList(),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 220,
            child: Image.asset('assets/images/back.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF1A1A1A))),
          ),
          Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.55))),
          SizedBox(
            height: 220,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('وفر أكثر مع عالم الخصومات!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                                height: 1.4)),
                        SizedBox(height: 8),
                        Text(
                            'استمتع بخصومات تصل إلى ٪70 على مجموعة واسعة من المنتجات. اكتشف العروض الحصرية اليومية وكوبونات الخصم.',
                            style: TextStyle(
                                color: AppTheme.textSecondaryinBlack,
                                fontSize: 11,
                                fontFamily: 'Cairo',
                                height: 1.5)),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Image.asset('assets/images/hero.png',
                        errorBuilder: (_, __, ___) => const SizedBox()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: TextField(
        cursorColor: AppTheme.primary,
        controller: _searchController,
        textDirection: TextDirection.rtl,
        style:
            const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Cairo'),
        decoration: InputDecoration(
          hintText: 'ابحث عن كوبونات أو متاجر...',
          hintStyle: const TextStyle(
              fontFamily: 'Cairo',
              color: AppTheme.textSecondaryinWhite,
              fontSize: 13),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8)),
            child: const Text('بحث',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: AppTheme.textSecondaryinWhite),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  })
              : null,
          filled: true,
          fillColor: AppTheme.background,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primary, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: AppTheme.textPrimary)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Cairo',
                    color: AppTheme.textSecondaryinWhite)),
          ],
        ],
      ),
    );
  }

  Widget _buildStoresList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: mockStores.length,
        itemBuilder: (context, i) => StoreItem(store: mockStores[i]),
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      child: SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: categories.length,
          itemBuilder: (context, i) {
            final cat = categories[i];
            final selected = cat == _selectedCategory;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedCategory = cat;
                _visibleCount = 4;
              }),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : AppTheme.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      width: 1.5,
                      color: selected
                          ? AppTheme.primary
                          : const Color(0xFFCCCCCC)),
                ),
                child: Text(cat,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : AppTheme.textSecondaryinWhite,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    )),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCouponsList() {
    if (filteredCoupons.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(children: [
            Icon(Icons.search_off,
                size: 60, color: AppTheme.textSecondaryinWhite),
            SizedBox(height: 12),
            Text('لا توجد نتائج',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppTheme.textSecondaryinWhite,
                    fontSize: 16)),
          ]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Coupons
          ...visibleCoupons.map((c) => CouponCard(coupon: c)),

          // "إظهار المزيد" button
          if (hasMore) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _visibleCount += 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('إظهار المزيد من الكوبونات',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      color: const Color(0xFF111111),
      child: Column(children: [
        Image.asset('assets/images/logo2.png',
            height: 40,
            errorBuilder: (_, __, ___) => const Text('CouponX',
                style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Cairo'))),
        const SizedBox(height: 8),
        const Text('منصتك لأفضل كوبونات الخصم والعروض الحصرية.',
            style: TextStyle(
                color: AppTheme.textSecondaryinBlack,
                fontSize: 12,
                fontFamily: 'Cairo'),
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
            style: TextStyle(
                color: AppTheme.textSecondaryinBlack,
                fontSize: 11,
                fontFamily: 'Cairo'),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Icon(icon, color: AppTheme.textSecondaryinBlack, size: 18),
    );
  }
}
