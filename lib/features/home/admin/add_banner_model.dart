import 'package:cloud_firestore/cloud_firestore.dart';

class AddBannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final bool isActive;
  final int order;

  AddBannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.isActive,
    required this.order,
  });

  factory AddBannerModel.fromJson(Map<String, dynamic> json, String id) {
    return AddBannerModel(
      id: id,
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isActive: json['isActive'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
