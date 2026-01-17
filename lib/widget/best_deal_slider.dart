import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../features/home/presentation/product_detail_page.dart';
import '../provider/best_deal_provider.dart';
import '../model/best_deal_model.dart';
import '../model/NewArrivalModel.dart';
import 'animated_percentage_badge.dart';

class BestDealSlider extends ConsumerWidget {
  const BestDealSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealsAsync = ref.watch(bestDealsProvider);

    final cardHeight =
        160.h + 24.h + 20.h + 16.h + 20.h + 44.h + 30.h;

    return dealsAsync.when(
      loading: () => SizedBox(
        height: cardHeight,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SizedBox(
        height: cardHeight,
        child: const Center(child: Text('Failed to load deals')),
      ),
      data: (deals) {
        if (deals.isEmpty) {
          return SizedBox(
            height: cardHeight,
            child: const Center(child: Text('No best deals available')),
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
              final hasDiscount = item.discountPercent > 0;
              return Container(
                width: 240.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGE + DISCOUNT BADGE
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _goToDetail(context, item),
                          child: CachedNetworkImage(
                            imageUrl: item.images.isNotEmpty
                                ? item.images.first
                                : '',
                            height: 160.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.backgroundLight,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.backgroundDark,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                        if (hasDiscount)
                          AnimatedPercentageBadge(
                            discount: item.discountPercent,
                            top: 8.h,
                            right: 8.w,
                          ),
                      ],
                    ),

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
                          SizedBox(height: 4.h),
                          Text(
                            item.overview ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // PRICE
                          Row(
                            children: [
                              Text(
                                "₹${NumberFormat('#,###').format(item.discountPrice)}",
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                              if (hasDiscount) ...[
                                SizedBox(width: 8.w),
                                Text(
                                  "₹${NumberFormat('#,###').format(item.originalPrice)}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          SizedBox(height: 10.h),

                          SizedBox(
                            width: double.infinity,
                            height: 36.h,
                            child: OutlinedButton(
                              onPressed: () => _goToDetail(context, item),
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
          ),
        );
      },
    );
  }
}

void _goToDetail(BuildContext context, BestDealModel item) {
  final product = NewArrivalModel(
    id: item.id,
    name: item.name,
    overview: item.overview,
    price: item.discountPrice,
    images: item.images,
    company: '',
    model: '',
    display: '',
    processor: '',
    operatingSystem: '',
    ram: '',
    storage: '',
    graphics: '',
    isActive: item.isActive,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProductDetailPage(product: product),
    ),
  );
}
