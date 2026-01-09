import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/banner_provider.dart';

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

        return CarouselSlider(
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            viewportFraction: 1,
            enableInfiniteScroll: true,
          ),
          items: banners.map((banner) {
            return Image.network(
              banner.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            );
          }).toList(),
        );
      },
    );
  }
}
