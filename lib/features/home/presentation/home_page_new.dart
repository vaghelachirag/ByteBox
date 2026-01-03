import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/home_provider.dart';
import 'new_arrivals_list_page.dart';
import 'product_detail_page.dart';



class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, homeState)),
            SliverToBoxAdapter(child: _buildHeroSection()),
            SliverToBoxAdapter(
              child: _buildNewArrivalsSection(context, homeState),
            ),
            SliverToBoxAdapter(
              child: _buildBestDealsSection(context, homeState),
            ),
            SliverToBoxAdapter(child: _buildServiceHighlights()),
            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _buildHeader(BuildContext context, HomeState homeState) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const Icon(Iconsax.lamp, color: Colors.white),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'RefurbLaptops',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Iconsax.shopping_cart),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Iconsax.call),
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: homeState.navigationItems.map((item) {
                final isActive = item == 'Home';
                return Padding(
                  padding: EdgeInsets.only(right: 24.w),
                  child: Column(
                    children: [
                      Text(
                        item,
                        style: GoogleFonts.poppins(
                          fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (isActive)
                        Container(
                          margin: EdgeInsets.only(top: 4.h),
                          height: 2,
                          width: 30,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HERO ----------------
  Widget _buildHeroSection() {
    final banners = [
      'assets/images/banner/home_banner.png',
      'assets/images/banner/home_banner.png',
    ];

    return _AutoScrollBanner(
      bannerImages: banners,
      height: 300.h,
    );
  }

  // ---------------- NEW ARRIVALS ----------------
  Widget _buildNewArrivalsSection(
      BuildContext context, HomeState homeState) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'New Arrivals',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NewArrivalsListPage(),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 350.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: homeState.newArrivals.length,
              itemBuilder: (_, i) =>
                  _productCard(context, homeState.newArrivals[i]),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- BEST DEALS ----------------
  Widget _buildBestDealsSection(
      BuildContext context, HomeState homeState) {
    return Container(
      color: AppColors.backgroundLight,
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(title: 'Best Deals', onTap: () {}),
          SizedBox(height: 16.h),
          SizedBox(
            height: 320.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: homeState.bestDeals.length,
              itemBuilder: (_, i) =>
                  _productCard(context, homeState.bestDeals[i]),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- PRODUCT CARD ----------------
  Widget _productCard(BuildContext context, ProductModel product) {
    return Container(
      width: 240.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Product Image
          GestureDetector(
            onTap: () => _goToDetail(context, product),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Image.asset(
                product.imageUrl,
                height: 140.h,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Product Name
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 6.h),

                /// RAM & Storage
              /*  Text(
                  "${product.description} RAM • ${product.description}",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 4.h),*/

                /// Processor / Specification
                Text(
                  product.specifications ?? "Specifications not available", // e.g. i5 10th Gen | SSD
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 8.h),

                /// Price
                Text(
                  "₹${NumberFormat('#,###').format(product.price)}",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10.h),

                /// View Details Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _goToDetail(context, product),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      "View Details",
                      style: GoogleFonts.poppins(fontSize: 12.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _goToDetail(BuildContext context, ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

  // ---------------- SERVICES ----------------
  Widget _buildServiceHighlights() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _ServiceItem(Iconsax.truck, 'Free Shipping', 'All Orders'),
          _ServiceItem(Iconsax.shield_tick, 'Warranty', '1 Year'),
          _ServiceItem(Iconsax.headphone, 'Support', '24/7 Help'),
        ],
      ),
    );
  }

  // ---------------- COMMON ----------------
  Widget _sectionHeader({required String title, required VoidCallback onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
          GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'See All',
            style: GoogleFonts.poppins(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}


// ---------------- BANNER ----------------
class _AutoScrollBanner extends StatefulWidget {
  final List<String> bannerImages;
  final double height;

  const _AutoScrollBanner({
    required this.bannerImages,
    required this.height,
  });

  @override
  State<_AutoScrollBanner> createState() => _AutoScrollBannerState();
}

class _AutoScrollBannerState extends State<_AutoScrollBanner> {
  final PageController _controller = PageController();
  int index = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) break;

      index = (index + 1) % widget.bannerImages.length;
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.bannerImages.length,
        itemBuilder: (_, i) => Image.asset(
          widget.bannerImages[i],
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}

// ---------------- SERVICE ITEM ----------------
class _ServiceItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ServiceItem(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        SizedBox(height: 8.h),
        Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        Text(subtitle, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }
}
