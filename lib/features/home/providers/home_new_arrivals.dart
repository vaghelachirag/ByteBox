import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../model/NewArrivalModel.dart';

final newArrivalProvider =
StreamProvider<List<NewArrivalModel>>((ref) {
  final refDb = FirebaseDatabase.instance.ref('new_arrivals');

  return refDb.onValue.map((event) {
    final data = event.snapshot.value;

    if (data == null) return [];

    final Map<dynamic, dynamic> map =
    data as Map<dynamic, dynamic>;

    return map.entries.map((e) {
      return NewArrivalModel.fromMap(
        e.key,
        Map<dynamic, dynamic>.from(e.value),
      );
    }).toList();
  });
});
