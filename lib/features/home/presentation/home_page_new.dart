import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../model/category_model.dart';
import '../../../widget/best_deal_slider.dart';
import '../../../widget/new_arrival_slider.dart';
import '../providers/home_provider.dart';
import 'accessories_page.dart';
import 'best_deal_list_page.dart';
import 'new_arrivals_list_page.dart';
import 'package:bytebox/widget/banner_widget.dart';
import 'package:bytebox/features/ai_chat/presentation/ai_chat_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          final isDesktop = constraints.maxWidth >= 1024;
          final bannerHeight = isDesktop
              ? 320.h
              : isTablet
                  ? 260.h
                  : 200.h;

          final maxContentWidth = isDesktop ? 1200.0 : constraints.maxWidth;

          return SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(context)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child:
                            SizedBox(height: bannerHeight, child: const BannerSlider()),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildCategoryStrip(),
                    ),
                    SliverToBoxAdapter(
                      child: _buildFeaturedCategoriesGrid(),
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
            ),
          );
        },
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
                    // AI Chat Icon
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AiChatPage()),
                        );
                      },
                      child: Container(
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
                          Icons.smart_toy_outlined,
                          color: Colors.white,
                          size: 22.sp,
                        ),
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
                  title: 'Free Delivery',
                  subtitle: 'On select locations',
                  gradient: [AppColors.primary, AppColors.primaryLight],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ServiceItem(
                  icon: Icons.verified_user_rounded,
                  title: 'Warranty Covered',
                  subtitle: 'Up to 1 Year',
                  gradient: [AppColors.success, const Color(0xFF34D399)],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ServiceItem(
                  icon: Icons.support_agent_rounded,
                  title: 'Expert Support',
                  subtitle: 'Store & online',
                  gradient: [AppColors.accent, AppColors.accentLight],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStrip() {
    final categories = [
      CategoryData(image: "assets/icon/laptop.png", label: "Laptops"),
      CategoryData(image: "assets/icon/desktop.png", label: "Desktops"),
      CategoryData(image: "assets/icon/mini_pc.png", label: "Mini PC"),
      CategoryData(image: "assets/icon/tablet.png", label: "Tablet"),
      CategoryData(image: "assets/icon/all_in_one.png", label: "All in One"),
      CategoryData(image: "assets/icon/accessories.png", label: "Accessories"),
    ];

    return Column(
      children: [
        SizedBox(height: 20.h),

        /// Title
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold),
            children: const [
              TextSpan(
                text: "Explore ",
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: "Refurbished",
                style: TextStyle(color: Colors.green),
              ),
              TextSpan(
                text: " Tech",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),

        SizedBox(height: 30.h),

        SizedBox(
          height: 130.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GestureDetector(
                  onTap: () {
                    if (category.label == 'Accessories') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AccessoriesPage(),
                        ),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 90.w,
                        height: 90.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade100,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Image.asset(
                            category.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------- FEATURED CATEGORIES GRID ----------------
  Widget _buildFeaturedCategoriesGrid() {
    final tiles = [
      _CategoryTileData(
        title: 'Shop Laptops',
        subtitle: 'Business • Student • Gaming',
        icon: Icons.laptop_chromebook_rounded,
        color: const Color(0xFF1D4ED8),
      ),
      _CategoryTileData(
        title: 'Exchange & Upgrade',
        subtitle: 'Upgrade your old laptop',
        icon: Icons.swap_horiz_rounded,
        color: const Color(0xFF059669),
      ),
      _CategoryTileData(
        title: 'Accessories',
        subtitle: 'Bags • Mouse • Keyboards',
        icon: Icons.headphones_rounded,
        color: const Color(0xFF7C3AED),
      ),
      _CategoryTileData(
        title: 'Store Locator',
        subtitle: 'Find nearby stores',
        icon: Icons.location_on_rounded,
        color: const Color(0xFFEA580C),
      ),
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore by category',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: tiles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.7,
            ),
            itemBuilder: (context, index) {
              final tile = tiles[index];
              VoidCallback? onTap;
              if (tile.title == 'Accessories') {
                onTap = () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AccessoriesPage(),
                    ),
                  );
                };
              }
              return _FeaturedCategoryTile(
                data: tile,
                onTap: onTap,
              );
            },
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

class _CategoryData {
  final IconData icon;
  final String label;

  _CategoryData({
    required this.icon,
    required this.label,
  });
}

class _CategoryChip extends StatelessWidget {
  final _CategoryData data;

  const _CategoryChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            data.icon,
            color: AppColors.primary,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            data.label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTileData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  _CategoryTileData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _FeaturedCategoryTile extends StatelessWidget {
  final _CategoryTileData data;
  final VoidCallback? onTap;

  const _FeaturedCategoryTile({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              data.color.withOpacity(0.12),
              data.color.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: data.color.withOpacity(0.35),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(10.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                data.icon,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    data.subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
