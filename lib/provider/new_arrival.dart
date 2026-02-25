import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/NewArrivals.dart';

final newArrivalProvider =
StreamProvider<List<NewArrivalModel>>((ref) {

  final query = FirebaseFirestore.instance
      .collection('new_arrivals')
      .where('isActive', isEqualTo: true)
      .orderBy('createdAt', descending: true);

  return query.snapshots().map((snapshot) {

    if (snapshot.docs.isEmpty) {
      return <NewArrivalModel>[];
    }

    final List<NewArrivalModel> list = [];

    for (final doc in snapshot.docs) {
      try {
        list.add(
          NewArrivalModel.fromJson(
            doc.id,
            doc.data(),
          ),
        );
      } catch (e) {
        print("Error parsing new arrival ${doc.id}: $e");
      }
    }

    return list;
  });
});
