import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';import '../model/NewArrivals.dart';


final newArrivalProvider =
StreamProvider<List<NewArrivalModel>>((ref) {
  final refDb = FirebaseDatabase.instance.ref('new_arrivals');

  return refDb.onValue.map((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data == null) return [];

    final list = data.entries
        .map((e) =>
        NewArrivalModel.fromJson(e.key, e.value))
        .where((p) => p.isActive)
        .toList();

    return list;
  });
});
