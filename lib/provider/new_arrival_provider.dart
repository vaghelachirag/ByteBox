import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/NewArrivals.dart';

final newArrivalsProvider =
StreamProvider.autoDispose<List<NewArrivalModel>>((ref) {
  final dbRef = FirebaseDatabase.instance.ref().child('new_arrivals');

  return dbRef.onValue.map((event) {
    final data = event.snapshot.value;
    if (data == null) return <NewArrivalModel>[];

    final List<NewArrivalModel> items = [];

    if (data is Map<dynamic, dynamic>) {
      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          items.add(
            NewArrivalModel.fromJson(
              key.toString(),
              Map<String, dynamic>.from(value),
            ),
          );
        }
      });
    }

    items
      ..removeWhere((e) => !e.isActive)
      ..sort((a, b) => a.order.compareTo(b.order));

    return items;
  });
});
