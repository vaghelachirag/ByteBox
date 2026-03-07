import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class AccessoriesDetailPage extends StatelessWidget {
  final String accessoryId;
  final String? initialTitle;

  const AccessoriesDetailPage({
    super.key,
    required this.accessoryId,
    this.initialTitle,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 800;

    final docStream = FirebaseFirestore.instance
        .collection('accessories')
        .doc(accessoryId)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docStream,
      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        final brand = _toString(data?['brand']);
        final name = _toString(data?['name']);
        final color = _toString(data?['color']);
        final price = _toDouble(data?['price']);
        final mrp = _toNullableDouble(data?['mrp']);
        final emiText = _toString(data?['emiText']);
        final images = _toStringList(data?['images']);

        final titleText = name.isNotEmpty
            ? name
            : (initialTitle?.trim().isNotEmpty ?? false)
                ? initialTitle!.trim()
                : 'Accessory';

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              iconTheme: const IconThemeData(color: Colors.black),
              title: Text(
                titleText,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            body: Center(
              child: Text(
                'Error loading accessory',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              iconTheme: const IconThemeData(color: Colors.black),
              title: Text(
                titleText,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || data == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              iconTheme: const IconThemeData(color: Colors.black),
              title: Text(
                titleText,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            body: Center(
              child: Text(
                'Accessory not found',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(
              titleText,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _AccessoryGallery(images: images),
                        ),
                        SizedBox(width: 24.w),
                        Expanded(
                          flex: 6,
                          child: _buildDetailSection(
                            context,
                            brand: brand,
                            name: name,
                            color: color,
                            price: price,
                            mrp: mrp,
                            emiText: emiText,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AccessoryGallery(images: images),
                        SizedBox(height: 16.h),
                        _buildDetailSection(
                          context,
                          brand: brand,
                          name: name,
                          color: color,
                          price: price,
                          mrp: mrp,
                          emiText: emiText,
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required String brand,
    required String name,
    required String color,
    required double price,
    required double? mrp,
    required String emiText,
  }) {
    int quantity = 1;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              brand,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Text(
                  '₹ ${price.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (mrp != null) ...[
                  SizedBox(width: 6.w),
                  Text(
                    '₹ ${mrp!.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
                SizedBox(width: 8.w),
                Text(
                  '($emiText)',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_shipping_rounded,
                    size: 14.sp,
                    color: Colors.green.shade700,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Enjoy Free Shipping',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Condition',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: [
                _buildConditionChip('Fair', isSelected: false),
                _buildConditionChip('Good', isSelected: false),
                _buildConditionChip('Superb', isSelected: true),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Select color: $color',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildColorDot(Colors.black, isSelected: true),
                SizedBox(width: 8.w),
                _buildColorDot(Colors.red),
                SizedBox(width: 8.w),
                _buildColorDot(Colors.grey),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Quantity',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                        icon: const Icon(Icons.remove),
                        visualDensity: VisualDensity.compact,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          '$quantity',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => quantity++);
                        },
                        icon: const Icon(Icons.add),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer_rounded,
                    size: 18.sp,
                    color: Colors.orange.shade800,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Holi Festival Sale – Free goodies worth ₹8,000 with code NJ-HOLI26',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    onPressed: () {},
                    child: Text(
                      'Add to Cart',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    onPressed: () {},
                    child: Text(
                      'Buy Now',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildConditionChip(String text, {bool isSelected = false}) {
    return ChoiceChip(
      label: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {},
      selectedColor: Colors.green.shade600,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }

  Widget _buildColorDot(Color color, {bool isSelected = false}) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: CircleAvatar(
        radius: 10.w,
        backgroundColor: color,
      ),
    );
  }
}

class _AccessoryGallery extends StatefulWidget {
  final List<String> images;

  const _AccessoryGallery({required this.images});

  @override
  State<_AccessoryGallery> createState() => _AccessoryGalleryState();
}

class _AccessoryGalleryState extends State<_AccessoryGallery> {
  int selected = 0;

  void _openFullscreenViewer() {
    final images = widget.images;
    if (images.isEmpty) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullscreenImageViewer(
          images: images,
          initialIndex: selected.clamp(0, images.length - 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    final hasImages = images.isNotEmpty;
    final mainUrl = hasImages ? images[selected.clamp(0, images.length - 1)] : '';

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'Live Store',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: hasImages
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _openFullscreenViewer,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(mainUrl, fit: BoxFit.cover),
                          Positioned(
                            right: 10.w,
                            bottom: 10.h,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.zoom_out_map_rounded,
                                    size: 14.sp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'View',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.speaker,
                      size: 80.sp,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ),
        if (images.length > 1) ...[
          SizedBox(height: 12.h),
          SizedBox(
            height: 70.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final isSelected = index == selected;
                return InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () => setState(() => selected = index),
                  child: Container(
                    width: 70.h,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                      color: Colors.white,
                    ),
                    child: Image.network(images[index], fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

double _toDouble(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

double? _toNullableDouble(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

List<String> _toStringList(Object? v) {
  if (v is List) {
    return v.whereType<String>().toList();
  }
  return const [];
}

String _toString(Object? v) {
  if (v == null) return '';
  if (v is String) return v;
  return v.toString();
}

class _FullscreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullscreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.images.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    panEnabled: true,
                    scaleEnabled: true,
                    child: Image.network(
                      images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 10.h,
              left: 10.w,
              right: 10.w,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${_index + 1}/${images.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
}

