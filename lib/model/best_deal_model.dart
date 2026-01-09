class BestDealModel {
  final String id;
  final String name;
  final String overview;
  final double price;
  final double discount;
  final List<String> images;
  final bool isActive;
  final int order;

  BestDealModel({
    required this.id,
    required this.name,
    required this.overview,
    required this.price,
    required this.discount,
    required this.images,
    required this.isActive,
    required this.order,
  });

  double get discountedPrice =>
      price - (price * discount / 100);

  factory BestDealModel.fromJson(
      String id, Map<String, dynamic> json) {
    return BestDealModel(
      id: id,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      isActive: json['isActive'] ?? true,
      order: json['order'] ?? 0,
    );
  }
}
