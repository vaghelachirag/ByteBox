import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../model/NewArrivalModel.dart';

/// ---------------- FULL SCREEN IMAGE VIEWER ----------------
class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  final TransformationController _transformationController =
  TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map, color: Colors.white),
            onPressed: _resetZoom,
            tooltip: 'Reset Zoom',
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _resetZoom();
          });
        },
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image,
                  size: 80,
                  color: Colors.white54,
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.images.length > 1
          ? Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        color: Colors.black87,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.images.length,
                (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _currentIndex
                    ? Colors.white
                    : Colors.white54,
              ),
            ),
          ),
        ),
      )
          : null,
    );
  }
}

/// ---------------- REVIEW MODEL ----------------
class ReviewModel {
  final String id;
  final String customerName;
  final double rating;
  final String comment;
  final DateTime date;
  final bool verified;

  ReviewModel({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.date,
    this.verified = false,
  });
}

/// ---------------- DUMMY REVIEWS DATA ----------------
final List<ReviewModel> _dummyReviews = [
  ReviewModel(
    id: '1',
    customerName: 'John Smith',
    rating: 5.0,
    comment: 'Excellent laptop! Fast performance and great build quality. The display is crisp and the battery life is amazing. Highly recommended!',
    date: DateTime.now().subtract(const Duration(days: 5)),
    verified: true,
  ),
  ReviewModel(
    id: '2',
    customerName: 'Sarah Johnson',
    rating: 4.5,
    comment: 'Very satisfied with my purchase. The laptop works perfectly for my work needs. Only minor issue is the keyboard could be slightly better.',
    date: DateTime.now().subtract(const Duration(days: 12)),
    verified: true,
  ),
  ReviewModel(
    id: '3',
    customerName: 'Michael Chen',
    rating: 5.0,
    comment: 'Great value for money! Refurbished but looks brand new. Shipping was fast and packaging was excellent.',
    date: DateTime.now().subtract(const Duration(days: 18)),
    verified: false,
  ),
  ReviewModel(
    id: '4',
    customerName: 'Emily Davis',
    rating: 4.0,
    comment: 'Good laptop overall. Performance is solid for the price. The only downside is the storage could be larger.',
    date: DateTime.now().subtract(const Duration(days: 25)),
    verified: true,
  ),
  ReviewModel(
    id: '5',
    customerName: 'David Wilson',
    rating: 5.0,
    comment: 'Perfect condition! Runs all my software smoothly. The warranty included gives me peace of mind. Great customer service too!',
    date: DateTime.now().subtract(const Duration(days: 30)),
    verified: true,
  ),
];

/// ---------------- REVIEW CARD WIDGET ----------------
class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }

  Widget _buildStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating ? Icons.star_half : Icons.star_border),
          size: 16.sp,
          color: Colors.amber,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.customerName[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.customerName,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                        ),
                        if (review.verified) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.verified,
                              size: 14.sp,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 6.h),
                    _buildStars(review.rating),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _formatDate(review.date),
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            review.comment,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey[800],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- SPECIFICATION HELPER CLASSES ----------------
class _SpecItem {
  final String label;
  final String value;

  _SpecItem({required this.label, required this.value});
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.w,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- STATE ----------------
class ProductDetailState {
  final int selectedImageIndex;

  ProductDetailState({this.selectedImageIndex = 0});

  ProductDetailState copyWith({int? selectedImageIndex}) {
    return ProductDetailState(
      selectedImageIndex:
      selectedImageIndex ?? this.selectedImageIndex,
    );
  }
}

/// ---------------- NOTIFIER ----------------
class ProductDetailNotifier
    extends StateNotifier<ProductDetailState> {
  ProductDetailNotifier() : super(ProductDetailState());

  void selectImage(int index) {
    state = state.copyWith(selectedImageIndex: index);
  }

  void nextImage(int total) {
    if (state.selectedImageIndex < total - 1) {
      state = state.copyWith(
          selectedImageIndex: state.selectedImageIndex + 1);
    }
  }

  void previousImage() {
    if (state.selectedImageIndex > 0) {
      state = state.copyWith(
          selectedImageIndex: state.selectedImageIndex - 1);
    }
  }
}

final productDetailProvider =
StateNotifierProvider<ProductDetailNotifier, ProductDetailState>(
        (ref) => ProductDetailNotifier());

/// ---------------- PAGE ----------------
class ProductDetailPage extends ConsumerWidget {
  final NewArrivalModel product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailProvider);
    final notifier = ref.read(productDetailProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          product.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.grey[800]),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageGallery(context, product, state, notifier),
            _productInfo(product),
            _tabs(context, product),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  /// ---------------- IMAGE GALLERY ----------------
  Widget _imageGallery(
      BuildContext context,
      NewArrivalModel product,
      ProductDetailState state,
      ProductDetailNotifier notifier,
      ) {
    final images = product.images;
    final index =
    state.selectedImageIndex.clamp(0, images.length - 1);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          Container(
            height: 350.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageViewer(
                            images: images,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Center(
                      child: Image.network(
                        images[index],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.image, size: 80, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ),
                if (images.length > 1)
                  Positioned(
                    left: 12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_left, size: 20),
                          color: AppColors.primary,
                          onPressed: notifier.previousImage,
                        ),
                      ),
                    ),
                  ),
                if (images.length > 1)
                  Positioned(
                    right: 12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_right, size: 20),
                          color: AppColors.primary,
                          onPressed: () =>
                              notifier.nextImage(images.length),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (images.length > 1) ...[
            SizedBox(height: 16.h),
            SizedBox(
              height: 70.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: images.length,
                itemBuilder: (context, i) {
                  final isSelected = i == index;
                  return GestureDetector(
                    onTap: () {
                      notifier.selectImage(i);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageViewer(
                            images: images,
                            initialIndex: i,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 70.w,
                      margin: EdgeInsets.only(right: 12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        color: Colors.white,
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(11.r),
                            child: Image.network(
                              images[i],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.image, size: 30, color: Colors.grey[400]),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.fullscreen,
                                size: 12.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ---------------- PRODUCT INFO ----------------
  Widget _productInfo(NewArrivalModel product) {
    final averageRating = _dummyReviews
        .map((r) => r.rating)
        .reduce((a, b) => a + b) /
        _dummyReviews.length;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 16.sp, color: Colors.green[700]),
                    SizedBox(width: 4.w),
                    Text(
                      "In Stock",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < averageRating.floor()
                        ? Icons.star
                        : (i < averageRating ? Icons.star_half : Icons.star_border),
                    size: 18.sp,
                    color: Colors.amber,
                  );
                }),
              ),
              SizedBox(width: 8.w),
              Text(
                averageRating.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                "(${_dummyReviews.length} Reviews)",
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${NumberFormat('#,###').format(product.price)}",
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              SizedBox(width: 8.w),
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  "Only",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    callSeller('7878934042');
                  },
                  icon: Icon(Icons.message, size: 20),
                  label: Text(
                    "Contact Seller",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  onPressed: () {
                    shareProductOnWhatsApp(product);
                  },
                  icon: SvgPicture.asset(
                    'icon/whatsup_icon.svg',
                    width: 24.w,
                    height: 24.w,
                  ),
                  padding: EdgeInsets.all(16.w),
                ),
              )
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.local_shipping, size: 24.sp, color: Colors.blue[700]),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Free Shipping & 1 Year Warranty Included",
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Ships within 1-2 business days",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> shareProductOnWhatsApp(NewArrivalModel product) async {
    final productUrl = 'https://yourdomain.com/product/${product.id}';
    final message = '''
🔥 ${product.name}
💰 Price: ₹${NumberFormat('#,###').format(product.price)}$productUrl''';
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not open WhatsApp';
    }
  }
  Future<void> callSeller(String phoneNumber) async {
    final Uri callUri = Uri.parse('tel:$phoneNumber');

    if (await canLaunchUrl(callUri)) {
      await launchUrl(
        callUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch dialer';
    }
  }


  /// ---------------- TABS ----------------
  Widget _tabs(BuildContext context, NewArrivalModel product) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 12.h),
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: "Overview"),
                  Tab(text: "Specifications"),
                  Tab(text: "Reviews"),
                ],
              ),
            ),
            SizedBox(
              height: 450.h,
              child: TabBarView(
                children: [
                  _overview(product),
                  _specifications(product),
                  _reviews(product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- OVERVIEW ----------------
  Widget _overview(NewArrivalModel product) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.overview != null && product.overview!.isNotEmpty) ...[
            Text(
              "Product Description",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              product.overview!,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                height: 1.8,
                color: Colors.grey[700],
              ),
            ),
          ] else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Column(
                  children: [
                    Icon(Icons.description_outlined,
                        size: 48.sp, color: Colors.grey[400]),
                    SizedBox(height: 12.h),
                    Text(
                      "No overview available",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ---------------- SPECIFICATIONS ----------------
  Widget _specifications(NewArrivalModel product) {
    final specs = [
      _SpecItem(label: "Model", value: product.model),
      _SpecItem(label: "Processor", value: product.processor),
      _SpecItem(label: "RAM", value: product.ram),
      _SpecItem(label: "Storage", value: product.storage),
      _SpecItem(label: "Display", value: product.display),
      _SpecItem(label: "Graphics", value: product.graphics),
      _SpecItem(label: "Operating System", value: product.operatingSystem),
    ];

    // Filter out empty specifications
    final validSpecs = specs.where((spec) => spec.value.isNotEmpty).toList();

    if (validSpecs.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(12.w),
        child: Center(
          child: Text(
            "No specifications available",
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: List.generate(
                validSpecs.length,
                    (index) {
                  final spec = validSpecs[index];
                  final isLast = index == validSpecs.length - 1;

                  return Container(
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                        bottom: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: _SpecRow(
                      label: spec.label,
                      value: spec.value,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- REVIEWS ----------------
  Widget _reviews(NewArrivalModel product) {
    final averageRating = _dummyReviews
        .map((r) => r.rating)
        .reduce((a, b) => a + b) /
        _dummyReviews.length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customer Reviews",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < averageRating.floor()
                                    ? Icons.star
                                    : (i < averageRating
                                    ? Icons.star_half
                                    : Icons.star_border),
                                size: 16.sp,
                                color: Colors.amber,
                              );
                            }),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "${_dummyReviews.length} reviews",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ..._dummyReviews.map((review) => _ReviewCard(review: review)),
        ],
      ),
    );
  }
}
