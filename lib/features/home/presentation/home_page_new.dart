import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widget/best_deal_slider.dart';
import '../../../widget/new_arrival_slider.dart';
import '../providers/home_provider.dart';
import 'best_deal_list_page.dart';
import 'new_arrivals_list_page.dart';
import 'package:bytebox/widget/banner_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: SizedBox(height: 200.h, child: const BannerSlider()),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildServiceHighlights(),
            ),
            SliverToBoxAdapter(
              child: _buildNewArrivalsSection(context, homeState),
            ),
            SliverToBoxAdapter(
              child: _buildBestDealsSection(context, homeState),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 24.h),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            const Color(0xFF0A0A1A),
            Colors.black,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4FF).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Blue light streak effect
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF00B4FF).withOpacity(0.4),
                    const Color(0xFF0066FF).withOpacity(0.6),
                    const Color(0xFF00B4FF).withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4FF).withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              children: [
                Row(
                  children: [
                    // Logo/Brand Section
                    Expanded(
                      child: Row(
                        children: [
                          // Logo Image
                          Image.asset(
                            'assets/splash_logo.png',
                            height: 45.h,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 45.w,
                                height: 45.w,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF0066FF),
                                      const Color(0xFF00B4FF),
                                      Colors.grey[300]!,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.abc,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 12.w),
                          // Brand Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BYTE BOX',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xFF00B4FF).withOpacity(0.5),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Smart Tech. Smart Price.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    color: Colors.white70,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Cart Icon with Badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF00B4FF).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.all(10.w),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFF6B35),
                                  const Color(0xFFFF8C66),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF6B35).withOpacity(0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              '0',
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    // Notification Icon
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00B4FF).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.all(10.w),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h)
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- NEW ARRIVALS ----------------
  Widget _buildNewArrivalsSection(
      BuildContext context, HomeState homeState) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _sectionHeader(
              title: 'New Arrivals',
              subtitle: 'Latest additions to our collection',
              icon: Icons.new_releases_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NewArrivalsPage(),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          NewArrivalSlider(),
        ],
      ),
    );
  }


  // ---------------- BEST DEALS ----------------
  Widget _buildBestDealsSection(
      BuildContext context, HomeState homeState) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _sectionHeader(
              title: 'Best Deals',
              subtitle: 'Special offers just for you',
              icon: Icons.local_offer_rounded,
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BestDealListPage(),
                  ),
                ),
              }
            ),
          ),
          SizedBox(height: 16.h),
          BestDealSlider(),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    String? subtitle,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See All',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12.sp,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceHighlights() {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Choose Us',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _ServiceItem(
                  icon: Icons.local_shipping_rounded,
                  title: 'Free Shipping',
                  subtitle: 'All Orders',
                  gradient: [AppColors.primary, AppColors.primaryLight],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ServiceItem(
                  icon: Icons.verified_user_rounded,
                  title: 'Warranty',
                  subtitle: '1 Year',
                  gradient: [AppColors.success, const Color(0xFF34D399)],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ServiceItem(
                  icon: Icons.support_agent_rounded,
                  title: 'Support',
                  subtitle: '24/7',
                  gradient: [AppColors.accent, AppColors.accentLight],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 100.h,
      ),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 8.sp,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
