import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/coupon.dart';
import '../theme.dart';

class StoreItem extends StatelessWidget {
  final Store store;
  final VoidCallback? onTap;
  const StoreItem({super.key, required this.store, this.onTap});

  bool get _isLocal => !store.logoUrl.startsWith('http');

  Widget _buildLogo() {
    if (_isLocal && store.logoUrl.endsWith('.svg')) {
      return SvgPicture.asset(store.logoUrl,
          fit: BoxFit.contain, placeholderBuilder: (_) => _fallback());
    }
    if (_isLocal) {
      return Image.asset(store.logoUrl,
          fit: BoxFit.contain, errorBuilder: (_, __, ___) => _fallback());
    }
    if (store.logoUrl.endsWith('.svg')) {
      return SvgPicture.network(store.logoUrl,
          fit: BoxFit.contain, placeholderBuilder: (_) => _fallback());
    }
    return Image.network(store.logoUrl,
        fit: BoxFit.contain, errorBuilder: (_, __, ___) => _fallback());
  }

  Widget _fallback() => Center(
        child: Text(store.name,
            style: AppTheme.tajawal(
                fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 50,
            height: 36,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.all(4),
            child: _buildLogo(),
          ),
          const SizedBox(height: 6),
          Text(store.name,
              style:
                  AppTheme.tajawal(fontSize: 11, color: AppTheme.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
