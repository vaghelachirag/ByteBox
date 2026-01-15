class NewArrivalModel {
  final String id;
  final String company;
  final String name;
  final String model;
  final String overview;
  final String display;
  final String processor;
  final String operatingSystem;
  final String ram;
  final String storage;
  final String graphics;
  final double price;
  final bool isActive;
  final List<String> images;

  NewArrivalModel({
    required this.id,
    required this.company,
    required this.name,
    required this.model,
    required this.overview,
    required this.display,
    required this.processor,
    required this.operatingSystem,
    required this.ram,
    required this.storage,
    required this.graphics,
    required this.price,
    required this.isActive,
    required this.images,
  });

  factory NewArrivalModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return NewArrivalModel(
      id: id,
      company: map['company'] ?? '',
      name: map['name'] ?? '',
      model: map['model'] ?? '',
      overview: map['overview'] ?? '',
      display: map['display'] ?? '',
      processor: map['processor'] ?? '',
      operatingSystem: map['operatingSystem'] ?? '',
      ram: map['ram'] ?? '',
      storage: map['storage'] ?? '',
      graphics: map['graphics'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      isActive: map['isActive'] ?? false,

      /// 🔥 Handles: String, Map{Value: url}, List
      images: _parseImages(map['images']),
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
