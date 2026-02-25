import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../model/best_deal_model.dart';
import '../../../model/NewArrivalModel.dart';
import '../../../widget/animated_percentage_badge.dart';
import '../../../widget/app_header.dart';
import 'product_detail_page.dart';

class BestDealListPage extends StatefulWidget {
  const BestDealListPage({super.key});

  @override
  State<BestDealListPage> createState() => _BestDealListPageState();
}

class _BestDealListPageState extends State<BestDealListPage> {
  final _dbRef = FirebaseFirestore.instance.collection('best_deals');


  String searchQuery = '';
  double minPrice = 0;
  double maxPrice = 200000;

  List<BestDealModel> _applyAll(List<BestDealModel> list) {
    final searched = searchQuery.isEmpty
        ? list
        : list.where((p) =>
    p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        p.overview.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return searched
        .where((p) => p.price >= minPrice && p.price <= maxPrice)
        .toList();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        minPrice: minPrice,
        maxPrice: maxPrice,
        onApply: (min, max) {
          setState(() {
            minPrice = min;
            maxPrice = max;
          });
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, BestDealModel item) {
    final product = NewArrivalModel(
      id: item.id,
      name: item.name,
      overview: item.overview,
      price: item.discountPrice,
      images: item.images,
      company: item.company,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cardWidth = (screenWidth - 48.w) / 2;
    final cardHeight = ((cardWidth / 0.45) + 12.h)
        .clamp(cardWidth * 1.5, screenHeight * 0.5);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppHeader(
        title: 'Best Deals',
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
                hintText: 'Search best deals...',
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
            child: StreamBuilder<QuerySnapshot>(
              stream: _dbRef
                  .where('isActive', isEqualTo: true)
                  .orderBy('discountPercent', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _LoadingState();
                }

                if (snapshot.hasError) {
                  return _ErrorState(error: snapshot.error.toString());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const _EmptyState();
                }

                final products = _applyAll(
                  snapshot.data!.docs.map((doc) {
                    return BestDealModel.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    );
                  }).toList(),
                );

                if (products.isEmpty) return const _EmptyState();

                return GridView.builder(
                  padding: EdgeInsets.all(16.w),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 16.w,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _navigateToDetail(context, products[i]),
                    child: BestDealCard(product: products[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BestDealCard extends StatelessWidget {
  final BestDealModel product;

  const BestDealCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl:
                  product.images.isNotEmpty ? product.images.first : '',
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                  const Icon(Icons.image_not_supported),
                ),
                if (product.discountPercent > 0)
                  AnimatedPercentageBadge(
                    discount: product.discountPercent,
                    top: 8,
                    right: 8,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // 🔥 important
                children: [
                  Text(
                    product.company,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹${NumberFormat('#,##0').format(product.discountPrice)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                          height: 1.0
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '₹${NumberFormat('#,##0').format(product.originalPrice)}',
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                          height: 1.0,
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
    );
  }
}

/// ------------------------------------------------------------
class FilterBottomSheet extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final Function(double, double) onApply;

  const FilterBottomSheet({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double min;
  late double max;

  @override
  void initState() {
    super.initState();
    min = widget.minPrice;
    max = widget.maxPrice;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          children: [
            Text('Price Range',
                style: GoogleFonts.poppins(
                    fontSize: 18.sp, fontWeight: FontWeight.bold)),
            RangeSlider(
              values: RangeValues(min, max),
              min: 0,
              max: 200000,
              divisions: 200,
              activeColor: AppColors.accent,
              onChanged: (values) =>
                  setState(() => {min = values.start, max = values.end}),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onApply(min, max);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            )
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
