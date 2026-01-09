import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/BannerModel.dart';

final bannerProvider = StreamProvider<List<BannerModel>>((ref) {
  final refDb = FirebaseDatabase.instance.ref().child('banners');

  return refDb.onValue.map((event) {
    final data = event.snapshot.value;
    if (data == null) return [];

    final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;

    final banners = map.values
        .map((e) => BannerModel.fromJson(
      Map<String, dynamic>.from(e),
    ))
        .where((e) => e.isActive)
        .toList();

    banners.sort((a, b) => a.order.compareTo(b.order));

    return banners;
  });
});
