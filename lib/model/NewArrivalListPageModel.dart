class NewArrivalListPageModel {
  final String id;
  final String name;
  final String processor;
  final String ram;
  final String storage;
  final int price;
  final List<String> images;

  NewArrivalListPageModel({
    required this.id,
    required this.name,
    required this.processor,
    required this.ram,
    required this.storage,
    required this.price,
    required this.images,
  });

  factory NewArrivalListPageModel.fromJson(Map<String, dynamic> json, String id) {
    return NewArrivalListPageModel(
      id: id,
      name: json['name'] ?? '',
      processor: json['processor'] ?? '',
      ram: json['ram'] ?? '',
      storage: json['storage'] ?? '',
      price: json['price'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
    );
  }
}
