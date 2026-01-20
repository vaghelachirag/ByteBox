import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/banner_provider.dart';
import '../features/home/presentation/product_detail_page.dart';

class BannerSlider extends ConsumerWidget {
  const BannerSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(bannerProvider);

    return bannersAsync.when(
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text(e.toString()),
      data: (banners) {
        if (banners.isEmpty) return const SizedBox();

        final imageUrls = banners.map((b) => b.imageUrl).toList();

        return CarouselSlider(
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            viewportFraction: 1,
            enableInfiniteScroll: true,
          ),
          items: banners.asMap().entries.map((entry) {
            final index = entry.key;
            final banner = entry.value;

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FullScreenImageViewer(
                      images: imageUrls,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Image.network(
                banner.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Image not available',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
