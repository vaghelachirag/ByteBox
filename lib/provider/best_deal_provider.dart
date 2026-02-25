import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/best_deal_model.dart';

final bestDealsProvider =
StreamProvider.autoDispose<List<BestDealModel>>((ref) {
  final query = FirebaseFirestore.instance
      .collection('best_deals')
      .where('isActive', isEqualTo: true)
      .orderBy('discountPercent', descending: true);

  return query.snapshots().map((snapshot) {
    final List<BestDealModel> items = [];

    for (final doc in snapshot.docs) {
      try {
        items.add(
          BestDealModel.fromJson(
            doc.id,
            doc.data(),
          ),
        );
      } catch (e) {
        print("Error parsing best deal ${doc.id}: $e");
      }
    }

    return items;
  });
});
