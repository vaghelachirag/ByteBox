class NewArrivalModel {
  final String id;
  final String name;
  final String brand;
  final String specifications;
  final String description;
  final int actualPrice;
  final int offerPrice;
  final int discountPercent;
  final bool isActive;
  final int order;
  final List<String> images;

  NewArrivalModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.specifications,
    required this.description,
    required this.actualPrice,
    required this.offerPrice,
    required this.discountPercent,
    required this.isActive,
    required this.order,
    required this.images,
  });

  factory NewArrivalModel.fromJson(
      String id,
      Map<String, dynamic> json,
      ) {
    final imagesMap = json['images'] as Map<dynamic, dynamic>?;

    return NewArrivalModel(
      id: id,
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      specifications: json['specifications'] ?? '',
      description: json['description'] ?? '',
      actualPrice: json['actual_price'] ?? 0,
      offerPrice: json['offer_price'] ?? 0,
      discountPercent: json['discount_percent'] ?? 0,
      isActive: json['isActive'] ?? false,
      order: json['order'] ?? 0,
      images: imagesMap == null
          ? []
          : imagesMap.values.map((e) => e.toString()).toList(),
    );
  }
}
