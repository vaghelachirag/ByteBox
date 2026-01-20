import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../features/home/presentation/product_detail_page.dart';
import '../features/home/providers/home_new_arrivals.dart';
import '../model/NewArrivalModel.dart';


class NewArrivalSlider extends ConsumerWidget {
  const NewArrivalSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arrivalsAsync = ref.watch(newArrivalProvider);

    // Calculate height based on card content for consistent sizing
    final cardHeight = 160.h + // Image height
        24.h + // Top and bottom padding
        20.h + // Name text
        16.h + // Overview text
        20.h + // Price text
        40.h + // Button height
        28.h; // Spacing between elements

    return arrivalsAsync.when(
      loading: () => SizedBox(
        height: cardHeight,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      ),
      error: (e, _) => Container(
        padding: EdgeInsets.all(20.w),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 48.sp),
              SizedBox(height: 12.h),
              Text(
                'Failed to load products',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
      data: (arrivals) {
        if (arrivals.isEmpty) {
          return Container(
            height: 200.h,
            padding: EdgeInsets.all(20.w),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, color: AppColors.textTertiary, size: 48.sp),
                  SizedBox(height: 12.h),
                  Text(
                    'No new arrivals yet',
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

        final calculatedHeight = 160.h + // Image height
            24.h + // Top and bottom padding
            20.h + // Name text
            16.h + // Overview text
            20.h + // Price text
            44.h + // Button height with padding
            30.h; // Spacing between elements

        return SizedBox(
          height: calculatedHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: arrivals.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final item = arrivals[index];
              return Container(
                width: 240.w,
                constraints: BoxConstraints(
                  maxHeight: calculatedHeight,
                ),
                clipBehavior: Clip.antiAlias,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image Section
                    GestureDetector(
                      onTap: () => _goToDetail(context, item),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16.r),
                        ),
                        child: item.images.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.images[0],
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
                                    mainAxisSize: MainAxisSize.min,
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
                                  mainAxisSize: MainAxisSize.min,
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
                    ),
                    // Details Section
                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
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
                          SizedBox(height: 6.h),
                          Text(
                            "₹${NumberFormat('#,###').format(item.price)}",
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          SizedBox(
                            width: double.infinity,
                            height: 36.h,
                            child: OutlinedButton(
                              onPressed: () => _goToDetail(context, item),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "View Details",
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
      },
    );
  }
}

void _goToDetail(BuildContext context, NewArrivalModel item) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProductDetailPage(product: item),
    ),
  );
}
