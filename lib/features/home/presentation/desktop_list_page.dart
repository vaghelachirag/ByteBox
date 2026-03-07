import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../model/NewArrivalModel.dart';
import '../../../widget/product_card.dart';
import '../../../widget/app_header.dart';
import '../providers/desktop_list_provider.dart';

const availableBrands = ['Dell', 'HP', 'Lenovo', 'Apple', 'Asus'];
const availableRAM = ['8 GB', '12 GB', '16 GB', '32 GB'];
const availableSSD = ['256 GB', '512 GB', '1 TB'];

class DesktopListPage extends ConsumerStatefulWidget {
  const DesktopListPage({super.key});

  @override
  ConsumerState<DesktopListPage> createState() => _DesktopListPageState();
}

class _DesktopListPageState extends ConsumerState<DesktopListPage> {
  String searchQuery = '';

  final Set<String> selectedBrands = {};
  final Set<String> selectedRAM = {};
  final Set<String> selectedStorage = {};
  double minPrice = 0;
  double maxPrice = 200000;

  List<NewArrivalModel> _applyAll(List<NewArrivalModel> list) {
    final searched = searchQuery.isEmpty
        ? list
        : list.where((p) {
            return p.name
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                p.processor
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase());
          }).toList();

    return searched.where((p) {
      final brandOk =
          selectedBrands.isEmpty || selectedBrands.contains(p.company);
      final ramOk = selectedRAM.isEmpty || selectedRAM.contains(p.ram);
      final storageOk =
          selectedStorage.isEmpty || selectedStorage.contains(p.storage);
      final priceOk = p.price >= minPrice && p.price <= maxPrice;

      return brandOk && ramOk && storageOk && priceOk;
    }).toList();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        selectedBrands: selectedBrands,
        selectedRAM: selectedRAM,
        selectedStorage: selectedStorage,
        minPrice: minPrice,
        maxPrice: maxPrice,
        onApply: (b, r, s, min, max) {
          setState(() {
            selectedBrands
              ..clear()
              ..addAll(b);
            selectedRAM
              ..clear()
              ..addAll(r);
            selectedStorage
              ..clear()
              ..addAll(s);
            minPrice = min;
            maxPrice = max;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    final horizontalPadding = 16.w * 2;
    final crossAxisSpacing = 16.w;
    final availableWidth = screenWidth - horizontalPadding - crossAxisSpacing;
    final cardWidth = availableWidth / 2;

    final cardHeight = ((cardWidth / 0.65) + 10.h).clamp(
      cardWidth * 1.5,
      screenHeight * 0.5,
    );

    final productsAsync = ref.watch(desktopFirebaseProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppHeader(
        title: 'Desktops',
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search Desktops...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => const _LoadingState(),
              error: (e, _) => _ErrorState(error: e.toString()),
              data: (allProducts) {
                if (allProducts.isEmpty) {
                  return const _EmptyState();
                }

                final products = _applyAll(allProducts);

                if (products.isEmpty) return const _EmptyState();

                return GridView.builder(
                  padding: EdgeInsets.all(16.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    mainAxisExtent: cardHeight,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) => ProductCard(product: products[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final Set<String> selectedBrands;
  final Set<String> selectedRAM;
  final Set<String> selectedStorage;
  final double minPrice;
  final double maxPrice;
  final Function(Set<String>, Set<String>, Set<String>, double, double) onApply;

  const FilterBottomSheet({
    super.key,
    required this.selectedBrands,
    required this.selectedRAM,
    required this.selectedStorage,
    required this.minPrice,
    required this.maxPrice,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  static const Color _bg = Color(0xFF050914);
  static const Color _panel = Color(0xFF0C1324);
  static const Color _panelAlt = Color(0xFF111B33);
  static const Color _accent = Color(0xFF0BA8FF);
  static const Color _accentGlow = Color(0xFF2DD3FF);
  static const Color _border = Color(0x332DD3FF);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFF9FB4D6);

  late Set<String> brands;
  late Set<String> ram;
  late Set<String> storage;
  late double min;
  late double max;

  @override
  void initState() {
    super.initState();
    brands = {...widget.selectedBrands};
    ram = {...widget.selectedRAM};
    storage = {...widget.selectedStorage};
    min = widget.minPrice;
    max = widget.maxPrice;
  }

  int get _activeFilterCount {
    int count = 0;
    if (brands.isNotEmpty) count += brands.length;
    if (ram.isNotEmpty) count += ram.length;
    if (storage.isNotEmpty) count += storage.length;
    if (min > 0 || max < 200000) count += 1;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF070E1D),
              _bg,
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.25),
              blurRadius: 30,
              spreadRadius: 4,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              height: 5.h,
              width: 48.w,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          color: _accent,
                          size: 24.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Filters',
                          style: GoogleFonts.poppins(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                        if (_activeFilterCount > 0) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: _accent,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '$_activeFilterCount',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        brands.clear();
                        ram.clear();
                        storage.clear();
                        min = 0;
                        max = 200000;
                      });
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 18.sp,
                      color: _textSecondary,
                    ),
                    label: Text(
                      'Clear All',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.white10,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      icon: Icons.branding_watermark_rounded,
                      title: 'Brand',
                      items: availableBrands,
                      selected: brands,
                    ),
                    SizedBox(height: 20.h),
                    _buildSection(
                      icon: Icons.memory_rounded,
                      title: 'RAM',
                      items: availableRAM,
                      selected: ram,
                    ),
                    SizedBox(height: 20.h),
                    _buildSection(
                      icon: Icons.storage_rounded,
                      title: 'Storage',
                      items: availableSSD,
                      selected: storage,
                    ),
                    SizedBox(height: 20.h),
                    _buildPriceSection(),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: _panel,
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.15),
                    blurRadius: 18,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(
                          color: _accent,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        foregroundColor: _accent,
                        backgroundColor: Colors.transparent,
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(brands, ram, storage, min, max);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: _accentGlow.withOpacity(0.45),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_accent, _accentGlow],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: _accentGlow.withOpacity(0.45),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 14.h,
                          horizontal: 12.w,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Apply Filters',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_activeFilterCount > 0) ...[
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '$_activeFilterCount',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ],
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

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<String> items,
    required Set<String> selected,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _panel,
            _panelAlt,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: _border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: _accent,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: items.map((item) {
              final isSelected = selected.contains(item);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selected.remove(item);
                    } else {
                      selected.add(item);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _accent
                        : Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : _border,
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _accentGlow.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? _textPrimary : _textSecondary,
                        ),
                      ),
                      if (isSelected) ...[
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16.sp,
                          color: _textPrimary,
                        ),
                      ],
                    ],
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _panel,
            _panelAlt,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: _border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.currency_rupee_rounded,
                  size: 20.sp,
                  color: _accent,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Price Range',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _border,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Min Price',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: _textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '₹${NumberFormat('#,###').format(min.toInt())}',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _border,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Max Price',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: _textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '₹${NumberFormat('#,###').format(max.toInt())}',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _accent,
              inactiveTrackColor: Colors.white24,
              thumbColor: _accentGlow,
              overlayColor: _accentGlow.withOpacity(0.2),
              trackHeight: 4,
              valueIndicatorColor: _accent,
              valueIndicatorTextStyle: GoogleFonts.poppins(
                color: _textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: RangeSlider(
              values: RangeValues(min, max),
              min: 0,
              max: 200000,
              divisions: 200,
              labels: RangeLabels(
                '₹${NumberFormat.compact().format(min.toInt())}',
                '₹${NumberFormat.compact().format(max.toInt())}',
              ),
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

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('No products found'));
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) => Center(child: Text(error));
}

