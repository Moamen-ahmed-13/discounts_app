import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/coupon.dart';
import '../theme.dart';

class CouponCard extends StatelessWidget {
  final Coupon coupon;
  const CouponCard({super.key, required this.coupon});

  Color get badgeColor =>
      AppTheme.badgeColors[coupon.badge] ?? AppTheme.primary;
  Color get badgeTextColor =>
      AppTheme.badgeTextColors[coupon.badge] ?? Colors.black;

  bool get _isLocalAsset => !coupon.storeLogo.startsWith('http');

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: coupon.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'تم نسخ الكود: ${coupon.code}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildLogo() {
    if (_isLocalAsset) {
      return Image.asset(
        coupon.storeLogo,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallbackText(),
      );
    }
    return Image.network(
      coupon.storeLogo,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _fallbackText(),
    );
  }

  Widget _fallbackText() => Center(
    child: Text(
      coupon.storeName,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Text(
            '\n\nDISCOUNT\n\n',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              fontFamily: 'Cairo',
              letterSpacing: 2,
            ),
          ),
        ),
        Positioned(
          height: 200,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: AppTheme.background.withOpacity(0.5)),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.background.withOpacity(1),
                AppTheme.background.withOpacity(0.7),

                AppTheme.background.withOpacity(0.3),
              ],
            ),
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            // border: Border.all(color: AppTheme.background, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          coupon.badge,
                          style: TextStyle(
                            color: badgeTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        coupon.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppTheme.textSecondaryinWhite,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            coupon.expiryText,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondaryinWhite,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _copyCode(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.copy, color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'نسخ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          if (coupon.storeUrl.isNotEmpty) {
                            final Uri url = Uri.parse(coupon.storeUrl);
                            try {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            } catch (e) {
                              debugPrint('Could not launch $url: $e');
                            }
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.open_in_new,
                              size: 13,
                              color: AppTheme.textSecondaryinWhite,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'زيارة المتجر',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryinWhite,
                                fontFamily: 'Cairo',
                                decoration: TextDecoration.underline,
                                decorationColor: AppTheme.textSecondaryinWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5 - 40,
                  height: MediaQuery.of(context).size.height * 0.20 - 40,
                  decoration: BoxDecoration(
                    // color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: _buildLogo(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
