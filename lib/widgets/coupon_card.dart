// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../models/coupon.dart';
// import '../theme.dart';

// class CouponCard extends StatefulWidget {
//   final Coupon coupon;
//   const CouponCard({super.key, required this.coupon});

//   @override
//   State<CouponCard> createState() => _CouponCardState();
// }

// class _CouponCardState extends State<CouponCard> with SingleTickerProviderStateMixin {
//   bool _revealed = false;
//   late AnimationController _controller;
//   late Animation<double> _blurAnim;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
//     _blurAnim = Tween<double>(begin: 8.0, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Color get badgeColor => AppTheme.badgeColors[widget.coupon.badge] ?? AppTheme.primary;
//   Color get badgeTextColor => AppTheme.badgeTextColors[widget.coupon.badge] ?? Colors.black;
//   bool get _isLocalAsset => !widget.coupon.storeLogo.startsWith('http');

//   Future<void> _revealAndOpen() async {
//     await Clipboard.setData(ClipboardData(text: widget.coupon.code));

//     setState(() => _revealed = true);
//     _controller.forward();

//     if (widget.coupon.storeUrl.isNotEmpty) {
//       final Uri url = Uri.parse(widget.coupon.storeUrl);
//       try {
//         await launchUrl(url, mode: LaunchMode.externalApplication);
//       } catch (e) {
//         debugPrint('Could not launch $url: $e');
//       }
//     }

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(children: [
//             const Icon(Icons.check_circle, color: Colors.white, size: 18),
//             const SizedBox(width: 8),
//             Text('تم نسخ الكود: ${widget.coupon.code}',
//                 style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
//           ]),
//           backgroundColor: AppTheme.primary,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           margin: const EdgeInsets.all(16),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   Widget _buildLogo() {
//     if (_isLocalAsset) {
//       return Image.asset(widget.coupon.storeLogo, fit: BoxFit.contain,
//           errorBuilder: (_, __, ___) => _fallback());
//     }
//     return Image.network(widget.coupon.storeLogo, fit: BoxFit.contain,
//         errorBuilder: (_, __, ___) => _fallback());
//   }

//   Widget _fallback() => Center(
//         child: Text(widget.coupon.storeName,
//             style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
//             textAlign: TextAlign.center),
//       );

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       decoration: BoxDecoration(
//         color: AppTheme.background,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4)),
//         ],
//         border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Expanded(
//                 flex: 3,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                       decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
//                       child: Text(widget.coupon.badge,
//                           style: TextStyle(color: badgeTextColor, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
//                     ),
//                     const SizedBox(height: 8),

//                     Text(widget.coupon.title,
//                         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'Cairo')),
//                     const SizedBox(height: 4),

//                     Row(children: [
//                       const Icon(Icons.access_time, size: 12, color: AppTheme.textSecondaryinWhite),
//                       const SizedBox(width: 4),
//                       Text(widget.coupon.expiryText,
//                           style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryinWhite, fontFamily: 'Cairo')),
//                     ]),
//                     const SizedBox(height: 14),

//                     AnimatedBuilder(
//                       animation: _blurAnim,
//                       builder: (context, child) {
//                         return Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             Container(
//                               width: double.infinity,
//                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFF5F5F5),
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(color: const Color(0xFFE0E0E0)),
//                               ),
//                               child: Text(
//                                 widget.coupon.code,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppTheme.textPrimary,
//                                   letterSpacing: 2,
//                                   fontFamily: 'Cairo',
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),

//                             if (!_revealed || _blurAnim.value > 0)
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: BackdropFilter(
//                                   filter: ImageFilter.blur(sigmaX: _blurAnim.value, sigmaY: _blurAnim.value),
//                                   child: Container(
//                                     width: double.infinity,
//                                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                                     color: Colors.white.withOpacity(_revealed ? 0 : 0.6),
//                                   ),
//                                 ),
//                               ),

//                             if (!_revealed)
//                               GestureDetector(
//                                 onTap: _revealAndOpen,
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                                   decoration: BoxDecoration(
//                                     color: AppTheme.primary,
//                                     borderRadius: BorderRadius.circular(8),
//                                     boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
//                                   ),
//                                   child: const Row(mainAxisSize: MainAxisSize.min, children: [
//                                     Icon(Icons.copy, color: Colors.white, size: 14),
//                                     SizedBox(width: 6),
//                                     Text('نسخ وزيارة المتجر',
//                                         style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
//                                   ]),
//                                 ),
//                               ),
//                           ],
//                         );
//                       },
//                     ),

//                     if (_revealed) ...[
//                       const SizedBox(height: 8),
//                       GestureDetector(
//                         onTap: () async {
//                           final Uri url = Uri.parse(widget.coupon.storeUrl);
//                           try { await launchUrl(url, mode: LaunchMode.externalApplication); } catch (_) {}
//                         },
//                         child: Row(mainAxisSize: MainAxisSize.min, children: [
//                           const Icon(Icons.open_in_new, size: 13, color: AppTheme.textSecondaryinWhite),
//                           const SizedBox(width: 4),
//                           Text('زيارة المتجر',
//                               style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryinWhite, fontFamily: 'Cairo',
//                                   decoration: TextDecoration.underline, decorationColor: AppTheme.textSecondaryinWhite)),
//                         ]),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 12),

//               SizedBox(
//                 width: screenWidth * 0.28,
//                 height: screenWidth * 0.28,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: _buildLogo(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:ui';
import 'package:discounts_app/models/coupon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/api_models.dart';
import '../theme.dart';

class ApiCouponCard extends StatefulWidget {
  final Coupon coupon;
  final int index;
  final int totalItems;
  const ApiCouponCard({super.key, required this.coupon, required this.index, required this.totalItems});
  @override
  State<ApiCouponCard> createState() => _ApiCouponCardState();
}

class _ApiCouponCardState extends State<ApiCouponCard>
    with SingleTickerProviderStateMixin {
  bool _revealed = false;
  late AnimationController _controller;
  late Animation<double> _blurAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _blurAnim = Tween<double>(begin: 8.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get badgeColor =>
      AppTheme.badgeColors[widget.coupon.badge] ?? AppTheme.primary;
  Color get badgeTextColor =>
      AppTheme.badgeTextColors[widget.coupon.badge] ?? Colors.black;

  Future<void> _revealAndOpen() async {
    await Clipboard.setData(ClipboardData(text: widget.coupon.code));
    setState(() => _revealed = true);
    _controller.forward();
    if (widget.coupon.storeUrl.isNotEmpty) {
      try {
        await launchUrl(Uri.parse(widget.coupon.storeUrl),
            mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text('تم نسخ الكود: ${widget.coupon.code}',
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ]),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Widget _buildLogo() {
    final url = widget.coupon.storeLogo;
    if (url.isEmpty)
      return Center(
          child: Text(widget.coupon.storeName,
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 12),
              textAlign: TextAlign.center));
    return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        placeholder: (_, __) => Container(color: Colors.grey[100]),
        errorWidget: (_, __, ___) => Center(
            child: Text(widget.coupon.storeName,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 12),
                textAlign: TextAlign.center)));
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: Listenable.merge([
        ValueNotifier(widget.index),
        ValueNotifier(widget.totalItems),
      ]),
      builder: (context, child) {
        final animation = Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: AlwaysStoppedAnimation<double>(
              (widget.index / widget.totalItems) * 0.4 + 0.6,
            ),
            curve: Curves.easeInOut,
          ),
        );

        return AppTheme.animatedSlideFadeIn(
          child: child!,
          animation: animation,
          offset: 25,
          direction: AxisDirection.up,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                  flex: 3,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(widget.coupon.badge,
                              style: TextStyle(
                                  color: badgeTextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo')),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.coupon.title,
                            style: AppTheme.tajawal(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            )),
                        const SizedBox(height: 4),
                        if (widget.coupon.expiryText.isNotEmpty)
                          Row(children: [
                            const Icon(Icons.access_time,
                                size: 12, color: AppTheme.textSecondaryinWhite),
                            const SizedBox(width: 4),
                            Text(widget.coupon.expiryText,
                                style: AppTheme.tajawal(
                                  fontSize: 11,
                                  color: AppTheme.textSecondaryinWhite,
                                )),
                          ]),
                        const SizedBox(height: 14),
                        AnimatedBuilder(
                          animation: _blurAnim,
                          builder: (context, _) =>
                              Stack(alignment: Alignment.center, children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: const Color(0xFFE0E0E0))),
                              child: Text(widget.coupon.code,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                      letterSpacing: 2,
                                      fontFamily: 'Cairo'),
                                  textAlign: TextAlign.center),
                            ),
                            if (!_revealed || _blurAnim.value > 0)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: _blurAnim.value,
                                      sigmaY: _blurAnim.value),
                                  child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      color: Colors.white
                                          .withOpacity(_revealed ? 0 : 0.6)),
                                ),
                              ),
                            if (!_revealed)
                              GestureDetector(
                                onTap: _revealAndOpen,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                AppTheme.primary.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3))
                                      ]),
                                  child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.copy,
                                            color: Colors.white, size: 14),
                                        SizedBox(width: 6),
                                        Text('نسخ الكود',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Cairo')),
                                      ]),
                                ),
                              ),
                          ]),
                        ),
                        if (_revealed) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              try {
                                await launchUrl(Uri.parse(widget.coupon.storeUrl),
                                    mode: LaunchMode.externalApplication);
                              } catch (_) {}
                            },
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.open_in_new,
                                  size: 13, color: AppTheme.textSecondaryinWhite),
                              const SizedBox(width: 4),
                              Text('زيارة المتجر',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondaryinWhite,
                                      fontFamily: 'Cairo',
                                      decoration: TextDecoration.underline,
                                      decorationColor:
                                          AppTheme.textSecondaryinWhite)),
                            ]),
                          ),
                        ],
                      ])),
              const SizedBox(width: 12),
              SizedBox(
                  width: sw * 0.28,
                  height: sw * 0.28,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildLogo())),
            ]),
          ),
        ),
      ),
    );
  }
}
