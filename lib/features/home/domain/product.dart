class Product {
  final String id;
  final String brand;
  final String model;
  final String specs;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final bool isNewArrival;
  final bool isBestDeal;

  Product({
    required this.id,
    required this.brand,
    required this.model,
    required this.specs,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.isNewArrival = false,
    this.isBestDeal = false,
  });
}
