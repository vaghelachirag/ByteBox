class BestDealModel {
  final String id;
  final String company;
  final String name;
  final String overview;
  final double price;
  final double discount;
  final double discountPercent;
  final double originalPrice;
  final double discountPrice;
  final List<String> images;
  final bool isActive;
  final int order;

  BestDealModel({
    required this.id,
    required this.company,
    required this.name,
    required this.overview,
    required this.price,
    required this.discount,
    required this.discountPercent,
    required this.originalPrice,
    required this.discountPrice,
    required this.images,
    required this.isActive,
    required this.order,
  });



  factory BestDealModel.fromJson(
      String id, Map<String, dynamic> json) {
    return BestDealModel(
      id: id,
      company: json['company'] ?? '',
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      discountPercent: (json['discountPercent'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountPrice: (json['discountPrice'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      isActive: json['isActive'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  factory BestDealModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return BestDealModel(
      id: id,
      company: map['company'] ?? '',
      name: map['name'] ?? '',
      overview: map['overview'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      discountPercent: (map['discountPercent'] ?? 0).toDouble(),
      originalPrice: (map['originalPrice'] ?? 0).toDouble(),
      discountPrice: (map['discountPrice'] ?? 0).toDouble(),
      images: _parseImages(map['images']),
      isActive: map['isActive'] ?? true,
      order: map['order'] ?? 0,
    );
  }

  /// Firebase mixed array parser
  static List<String> _parseImages(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data.map((item) {
        if (item is String) return item;
        if (item is Map && item.containsKey('Value')) {
          return item['Value'].toString();
        }
        return '';
      }).where((e) => e.isNotEmpty).toList();
    }

    return [];
  }
}
