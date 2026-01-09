class NewArrivalModel {
  final String id;
  final String imageUrl;
  final String name;
  final double price;

  NewArrivalModel({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
  });

  factory NewArrivalModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return NewArrivalModel(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
    );
  }
}
