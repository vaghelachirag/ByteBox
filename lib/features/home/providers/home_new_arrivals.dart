import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/NewArrivalModel.dart';

final newArrivalProvider =
StreamProvider<List<NewArrivalModel>>((ref) {
  final query = FirebaseFirestore.instance
      .collection('new_arrivals')
      .where('isActive', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .limit(10);

  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return NewArrivalModel.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();
  });
});

