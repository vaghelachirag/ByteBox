import 'package:bytebox/features/home/admin/add_banner_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


/// FIRESTORE
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// BANNER REPOSITORY
final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  return BannerRepository(ref.read(firestoreProvider));
});

/// BANNER LIST STREAM
final bannerListProvider =
StreamProvider.autoDispose<List<AddBannerModel>>((ref) {
  return ref.read(bannerRepositoryProvider).getBanners();
});

/// ------------------------------------------------------------
/// REPOSITORY CLASS
/// ------------------------------------------------------------
class BannerRepository {
  final FirebaseFirestore _db;
  BannerRepository(this._db);

  Future<void> addBanner(AddBannerModel banner) async {
    await _db.collection('banners').add(banner.toJson());
  }

  Stream<List<AddBannerModel>> getBanners() {
    return _db
        .collection('banners')
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AddBannerModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }
}
