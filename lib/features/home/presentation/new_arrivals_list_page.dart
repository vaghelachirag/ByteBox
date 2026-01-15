import 'package:bytebox/features/home/presentation/product_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../model/NewArrivalModel.dart';

/// ------------------------------------------------------------
/// FILTER OPTIONS
/// ------------------------------------------------------------
const availableBrands = ['Dell', 'HP', 'Lenovo', 'Apple', 'Asus'];
const availableRAM = ['8 GB', '12 GB','16 GB', '32 GB'];
const availableSSD = ['256 GB', '512 GB', '1 TB'];

class NewArrivalsPage extends StatefulWidget {
  const NewArrivalsPage({super.key});

  @override
  State<NewArrivalsPage> createState() => _NewArrivalsPageState();
}

class _NewArrivalsPageState extends State<NewArrivalsPage> {
  final _dbRef = FirebaseDatabase.instance.ref('new_arrivals');

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

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('New Arrivals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _openFilterSheet,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search laptops...',
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
            child: StreamBuilder<DatabaseEvent>(
              stream: _dbRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const _LoadingState();
                }

                if (snapshot.hasError) {
                  return _ErrorState(error: snapshot.error.toString());
                }

                final data = snapshot.data?.snapshot.value;
                if (data == null) return const _EmptyState();

                final map = Map<dynamic, dynamic>.from(data as Map);
                final allProducts = map.entries
                    .map((e) => NewArrivalModel.fromMap(
                  e.key,
                  Map<dynamic, dynamic>.from(e.value),
                ))
                    .toList();

                final products = _applyAll(allProducts);
                if (products.isEmpty) return const _EmptyState();

                return GridView.builder(
                  padding: EdgeInsets.all(16.w),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    mainAxisExtent: size.height * 0.35,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) =>
                      ProductCard(product: products[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// PRODUCT CARD
/// ------------------------------------------------------------
class ProductCard extends StatelessWidget {
  final NewArrivalModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToDetail(context, product),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                // Product Image
                Container(
                  height: 160,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: product.images.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: product.images.first,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                  )
                      : Container(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 40),
                    ),
                  ),
                ),

                // Badges
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'NEW',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Subtitle (Processor)
                  Text(
                    product.processor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Specs
                  Row(
                    children: [
                      _buildSpecChip(
                        context,
                        icon: Icons.memory,
                        label: product.ram,
                      ),
                      const SizedBox(width: 8),
                      _buildSpecChip(
                        context,
                        icon: Icons.storage,
                        label: product.storage,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Price & Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Price
                      Text(
                        '₹${NumberFormat('#,##0').format(product.price)}',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecChip(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, NewArrivalModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }
}


/// ------------------------------------------------------------
/// REDESIGNED FILTER BOTTOM SHEET
/// ------------------------------------------------------------
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filters',
                      style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        brands.clear();
                        ram.clear();
                        storage.clear();
                        min = 0;
                        max = 200000;
                      });
                    },
                    child: const Text('Clear All'),
                  )
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _section('Brand', availableBrands, brands),
                    _section('RAM', availableRAM, ram),
                    _section('Storage', availableSSD, storage),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Price Range'),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('₹${min.toInt()}'),
                                Text('₹${max.toInt()}'),
                              ],
                            ),
                            RangeSlider(
                              values: RangeValues(min, max),
                              min: 0,
                              max: 200000,
                              divisions: 100,
                              onChanged: (v) {
                                setState(() {
                                  min = v.start;
                                  max = v.end;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () {
                    widget.onApply(brands, ram, storage, min, max);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _section(
      String title, List<String> items, Set<String> selected) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((e) {
                final selectedItem = selected.contains(e);
                return ChoiceChip(
                  label: Text(e),
                  selected: selectedItem,
                  onSelected: (_) {
                    setState(() {
                      selectedItem
                          ? selected.remove(e)
                          : selected.add(e);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
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
  Widget build(BuildContext context) =>
      Center(child: Text(error));
}
