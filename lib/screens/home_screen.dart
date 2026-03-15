import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/coupon.dart';
import '../theme.dart';
import '../widgets/coupon_card.dart';
import '../widgets/store_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  final TextEditingController _searchController = TextEditingController();

  List<Coupon> get filteredCoupons => mockCoupons.where((c) {
    final matchSearch =
        _searchQuery.isEmpty ||
        c.title.contains(_searchQuery) ||
        c.storeName.contains(_searchQuery) ||
        c.code.contains(_searchQuery);
    final matchCategory =
        _selectedCategory == 'الكل' || c.category == _selectedCategory;
    return matchSearch && matchCategory;
  }).toList();

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
            title: Image.asset(
              'assets/images/logo.png',
              height: 36,
              errorBuilder: (_, __, ___) => const Text(
                'CouponX',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.primary,
                ),
              ),
            ),
            centerTitle: true,
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
                  child: const Text(
                    'لا تفوت أفضل العروض اليومية!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondaryinBlack,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),

                _buildHeroSection(),

                _buildSearchBar(),

                _buildSectionHeader(
                  '🏪  أشهر المتاجر',
                  'تضم مجموعة واسعة من المتاجر التي نقدم لها كوبونات خصم حصرية',
                ),
                _buildStoresList(),

                _buildCategories(),
                _buildSectionHeader(
                  '🏷️  كوبونات مميزة',
                  'أحدث العروض والكوبونات الحصرية التي تمت إضافتها حديثًا إلى منصتنا',
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
    return Container(
      margin: const EdgeInsets.all(0),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(0),
      //   border: Border.all(color: AppTheme.cardBorder),
      // ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/back.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppTheme.surface),
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.55)),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'وفر أكثر مع عالم الخصومات!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'استمتع بخصومات تصل إلى ٪70 على مجموعة واسعة من المنتجات من متاجرك المفضلة. اكتشف العروض الحصرية اليومية وكوبونات الخصم التي تجعل التسوق أكثر متعة وتوفيرًا.',
                          style: TextStyle(
                            color: AppTheme.textSecondaryinBlack,
                            fontSize: 11,
                            fontFamily: 'Cairo',
                            height: 1.5,
                          ),
                        ),
                        // const SizedBox(height: 16),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 16,
                        //     vertical: 10,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: AppTheme.secondary,
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   child: const Row(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       Icon(Icons.search, color: Colors.white, size: 16),
                        //       SizedBox(width: 6),
                        //       Text(
                        //         'بحث',
                        //         style: TextStyle(
                        //           color: Colors.white,
                        //           fontFamily: 'Cairo',
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/images/hero.png',
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 8, left: 8, bottom: 30),
      child: TextField(
        cursorColor: AppTheme.primary,
        controller: _searchController,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontFamily: 'Cairo',
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن كوبونات أو متاجر...',
          hintStyle: const TextStyle(
            fontFamily: 'Cairo',
            color: AppTheme.textSecondaryinWhite,
            fontSize: 13,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'بحث',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppTheme.textSecondaryinWhite,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.textSecondaryinBlack),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: AppTheme.textPrimary,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Cairo',
                color: Color.fromARGB(255, 121, 121, 121),
              ),
            ),
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
      padding: const EdgeInsets.only(top: 40, bottom: 8),
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
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : AppTheme.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    width: 2,
                    color: selected
                        ? AppTheme.primary
                        : const Color.fromARGB(255, 192, 191, 191),
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : AppTheme.textSecondaryinWhite,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
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
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 60,
                color: AppTheme.textSecondaryinWhite,
              ),
              SizedBox(height: 12),
              Text(
                'لا توجد نتائج',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppTheme.textSecondaryinWhite,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      // color: Colors.yellowAccent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: filteredCoupons.map((c) => CouponCard(coupon: c)).toList(),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      color: const Color(0xFF111111),
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo2.png',
            height: 40,
            errorBuilder: (_, __, ___) => const Text(
              'CouponX',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'منصتك لأفضل كوبونات الخصم والعروض الحصرية.',
            style: TextStyle(
              color: AppTheme.textSecondaryinBlack,
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialIcon(Icons.facebook),
              const SizedBox(width: 16),
              _socialIcon(Icons.camera_alt_outlined),
              const SizedBox(width: 16),
              _socialIcon(Icons.telegram),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '2025 عالم الخصومات. جميع الحقوق محفوظة.',
            style: TextStyle(
              color: AppTheme.textSecondaryinBlack,
              fontSize: 11,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Icon(icon, color: AppTheme.textSecondaryinBlack, size: 18),
    );
  }
}
