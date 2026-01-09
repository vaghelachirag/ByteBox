class BannerModel {
  final String imageUrl;
  final bool isActive;
  final int order;

  BannerModel({
    required this.imageUrl,
    required this.isActive,
    required this.order,
  });

  /// Realtime Database → Model
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      imageUrl: json['imageUrl']?.toString() ?? '',
      isActive: json['isActive'] ?? false,
      order: json['order'] is int
          ? json['order']
          : int.tryParse(json['order']?.toString() ?? '0') ?? 0,
    );
  }

  /// Model → Realtime Database
  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'isActive': isActive,
      'order': order,
    };
  }
}
