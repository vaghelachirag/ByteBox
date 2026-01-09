import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../provider/best_deal_provider.dart';

class AnimatedPercentageBadge extends StatefulWidget {
  final double discount;
  final double top;
  final double right;

  const AnimatedPercentageBadge({
    super.key,
    required this.discount,
    this.top = 8,
    this.right = 8,
  });

  @override
  State<AnimatedPercentageBadge> createState() =>
      _AnimatedPercentageBadgeState();
}

class _AnimatedPercentageBadgeState extends State<AnimatedPercentageBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, -0.1),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // ▶ Auto play on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward().then((_) => _controller.reverse());
    });
  }

  void _onTap() {
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      right: widget.right,
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Transform.scale(
              scale: _scale.value,
              child: Transform.translate(
                offset: Offset(
                  _slide.value.dx * 20,
                  _slide.value.dy * 20,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35), // Orange color matching the image
                    borderRadius: BorderRadius.circular(20.r), // More rounded like circular badges
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${widget.discount.toInt()}%",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        "OFF",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// 🛍 BEST DEAL SLIDER
/// ------------------------------------------------------------
class BestDealSlider extends ConsumerWidget {
  const BestDealSlider({super.key});

  double _discountedPrice(double price, double discount) {
    return price - (price * discount / 100);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealsAsync = ref.watch(bestDealsProvider);

    // Calculate height based on card content for consistent sizing
    final cardHeight = 160.h + // Image height
        24.h + // Top and bottom padding
        20.h + // Name text
        16.h + // Overview text
        20.h + // Price text
        40.h + // Button height
        28.h; // Spacing between elements

    return dealsAsync.when(
      loading: () => SizedBox(
        height: cardHeight,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      ),
      error: (e, _) => Container(
        height: 200.h,
        padding: EdgeInsets.all(20.w),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 48.sp),
              SizedBox(height: 12.h),
              Text(
                'Failed to load deals',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
      data: (deals) {
        if (deals.isEmpty) {
          return Container(
            height: 200.h,
            padding: EdgeInsets.all(20.w),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_offer_outlined, color: AppColors.textTertiary, size: 48.sp),
                  SizedBox(height: 12.h),
                  Text(
                    'No best deals available',
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: deals.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final item = deals[index];
              final hasDiscount = item.discount > 0;
              final discountedPrice = hasDiscount
                  ? _discountedPrice(item.price, item.discount)
                  : item.price;

              return Container(
                width: 240.w,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// IMAGE + BADGE
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.r),
                          ),
                          child: item.images.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: item.images.first,
                                  height: 160.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 160.h,
                                    width: double.infinity,
                                    color: AppColors.backgroundLight,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    height: 160.h,
                                    width: double.infinity,
                                    color: AppColors.backgroundDark,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 48.sp,
                                          color: AppColors.textTertiary,
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'Image not available',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10.sp,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 160.h,
                                  width: double.infinity,
                                  color: AppColors.backgroundDark,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        size: 48.sp,
                                        color: AppColors.textTertiary,
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'No image',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.sp,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        if (hasDiscount)
                          AnimatedPercentageBadge(
                            discount: item.discount,
                            top: 12.h,
                            right: 12.w,
                          ),
                      ],
                    ),

                    /// DETAILS
                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            item.overview ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8.h),

                          /// PRICE
                          Row(
                            children: [
                              Text(
                                "₹${NumberFormat('#,###').format(discountedPrice)}",
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                              if (hasDiscount) ...[
                                SizedBox(width: 8.w),
                                Text(
                                  "₹${NumberFormat('#,###').format(item.price)}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                    decoration:
                                    TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text("View Details"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ));
        }
    );
  }
}
