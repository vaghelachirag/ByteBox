import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context, size),
            _buildSectionHeader('New Arrivals', 'See All'),
            _buildProductGrid(ProductType.newArrival, size),
            _buildSectionHeader('Best Deals', 'See All'),
            _buildProductGrid(ProductType.bestDeal, size),
            _buildSectionHeader('All Available Laptops', 'See All'),
            _buildProductList(),
            _buildWhyBuySection(),
            _buildWhatsAppBanner(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, Size size) {
    return Container(
      height: 400.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E3A8A),
            const Color(0xFF1E3A8A).withOpacity(0.9),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.memory,
                size: 300,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '🔥 Hot Deals',
                          style: GoogleFonts.poppins(
                            color: Colors.amber,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Premium Refurbished Laptops',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Fully Tested • 1 Year Warranty • 7-Day Returns',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 2,
                            ),
                            icon: Icon(Iconsax.message, size: 20.w),
                            label: Text(
                              'Chat on WhatsApp',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white.withOpacity(0.3)),
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            icon: Icon(Iconsax.search_normal_1, size: 20.w),
                            label: Text(
                              'Explore More',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (size.width > 800) ...[
                  SizedBox(width: 40.w),
                  Expanded(
                    child: Hero(
                      tag: 'hero-laptop',
                      child: Image.asset(
                        'assets/images/hero_laptop.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: [
                Text(
                  actionText,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1E3A8A),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.w,
                  color: const Color(0xFF1E3A8A),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(ProductType type, Size size) {
    final products = type == ProductType.newArrival
        ? dummyNewArrivals
        : dummyBestDeals;

    return Container(
      height: 300.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product, size);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, Size size) {
    return Container(
      width: 260.w,
      margin: EdgeInsets.only(right: 16.w, bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              height: 160.h,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${product.brand} ${product.model}',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  product.specs,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '₹${product.price.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dummyAllProducts.length,
      itemBuilder: (context, index) {
        final product = dummyAllProducts[index];
        return _buildProductListItem(product);
      },
    );
  }

  Widget _buildProductListItem(Product product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              width: 120,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product.brand} ${product.model}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    product.specs,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
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

  Widget _buildWhyBuySection() {
    return Container(
      margin: EdgeInsets.only(top: 40.h, bottom: 20.h),
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(40.r),
          bottom: Radius.circular(40.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Why Choose ByteBox', 'Learn More'),
          SizedBox(height: 24.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 2.5,
            ),
            itemCount: benefits.length,
            itemBuilder: (context, index) {
              final benefit = benefits[index];
              return _buildBenefitItem(benefit);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(Benefit benefit) {
    return Row(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              benefit.icon,
              color: Colors.blue,
              size: 28.w,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            benefit.title,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWhatsAppBanner(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF25D366), Color(0xFF128C7E)],
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.message_text, color: Colors.white, size: 28),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Help? Chat with us!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Our team is available 24/7 to assist you with any questions about our products.',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum ProductType { newArrival, bestDeal, all }

class Product {
  final String id;
  final String brand;
  final String model;
  final String specs;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final bool isNewArrival;
  final bool isBestDeal;

  Product({
    required this.id,
    required this.brand,
    required this.model,
    required this.specs,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.isNewArrival = false,
    this.isBestDeal = false,
  });
}

class Benefit {
  final IconData icon;
  final String title;

  Benefit({required this.icon, required this.title});
}

final List<Product> dummyNewArrivals = [
  Product(
      id: '1',
      brand: 'HP',
      model: 'EliteBook 840 G5',
      specs: 'i5 - 8GB - 256GB SSD',
      price: 24999,
      imageUrl: 'https://i.ibb.co/Jj1D0jkj/dell-image.png',
      isNewArrival: true),
  Product(
      id: '2',
      brand: 'Dell',
      model: 'Latitude 5400',
      specs: 'i7 - 16GB - 512GB SSD',
      price: 34999,
      imageUrl: 'https://i.ibb.co/Jj1D0jkj/dell-image.png',
      isNewArrival: true),
];

final List<Product> dummyBestDeals = [
  Product(
      id: '5',
      brand: 'Dell',
      model: 'Latitude 5500',
      specs: 'i5 - 8GB - 256GB SSD',
      price: 27399,
      originalPrice: 34999,
      imageUrl: 'https://i.ibb.co/Jj1D0jkj/dell-image.png',
      isBestDeal: true),
];

final List<Product> dummyAllProducts = [
  ...dummyNewArrivals,
  ...dummyBestDeals,
];

final List<Benefit> benefits = [
  Benefit(icon: Iconsax.shield_tick, title: '100% Genuine'),
  Benefit(icon: Iconsax.refresh, title: '7-Day Returns'),
  Benefit(icon: Iconsax.security_user, title: '1-Year Warranty'),
  Benefit(icon: Iconsax.truck_fast, title: 'Free Shipping'),
];
