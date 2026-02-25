import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/BannerModel.dart';

final bannerProvider =
StreamProvider<List<BannerModel>>((ref) {
  ref.keepAlive();

  final query = FirebaseFirestore.instance
      .collection('banners')
      .where('isActive', isEqualTo: true)
      .orderBy('order', descending: false);

  return query.snapshots().map((snapshot) {
    if (snapshot.docs.isEmpty) {
      return <BannerModel>[];
    }

    final List<BannerModel> banners = [];

    for (final doc in snapshot.docs) {
      try {
        final banner = BannerModel.fromJson(doc.data());
        banners.add(banner);
      } catch (e) {
        print("Error parsing banner ${doc.id}: $e");
      }
    }

    return banners;
  });
});
