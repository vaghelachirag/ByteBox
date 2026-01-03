import 'package:flutter_riverpod/flutter_riverpod.dart';

// Home Page State Model
class HomeState {
  final String searchQuery;
  final int selectedCategoryIndex;
  final bool isLoading;
  final List<String> categories;
  final List<String> navigationItems;
  final List<ProductModel> featuredProducts;
  final List<ProductModel> newArrivals;
  final List<ProductModel> bestDeals;
  final List<ProductModel> allProducts;

  HomeState({
    this.searchQuery = '',
    this.selectedCategoryIndex = 0,
    this.isLoading = false,
    List<String>? categories,
    List<String>? navigationItems,
    List<ProductModel>? featuredProducts,
    List<ProductModel>? newArrivals,
    List<ProductModel>? bestDeals,
    List<ProductModel>? allProducts,
  })  : categories = categories ?? _defaultCategories,
        navigationItems = navigationItems ?? _defaultNavigationItems,
        featuredProducts = featuredProducts ?? _defaultFeaturedProducts,
        newArrivals = newArrivals ?? _defaultNewArrivals,
        bestDeals = bestDeals ?? _defaultBestDeals,
        allProducts = allProducts ?? _defaultAllProducts;

  HomeState copyWith({
    String? searchQuery,
    int? selectedCategoryIndex,
    bool? isLoading,
    List<String>? categories,
    List<String>? navigationItems,
    List<ProductModel>? featuredProducts,
    List<ProductModel>? newArrivals,
    List<ProductModel>? bestDeals,
    List<ProductModel>? allProducts,
  }) {
    return HomeState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      navigationItems: navigationItems ?? this.navigationItems,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      newArrivals: newArrivals ?? this.newArrivals,
      bestDeals: bestDeals ?? this.bestDeals,
      allProducts: allProducts ?? this.allProducts,
    );
  }
}

// Product Specifications Model
class ProductSpecifications {
  final String? processor;
  final String? ram;
  final String? storage;
  final String? display;
  final String? battery;
  final String? graphics;
  final String? operatingSystem;
  final String? connectivity;
  final String? model;

  ProductSpecifications({
    this.processor,
    this.ram,
    this.storage,
    this.display,
    this.battery,
    this.graphics,
    this.operatingSystem,
    this.connectivity,
    this.model,
  });
}

// Product Model
class ProductModel {
  final String id;
  final String name;
  final String description;
  final String? specifications; // For New Arrivals section
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final List<String>? imageUrls; // Multiple images for gallery
  final double rating;
  final int reviews;
  final String brand;
  final bool isFeatured;
  final bool isNewArrival;
  final bool isBestDeal;
  final String? discountBadge; // For Best Deals section (e.g., "30% OFF", "SAVE $200")
  final ProductSpecifications? detailedSpecs;
  final bool inStock;
  final String? shippingInfo;
  final String? phoneNumber;
  final String? whatsappNumber;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    this.specifications,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.imageUrls,
    this.rating = 0.0,
    this.reviews = 0,
    required this.brand,
    this.isFeatured = false,
    this.isNewArrival = false,
    this.isBestDeal = false,
    this.discountBadge,
    this.detailedSpecs,
    this.inStock = true,
    this.shippingInfo,
    this.phoneNumber,
    this.whatsappNumber,
  });

  List<String> get allImages {
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      return imageUrls!;
    }
    return [imageUrl];
  }
}

// Default Data
final _defaultCategories = [
  'All',
  'Laptops',
  'Desktops',
  'Monitors',
  'Accessories',
  'Gaming',
  'Business',
];

final _defaultNavigationItems = [
  'Home',
  'Laptops',
  'New Arrivals',
  'Best Deals',
  'Accessories',
  'Warranty',
  'Contact Us',
];

final _defaultFeaturedProducts = [
  ProductModel(
    id: '1',
    name: 'Dell XPS 15',
    description: 'Premium laptop with 15.6" display',
    price: 1299.99,
    originalPrice: 1599.99,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.8,
    reviews: 234,
    brand: 'Dell',
    isFeatured: true,
  ),
  ProductModel(
    id: '2',
    name: 'MacBook Pro 16"',
    description: 'Powerful laptop for professionals',
    price: 2399.99,
    originalPrice: 2799.99,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.9,
    reviews: 456,
    brand: 'Apple',
    isFeatured: true,
  ),
  ProductModel(
    id: '3',
    name: 'HP Spectre x360',
    description: '2-in-1 convertible laptop',
    price: 1199.99,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.7,
    reviews: 189,
    brand: 'HP',
    isFeatured: true,
  ),
];

final _defaultNewArrivals = [
  ProductModel(
    id: '7',
    name: 'Dell XPS 13',
    description: 'Premium ultrabook',
    specifications: '8GB RAM, 256GB SSD',
    price: 549.0,
    imageUrl: 'assets/images/dell/dell_image.png',
    imageUrls: [
      'assets/images/dell/dell_image.png',
      'assets/images/dell/dell_image.png',
      'assets/images/dell/dell_image.png',
      'assets/images/dell/dell_image.png',
    ],
    rating: 5.0,
    reviews: 78,
    brand: 'Dell',
    isNewArrival: true,
    inStock: true,
    shippingInfo: 'Ships within 1-2 business days',
    phoneNumber: '(123) 456-7890',
    whatsappNumber: '+1234567890',
    detailedSpecs: ProductSpecifications(
      model: 'Dell XPS 13',
      processor: 'Intel Core i5 8th Gen, 1.6GHz',
      ram: '8GB DDR3',
      storage: '256GB SSD',
      display: '13.3" Full HD (1920x1080)',
      battery: 'Up to 10 hours of battery life',
      graphics: 'Intel UHD Graphics 620',
      operatingSystem: 'Windows 10 Pro',
      connectivity: '2x USB-C, 1x USB 3.1, microSD card reader, headphone jack, Wi-Fi',
    ),
  ),
  ProductModel(
    id: '8',
    name: 'HP EliteBook',
    description: 'Business laptop',
    specifications: 'Core i5, 16GB RAM',
    price: 999.0,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.7,
    reviews: 189,
    brand: 'HP',
    isNewArrival: true,
  ),
  ProductModel(
    id: '9',
    name: 'Lenovo ThinkPad',
    description: 'Professional laptop',
    specifications: 'i7, 512GB SSD',
    price: 399.0,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.6,
    reviews: 312,
    brand: 'Lenovo',
    isNewArrival: true,
  ),
  ProductModel(
    id: '10',
    name: 'MacBook Pro',
    description: 'Apple premium laptop',
    specifications: 'Retina Display, 16GB RAM',
    price: 899.0,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.9,
    reviews: 456,
    brand: 'Apple',
    isNewArrival: true,
  ),
  ProductModel(
    id: '15',
    name: 'Acer Aspire 5',
    description: 'Budget-friendly laptop',
    specifications: '8GB RAM, 256GB SSD',
    price: 349.0,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.5,
    reviews: 278,
    brand: 'Acer',
    isNewArrival: true,
  ),
  ProductModel(
    id: '16',
    name: 'Surface Pro 7',
    description: 'Microsoft 2-in-1 tablet',
    specifications: '8GB RAM, 256GB SSD',
    price: 699.0,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.6,
    reviews: 312,
    brand: 'Microsoft',
    isNewArrival: true,
  ),
  ProductModel(
    id: '17',
    name: 'Lenovo Yoga 730',
    description: 'Convertible laptop',
    specifications: '16GB RAM, 512GB SSD',
    price: 429.0,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.4,
    reviews: 145,
    brand: 'Lenovo',
    isNewArrival: true,
  ),
  ProductModel(
    id: '18',
    name: 'HP Pavilion 15',
    description: 'Everyday laptop',
    specifications: '8GB RAM, 512GB SSD',
    price: 499.0,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.3,
    reviews: 198,
    brand: 'HP',
    isNewArrival: true,
  ),
  ProductModel(
    id: '19',
    name: 'Dell Latitude 7490',
    description: 'Business laptop',
    specifications: '16GB RAM, 512GB SSD',
    price: 599.0,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.7,
    reviews: 267,
    brand: 'Dell',
    isNewArrival: true,
  ),
  ProductModel(
    id: '20',
    name: 'Lenovo IdeaPad Flex 5',
    description: '2-in-1 convertible',
    specifications: '8GB RAM, 256GB SSD',
    price: 449.0,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.5,
    reviews: 189,
    brand: 'Lenovo',
    isNewArrival: true,
  ),
];

final _defaultBestDeals = [
  ProductModel(
    id: '11',
    name: 'Acer Aspire 5',
    description: 'Budget-friendly laptop',
    price: 349.0,
    originalPrice: 499.0,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.5,
    reviews: 278,
    brand: 'Acer',
    isBestDeal: true,
    discountBadge: '30% OFF',
  ),
  ProductModel(
    id: '12',
    name: 'Surface Pro 7',
    description: 'Microsoft 2-in-1 tablet',
    price: 699.0,
    originalPrice: 899.0,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.6,
    reviews: 312,
    brand: 'Microsoft',
    isBestDeal: true,
    discountBadge: 'SAVE \$200',
  ),
  ProductModel(
    id: '13',
    name: 'Lenovo Yoga 750',
    description: 'Convertible laptop',
    price: 429.0,
    originalPrice: 599.0,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.4,
    reviews: 145,
    brand: 'Lenovo',
    isBestDeal: true,
    discountBadge: 'FLASH SALE',
  ),
  ProductModel(
    id: '14',
    name: 'HP Pavilion 15',
    description: 'Everyday laptop',
    price: 499.0,
    originalPrice: 649.0,
    imageUrl: 'assets/images/dell/dell_image.png',
    rating: 4.3,
    reviews: 198,
    brand: 'HP',
    isBestDeal: true,
    discountBadge: 'FLASH SALE',
  ),
];

final _defaultAllProducts = [
  ..._defaultFeaturedProducts,
  ..._defaultNewArrivals,
  ..._defaultBestDeals,
];

// Home Provider
class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState());

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectCategory(int index) {
    state = state.copyWith(selectedCategoryIndex: index);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  List<ProductModel> get filteredProducts {
    final category = state.categories[state.selectedCategoryIndex];
    var products = state.allProducts;

    // Filter by category
    if (category != 'All') {
      products = products.where((p) => p.brand == category || p.name.contains(category)).toList();
    }

    // Filter by search query
    if (state.searchQuery.isNotEmpty) {
      products = products.where((p) {
        return p.name.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
            p.description.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
            p.brand.toLowerCase().contains(state.searchQuery.toLowerCase());
      }).toList();
    }

    return products;
  }

  List<ProductModel> get newArrivals => state.newArrivals;
  List<ProductModel> get bestDeals => state.bestDeals;
}

// Provider
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});

