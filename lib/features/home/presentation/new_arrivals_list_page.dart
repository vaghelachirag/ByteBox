import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/home_provider.dart';
import '../providers/new_arrivals_list_provider.dart';
import 'product_detail_page.dart';

class NewArrivalsListPage extends ConsumerWidget {
  const NewArrivalsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(newArrivalsListProvider);
    final listNotifier = ref.read(newArrivalsListProvider.notifier);
    final filteredProducts = listNotifier.filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;

            return Column(
              children: [
                // Header
                _buildHeader(context, isMobile),
                // Banner Section
                _buildBannerSection(context, isMobile),
                // Main Content
                Expanded(
                  child: isMobile
                      ? _buildMobileLayout(context, ref, filteredProducts, filterState, listNotifier)
                      : _buildDesktopLayout(context, ref, filteredProducts, filterState, listNotifier),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    List<ProductModel> products,
    FilterState filterState,
    NewArrivalsListNotifier notifier,
  ) {
    return Column(
      children: [
        // Search and Filter Bar (Mobile)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: TextEditingController(text: filterState.searchQuery),
                decoration: InputDecoration(
                  hintText: 'Search by model...',
                  prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                onChanged: (value) => notifier.updateSearchQuery(value),
              ),
              SizedBox(height: 12.h),
              // Filter and Sort Row
              Row(
                children: [
                  // Filter Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => _buildFilterBottomSheet(context, ref, filterState, notifier),
                        );
                      },
                      icon: const Icon(Iconsax.filter, size: 18),
                      label: Text(
                        'Filters',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Sort Dropdown
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButton<String>(
                        value: filterState.sortBy,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(Iconsax.arrow_down_1, color: AppColors.textSecondary, size: 18),
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                        ),
                        items: sortOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option, style: GoogleFonts.poppins(fontSize: 14.sp)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            notifier.setSortBy(value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Product Grid (Mobile)
        Expanded(
          child: _buildProductGrid(context, ref, products, filterState, notifier, true),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    List<ProductModel> products,
    FilterState filterState,
    NewArrivalsListNotifier notifier,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Filter Panel
        _buildFilterPanel(context, ref, filterState, notifier, false),
        // Right Product Grid
        Expanded(
          child: _buildProductGrid(context, ref, products, filterState, notifier, false),
        ),
      ],
    );
  }

  Widget _buildFilterBottomSheet(
    BuildContext context,
    WidgetRef ref,
    FilterState filterState,
    NewArrivalsListNotifier notifier,
  ) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.symmetric(vertical: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.close_circle),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: _buildFilterContent(context, ref, filterState, notifier),
            ),
          ),
          // Bottom Buttons
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      notifier.clearAllFilters();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
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
  }

  Widget _buildFilterContent(
    BuildContext context,
    WidgetRef ref,
    FilterState filterState,
    NewArrivalsListNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter by Brand
        Text(
          'Filter by:',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        ...availableBrands.map((brand) => _buildCheckbox(
              context,
              brand,
              filterState.selectedBrands.contains(brand),
              () => notifier.toggleBrand(brand),
            )),
        SizedBox(height: 20.h),
        // Price Range
        Text(
          'Price Range',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        RangeSlider(
          values: RangeValues(filterState.minPrice, filterState.maxPrice),
          min: 200,
          max: 1000,
          divisions: 80,
          labels: RangeLabels(
            '\$${filterState.minPrice.toInt()}',
            '\$${filterState.maxPrice.toInt()}',
          ),
          onChanged: (values) {
            notifier.updatePriceRange(values.start, values.end);
          },
          activeColor: AppColors.primary,
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${filterState.minPrice.toInt()}',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '\$${filterState.maxPrice.toInt()}',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        // RAM
        Text(
          'RAM',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        ...availableRAM.map((ram) => _buildCheckbox(
              context,
              ram,
              filterState.selectedRAM.contains(ram),
              () => notifier.toggleRAM(ram),
            )),
        SizedBox(height: 20.h),
        // SSD
        Text(
          'SSD',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        ...availableSSD.map((ssd) => _buildCheckbox(
              context,
              ssd,
              filterState.selectedSSD.contains(ssd),
              () => notifier.toggleSSD(ssd),
            )),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: 8.w),
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(
                  Iconsax.lamp,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'RefurbLaptops',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Iconsax.shopping_cart, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          if (!isMobile) ...[
            SizedBox(width: 8.w),
            IconButton(
              icon: const Icon(Iconsax.call, color: AppColors.textPrimary),
              onPressed: () {},
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBannerSection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Arrivals',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 16.sp : 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                'Home',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Iconsax.arrow_right_3, size: 14.sp, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text(
                'New Arrivals',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(
    BuildContext context,
    WidgetRef ref,
    FilterState filterState,
    NewArrivalsListNotifier notifier,
    bool isMobile,
  ) {
    return Container(
      width: isMobile ? double.infinity : 280.w,
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters Title
            Text(
              'Filters',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            // Filter Content
            _buildFilterContent(context, ref, filterState, notifier),
            SizedBox(height: 24.h),
            // Apply Filters Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Clear All
            Center(
              child: GestureDetector(
                onTap: () => notifier.clearAllFilters(),
                child: Text(
                  'Clear All',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(
    BuildContext context,
    String label,
    bool isChecked,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isChecked ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: isChecked
                  ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(
    BuildContext context,
    WidgetRef ref,
    List<ProductModel> products,
    FilterState filterState,
    NewArrivalsListNotifier notifier,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and Sort Bar (Desktop only)
          if (!isMobile)
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: filterState.searchQuery),
                      decoration: InputDecoration(
                        hintText: 'Search by model...',
                        prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                      onChanged: (value) => notifier.updateSearchQuery(value),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButton<String>(
                      value: filterState.sortBy,
                      underline: const SizedBox(),
                      icon: const Icon(Iconsax.arrow_down_1, color: AppColors.textSecondary),
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                      items: sortOptions.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          notifier.setSortBy(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          // Product Grid
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.box_search,
                          size: 64.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No products found',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive grid columns
                      int crossAxisCount;
                      if (constraints.maxWidth > 1200) {
                        crossAxisCount = 3; // Desktop
                      } else if (constraints.maxWidth > 768) {
                        crossAxisCount = 2; // Tablet
                      } else {
                        crossAxisCount = 2; // Mobile
                      }

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                          childAspectRatio: isMobile ? 0.7 : 0.75,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(context, products[index]);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.backgroundLight,
                      child: Icon(
                        Iconsax.lamp,
                        color: AppColors.textTertiary,
                        size: 40.sp,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 3.h),
                        if (product.specifications != null)
                          Text(
                            product.specifications!,
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'From \$${NumberFormat('#,###').format(product.price)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(product: product),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                          child: Text(
                            'View Details',
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

