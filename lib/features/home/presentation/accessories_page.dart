import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import 'accessories_detail_page.dart';

class AccessoriesPage extends StatelessWidget {
  const AccessoriesPage({super.key});

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

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Accessories',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accessories',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            SizedBox(height: 16.h),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('accessories')
                    .where('isActive', isEqualTo: true)
                    .orderBy('price', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed to load accessories',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final items = docs
                      .map((d) =>
                          _AccessoryItem.fromMap(d.data() as Map<String, dynamic>))
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${items.length} products',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Expanded(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16.w,
                            mainAxisSpacing: 16.h,
                            childAspectRatio:
                                isDesktop ? 3.4 : (isTablet ? 2.8 : 2.2),
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _AccessoryCard(item: item);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessoryItem {
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

  factory _AccessoryItem.fromMap(Map<String, dynamic> data) {
    final rawImages = data['images'];
    final images = (rawImages is List)
        ? rawImages.map((e) => e.toString()).toList()
        : const <String>[];

    double? mrp;
    final rawMrp = data['mrp'];
    if (rawMrp is num) {
      mrp = rawMrp.toDouble();
    } else if (rawMrp is String) {
      mrp = double.tryParse(rawMrp);
    }

    final rawPrice = data['price'];
    final price = (rawPrice is num)
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '') ?? 0;

    return _AccessoryItem(
      brand: (data['brand'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      color: (data['color'] ?? '').toString(),
      price: price,
      mrp: mrp,
      discountLabel: (data['discountLabel'] ?? '').toString(),
      emiText: (data['emiText'] ?? '').toString(),
      isSoldOut: data['isSoldOut'] == true,
      images: images,
    );
  }
}

class _AccessoryCard extends StatelessWidget {
  final _AccessoryItem item;

  const _AccessoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AccessoriesDetailPage(
              brand: item.brand,
              name: item.name,
              color: item.color,
              price: item.price,
              mrp: item.mrp,
              emiText: item.emiText,
            ),
          ),
        );
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    Container(
                      width: 90.w,
                      height: 90.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: item.images.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.network(
                                item.images.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.headphones_rounded,
                                  size: 40.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.headphones_rounded,
                              size: 40.sp,
                              color: AppColors.primary,
                            ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.brand,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item.name,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item.color,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Text(
                                '₹ ${item.price.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (item.mrp != null) ...[
                                SizedBox(width: 6.w),
                                Text(
                                  '₹ ${item.mrp!.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  item.discountLabel,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.sp,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item.emiText,
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: AppColors.primary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 6.h,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AccessoriesDetailPage(
                                          brand: item.brand,
                                          name: item.name,
                                          color: item.color,
                                          price: item.price,
                                          mrp: item.mrp,
                                          emiText: item.emiText,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Quick View',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 6.h,
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    'Compare',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
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
              if (item.isSoldOut)
                Positioned(
                  top: 8.h,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8.r),
                        bottomRight: Radius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'SOLDOUT',
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

