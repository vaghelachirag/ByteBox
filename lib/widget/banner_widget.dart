import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/banner_provider.dart';
import '../features/home/presentation/product_detail_page.dart';

class BannerSlider extends ConsumerStatefulWidget {
  const BannerSlider({super.key});

  @override
  ConsumerState<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends ConsumerState<BannerSlider> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(bannerProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.hasBoundedHeight && constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 180.0;

        return bannersAsync.when(
          loading: () => SizedBox(
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SizedBox(
            height: height,
            child: Center(child: Text(e.toString())),
          ),
          data: (banners) {
            if (banners.isEmpty) return const SizedBox();

            final imageUrls = banners.map((b) => b.imageUrl).toList();
            _activeIndex = _activeIndex.clamp(0, banners.length - 1);

            return Stack(
              children: [
                CarouselSlider.builder(
                  options: CarouselOptions(
                    height: height,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(milliseconds: 650),
                    autoPlayCurve: Curves.easeInOutCubic,
                    viewportFraction: 1,
                    enableInfiniteScroll: true,
                    onPageChanged: (index, _) {
                      if (!mounted) return;
                      setState(() => _activeIndex = index);
                    },
                  ),
                  itemCount: banners.length,
                  itemBuilder: (context, index, _) {
                    final banner = banners[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Material(
                        color: Colors.transparent,
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(18),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
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
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                banner.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 8),
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
                              // Subtle dark overlay for text/controls readability
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.10),
                                      Colors.black.withOpacity(0.05),
                                      Colors.black.withOpacity(0.35),
                                    ],
                                  ),
                                ),
                              ),
                              // "View" pill (works for mobile + web, encourages click)
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (banners.length > 1)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(banners.length, (i) {
                        final isActive = i == _activeIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 18 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: isActive
                                ? Colors.white.withOpacity(0.95)
                                : Colors.white.withOpacity(0.45),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
