import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/home_provider.dart';
import '../providers/product_detail_provider.dart';


class ProductDetailPage extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailPage> createState() =>
      _ProductDetailPageState();
}

class _ProductDetailPageState
    extends ConsumerState<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productDetailProvider.notifier)
          .setProduct(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailProvider);
    final notifier = ref.read(productDetailProvider.notifier);
    final product = state.product ?? widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildBreadcrumbs(product)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile =
                        constraints.maxWidth < 768;

                    return isMobile
                        ? Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _buildImageGallery(
                            product, state, notifier),
                        SizedBox(height: 24.h),
                        _buildProductDetails(product),
                      ],
                    )
                        : Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildImageGallery(
                              product, state, notifier),
                        ),
                        SizedBox(width: 40.w),
                        Expanded(
                          child:
                          _buildProductDetails(product),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildTabsSection(context, product, state, notifier),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 40.h)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.all(16.w),
      color: AppColors.primary,
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Iconsax.arrow_left,
                color: Colors.white,
              ),
            ),
          Text(
            'Refurb Laptops',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Icon(Iconsax.shopping_cart, color: Colors.white),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BREADCRUMBS
  // ---------------------------------------------------------------------------
  Widget _buildBreadcrumbs(ProductModel product) {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: AppColors.backgroundDark,
      child: Row(
        children: [
          Text('Home',
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary)),
          SizedBox(width: 8.w),
          Icon(Iconsax.arrow_right_3, size: 14),
          SizedBox(width: 8.w),
          Text('New Arrivals',
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary)),
          SizedBox(width: 8.w),
          Icon(Iconsax.arrow_right_3, size: 14),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              product.name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IMAGE GALLERY
  // ---------------------------------------------------------------------------
  Widget _buildImageGallery(
      ProductModel product,
      ProductDetailState state,
      ProductDetailNotifier notifier,
      ) {
    final images = product.allImages;
    final int safeIndex =
    state.selectedImageIndex.clamp(0, images.length - 1).toInt();

    return Column(
      children: [
        Container(
          height: 420.h,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              Center(
                child: Image.asset(
                  images[safeIndex],
                  fit: BoxFit.contain,
                ),
              ),
              if (images.length > 1)
                Positioned(
                  left: 12,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    onPressed: notifier.previousImage,
                    icon: _arrowButton(Iconsax.arrow_left_2),
                  ),
                ),
              if (images.length > 1)
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    onPressed: notifier.nextImage,
                    icon: _arrowButton(Iconsax.arrow_right_3),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        if (images.length > 1)
          SizedBox(
            height: 90.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) =>
                  SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final selected = index == safeIndex;
                return GestureDetector(
                  onTap: () => notifier.selectImage(index),
                  child: Container(
                    width: 90.w,
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(8.r),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.border,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Image.asset(
                      images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _arrowButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.15),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.textPrimary),
    );
  }

  // ---------------------------------------------------------------------------
  // PRODUCT DETAILS
  // ---------------------------------------------------------------------------
  Widget _buildProductDetails(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '₹${NumberFormat('#,###').format(product.price)}',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        SizedBox(height: 24.h),
        callButton(product)
      ],
    );
  }

  Widget callButton (ProductModel product){
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return isMobile
            ? Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Iconsax.message),
                label:  Text('WhatsApp Buy',style: TextStyle(fontSize: 12.sp),),
                onPressed: () async {
                  final uri = Uri.parse(
                      'https://wa.me/${product.whatsappNumber}');
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(Iconsax.call),
                label:  Text('Call Now',style: TextStyle(fontSize: 12.sp)),
                onPressed: () async {
                  final uri =
                  Uri.parse('tel:${product.name}');
                  await launchUrl(uri);
                },
              ),
            ),
          ],
        )
            : Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Iconsax.message),
                label: const Text('WhatsApp Buy'),
                onPressed: () async {
                  final uri = Uri.parse(
                      'https://wa.me/${product.whatsappNumber}');
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(Iconsax.call),
                label: const Text('Call Now'),
                onPressed: () async {
                  final uri =
                  Uri.parse('tel:${product.name}');
                  await launchUrl(uri);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // TABS SECTION
  // ---------------------------------------------------------------------------
  Widget _buildTabsSection(
    BuildContext context,
    ProductModel product,
    ProductDetailState state,
    ProductDetailNotifier notifier,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;
              if (isMobile) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTab(context, 'Overview', state.selectedTab == 'Overview', () {
                        notifier.selectTab('Overview');
                      }, isMobile),
                      SizedBox(width: 16.w),
                      _buildTab(context, 'Specifications', state.selectedTab == 'Specifications', () {
                        notifier.selectTab('Specifications');
                      }, isMobile),
                      SizedBox(width: 16.w),
                      _buildTab(context, 'Warranty', state.selectedTab == 'Warranty', () {
                        notifier.selectTab('Warranty');
                      }, isMobile),
                      SizedBox(width: 16.w),
                      _buildTab(context, 'Reviews (${product.reviews})', state.selectedTab == 'Reviews', () {
                        notifier.selectTab('Reviews');
                      }, isMobile),
                    ],
                  ),
                );
              } else {
                return Row(
                  children: [
                    _buildTab(context, 'Overview', state.selectedTab == 'Overview', () {
                      notifier.selectTab('Overview');
                    }, isMobile),
                    SizedBox(width: 24.w),
                    _buildTab(context, 'Specifications', state.selectedTab == 'Specifications', () {
                      notifier.selectTab('Specifications');
                    }, isMobile),
                    SizedBox(width: 24.w),
                    _buildTab(context, 'Warranty', state.selectedTab == 'Warranty', () {
                      notifier.selectTab('Warranty');
                    }, isMobile),
                    SizedBox(width: 24.w),
                    _buildTab(context, 'Reviews (${product.reviews})', state.selectedTab == 'Reviews', () {
                      notifier.selectTab('Reviews');
                    }, isMobile),
                  ],
                );
              }
            },
          ),
          SizedBox(height: 32.h),
          // Tab Content
          _buildTabContent(context, product, state.selectedTab),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, bool isActive, VoidCallback onTap, bool isMobile) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 14.sp : 16.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          if (isActive)
            Container(
              height: 2.h,
              width: isMobile ? 80.w : 100.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            )
          else
            SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, ProductModel product, String selectedTab) {
    switch (selectedTab) {
      case 'Specifications':
        return _buildSpecificationsTable(context, product);
      case 'Warranty':
        return _buildWarrantyContent(context);
      case 'Reviews':
        return _buildReviewsContent(context, product);
      case 'Overview':
      default:
        return _buildOverviewContent(context, product);
    }
  }

  Widget _buildOverviewContent(BuildContext context, ProductModel product) {
    return Text(
      product.description,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        color: AppColors.textPrimary,
        height: 1.6,
      ),
    );
  }

  Widget _buildSpecificationsTable(BuildContext context, ProductModel product) {
    final specs = product.detailedSpecs;
    if (specs == null) {
      return Text(
        'No detailed specifications available.',
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildSpecRow('Model', specs.model ?? product.name),
          _buildSpecDivider(),
          _buildSpecRow('Processor', specs.processor),
          _buildSpecDivider(),
          _buildSpecRow('RAM', specs.ram),
          _buildSpecDivider(),
          _buildSpecRow('Storage', specs.storage),
          _buildSpecDivider(),
          _buildSpecRow('Display', specs.display),
          _buildSpecDivider(),
          _buildSpecRow('Battery', specs.battery),
          _buildSpecDivider(),
          _buildSpecRow('Graphics', specs.graphics),
          _buildSpecDivider(),
          _buildSpecRow('Operating System', specs.operatingSystem),
          if (specs.connectivity != null) ...[
            _buildSpecDivider(),
            _buildSpecRow('Connectivity', specs.connectivity),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String? value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      value ?? 'N/A',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150.w,
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        value ?? 'N/A',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSpecDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
    );
  }

  Widget _buildWarrantyContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1 Year Warranty Included',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Get a full year warranty on all refurbished laptops. Buy with confidence knowing your purchase is protected.',
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsContent(BuildContext context, ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Reviews',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          '${product.reviews} customer reviews',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
