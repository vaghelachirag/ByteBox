import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/NewArrivalModel.dart';

final allInOneFirebaseProvider =
    StreamProvider<List<NewArrivalModel>>((ref) {
  ref.keepAlive();

  final query = FirebaseFirestore.instance
      .collection('all_in_one')
      .where('isActive', isEqualTo: true)
      .orderBy('price', descending: true);

  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return NewArrivalModel.fromMap(
          doc.id,
          doc.data(),
        );
      } catch (e) {
        print('Error parsing all_in_one product ${doc.id}: $e');
        return null;
      }
    }).whereType<NewArrivalModel>().toList();
  });
}
);

