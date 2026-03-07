import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../widget/app_header.dart';
import 'accessories_detail_page.dart';

class _NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class AccessoriesPage extends StatefulWidget {
  const AccessoriesPage({super.key});

  @override
  State<AccessoriesPage> createState() => _AccessoriesPageState();
}

class _AccessoriesPageState extends State<AccessoriesPage> {
  final Set<String> selectedBrands = {};
  final Set<String> selectedColors = {};
  double minPrice = 0;
  double maxPrice = 200000;
  bool hideSoldOut = false;

  List<_AccessoryItem> _applyAll(List<_AccessoryItem> list) {
    return list.where((p) {
      final brandOk =
          selectedBrands.isEmpty || selectedBrands.contains(p.brand);
      final colorOk =
          selectedColors.isEmpty || selectedColors.contains(p.color);
      final priceOk = p.price >= minPrice && p.price <= maxPrice;
      final soldOutOk = !hideSoldOut || !p.isSoldOut;

      return brandOk && colorOk && priceOk && soldOutOk;
    }).toList();
  }

  void _openFilterSheet({
    required List<String> availableBrands,
    required List<String> availableColors,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AccessoriesFilterBottomSheet(
        availableBrands: availableBrands,
        availableColors: availableColors,
        selectedBrands: selectedBrands,
        selectedColors: selectedColors,
        minPrice: minPrice,
        maxPrice: maxPrice,
        hideSoldOut: hideSoldOut,
        onApply: (b, c, min, max, hide) {
          setState(() {
            selectedBrands
              ..clear()
              ..addAll(b);
            selectedColors
              ..clear()
              ..addAll(c);
            minPrice = min;
            maxPrice = max;
            hideSoldOut = hide;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final isTablet = size.width >= 600;
    final isDesktop = size.width >= 1024;

    int crossAxisCount = 1;

    if (isDesktop) {
      crossAxisCount = 3;
    } else if (isTablet) {
      crossAxisCount = 2;
    }

    final stream = FirebaseFirestore.instance
        .collection('accessories')
        .where('isActive', isEqualTo: true)
        .orderBy('price', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        final items = docs
            .map((d) => _AccessoryItem.fromFirestore(d))
            .toList();

        final availableBrands = items
            .map((e) => e.brand.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        final availableColors = items
            .map((e) => e.color.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        final openFilters = snapshot.hasData
            ? () => _openFilterSheet(
                  availableBrands: availableBrands,
                  availableColors: availableColors,
                )
            : null;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppHeader(
              title: 'Accessories',
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.filter_list_rounded,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  onPressed: openFilters,
                ),
              ],
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppHeader(
              title: 'Accessories',
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.filter_list_rounded,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  onPressed: openFilters,
                ),
              ],
            ),
            body: Center(
              child: Text(
                "Error loading products",
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          );
        }

        final filteredItems = _applyAll(items);

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppHeader(
            title: 'Accessories',
            actions: [
              IconButton(
                icon: Icon(
                  Icons.filter_list_rounded,
                  color: Colors.white,
                  size: 24.sp,
                ),
                onPressed: openFilters,
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${filteredItems.length} Products",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: _NoOverscrollBehavior(),
                    child: GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      itemCount: filteredItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio:
                            isDesktop ? 3.2 : (isTablet ? 2.6 : 2.2),
                      ),
                      itemBuilder: (context, index) {
                        return _AccessoryCard(item: filteredItems[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AccessoriesFilterBottomSheet extends StatefulWidget {
  final List<String> availableBrands;
  final List<String> availableColors;
  final Set<String> selectedBrands;
  final Set<String> selectedColors;
  final double minPrice;
  final double maxPrice;
  final bool hideSoldOut;
  final void Function(
    Set<String> brands,
    Set<String> colors,
    double min,
    double max,
    bool hideSoldOut,
  ) onApply;

  const AccessoriesFilterBottomSheet({
    super.key,
    required this.availableBrands,
    required this.availableColors,
    required this.selectedBrands,
    required this.selectedColors,
    required this.minPrice,
    required this.maxPrice,
    required this.hideSoldOut,
    required this.onApply,
  });

  @override
  State<AccessoriesFilterBottomSheet> createState() =>
      _AccessoriesFilterBottomSheetState();
}

class _AccessoriesFilterBottomSheetState
    extends State<AccessoriesFilterBottomSheet> {
  late Set<String> brands;
  late Set<String> colors;
  late double min;
  late double max;
  late bool hideSoldOut;

  @override
  void initState() {
    super.initState();
    brands = {...widget.selectedBrands};
    colors = {...widget.selectedColors};
    min = widget.minPrice;
    max = widget.maxPrice;
    hideSoldOut = widget.hideSoldOut;
  }

  int get _activeFilterCount {
    int count = 0;
    if (brands.isNotEmpty) count += brands.length;
    if (colors.isNotEmpty) count += colors.length;
    if (min > 0 || max < 200000) count += 1;
    if (hideSoldOut) count += 1;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: BoxDecoration(
          color: const Color(0xFF050914),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0BA8FF).withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.h),
              height: 5.h,
              width: 46.w,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: const Color(0xFF0BA8FF),
                    size: 22.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Filters',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (_activeFilterCount > 0) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0BA8FF),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '$_activeFilterCount',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        brands.clear();
                        colors.clear();
                        min = 0;
                        max = 200000;
                        hideSoldOut = false;
                      });
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.white.withOpacity(0.08),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChipSection(
                      title: 'Brand',
                      icon: Icons.branding_watermark_rounded,
                      items: widget.availableBrands,
                      selected: brands,
                    ),
                    SizedBox(height: 16.h),
                    _buildChipSection(
                      title: 'Color',
                      icon: Icons.palette_rounded,
                      items: widget.availableColors,
                      selected: colors,
                    ),
                    SizedBox(height: 16.h),
                    _buildPriceSection(),
                    SizedBox(height: 16.h),
                    SwitchListTile(
                      value: hideSoldOut,
                      onChanged: (v) => setState(() => hideSoldOut = v),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF0BA8FF),
                      title: Text(
                        'Hide sold out',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                      subtitle: Text(
                        'Show only available items',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFF0BA8FF).withOpacity(0.9),
                        ),
                        foregroundColor: Colors.white70,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(brands, colors, min, max, hideSoldOut);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0BA8FF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Apply',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required Set<String> selected,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0BA8FF), size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: items.map((item) {
              final isSelected = selected.contains(item);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selected.remove(item);
                    } else {
                      selected.add(item);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0BA8FF)
                        : Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.10),
                    ),
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.currency_rupee_rounded,
                color: const Color(0xFF0BA8FF),
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Price Range',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '₹${min.toInt()} - ₹${max.toInt()}',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF0BA8FF),
              inactiveTrackColor: Colors.white24,
              thumbColor: const Color(0xFF2DD3FF),
              overlayColor: const Color(0xFF2DD3FF).withOpacity(0.18),
              trackHeight: 4,
            ),
            child: RangeSlider(
              values: RangeValues(min, max),
              min: 0,
              max: 200000,
              divisions: 200,
              onChanged: (values) {
                setState(() {
                  min = values.start;
                  max = values.end;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessoryItem {
  final String id;
  final String brand;
  final String name;
  final String color;
  final double price;
  final double? mrp;
  final String discountLabel;
  final String emiText;
  final bool isSoldOut;
  final List<String> images;

  const _AccessoryItem({
    required this.id,
    required this.brand,
    required this.name,
    required this.color,
    required this.price,
    this.mrp,
    required this.discountLabel,
    required this.emiText,
    this.isSoldOut = false,
    this.images = const [],
  });

  factory _AccessoryItem.fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    List<String> images = [];

    if (data['images'] != null) {
      images = List<String>.from(data['images']);
    }

    double price = 0;
    if (data['price'] is num) {
      price = (data['price'] as num).toDouble();
    }

    double? mrp;
    if (data['mrp'] is num) {
      mrp = (data['mrp'] as num).toDouble();
    }

    return _AccessoryItem(
      id: doc.id,
      brand: data['brand'] ?? "",
      name: data['name'] ?? "",
      color: data['color'] ?? "",
      price: price,
      mrp: mrp,
      discountLabel: data['discountLabel'] ?? "",
      emiText: data['emiText'] ?? "",
      isSoldOut: data['isSoldOut'] ?? false,
      images: images,
    );
  }
}

class _AccessoryCard extends StatelessWidget {
  final _AccessoryItem item;

  const _AccessoryCard({required this.item});

  int _calculateDiscount() {
    if (item.mrp == null || item.mrp == 0) return 0;
    return (((item.mrp! - item.price) / item.mrp!) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final discount = _calculateDiscount();

    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AccessoriesDetailPage(
              accessoryId: item.id,
              initialTitle: item.name,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  /// PRODUCT IMAGE
                  Container(
                    width: 95.w,
                    height: 95.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      color: Colors.grey.shade100,
                    ),
                    child: item.images.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: Image.network(
                        item.images.first,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Icon(
                      Icons.headphones,
                      size: 40.sp,
                      color: AppColors.primary,
                    ),
                  ),

                  SizedBox(width: 14.w),

                  /// DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.brand.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          item.color,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        /// PRICE
                        Row(
                          children: [
                            Text(
                              "₹${item.price.toStringAsFixed(0)}",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (item.mrp != null) ...[
                              SizedBox(width: 6.w),
                              Text(
                                "₹${item.mrp!.toStringAsFixed(0)}",
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ]
                          ],
                        ),

                        SizedBox(height: 4.h),

                        const Spacer(),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding:
                                  EdgeInsets.symmetric(vertical: 8.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(8.r),
                                  ),
                                ),
                                onPressed: () {},
                                child: Text(
                                  "View",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          /// 🔴 DISCOUNT BADGE
          if (discount > 0)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  "$discount% OFF",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}