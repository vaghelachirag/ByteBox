import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/product.dart';

final homeProvider = Provider<HomeNotifier>((ref) {
  return HomeNotifier();
});

class HomeNotifier {
  List<Product> getNewArrivals() {
    // In a real app, this would fetch from an API
    return [
      Product(
        id: '1',
        brand: 'HP',
        model: 'EliteBook 840 G5',
        specs: 'i5 - 8GB - 256GB SSD',
        price: 24999,
        imageUrl: 'https://ibb.co/PGLq3GCG',
        isNewArrival: true,
      ),
      Product(
        id: '2',
        brand: 'Dell',
        model: 'Latitude 5400',
        specs: 'i7 - 16GB - 512GB SSD',
        price: 34999,
        originalPrice: 39999,
        imageUrl: 'https://ibb.co/PGLq3GCG',
        isNewArrival: true,
      ),
      Product(
        id: '3',
        brand: 'Lenovo',
        model: 'ThinkPad T490',
        specs: 'i5 - 16GB - 512GB SSD',
        price: 31999,
        imageUrl: 'https://via.placeholder.com/200',
        isNewArrival: true,
      ),
    ];
  }

  List<Product> getBestDeals() {
    // In a real app, this would fetch from an API
    return [
      Product(
        id: '4',
        brand: 'Dell',
        model: 'Latitude 5500',
        specs: 'i5 - 8GB - 256GB SSD',
        price: 27399,
        originalPrice: 34999,
        imageUrl: 'https://via.placeholder.com/200',
        isBestDeal: true,
      ),
      Product(
        id: '5',
        brand: 'HP',
        model: 'ProBook 450 G6',
        specs: 'i7 - 16GB - 512GB SSD',
        price: 42999,
        originalPrice: 49999,
        imageUrl: 'https://via.placeholder.com/200',
        isBestDeal: true,
      ),
    ];
  }

  List<Product> getAllProducts() {
    // In a real app, this would fetch from an API
    return [
      ...getNewArrivals(),
      ...getBestDeals(),
      Product(
        id: '6',
        brand: 'Asus',
        model: 'VivoBook 15',
        specs: 'Ryzen 5 - 8GB - 512GB SSD',
        price: 37999,
        imageUrl: 'https://ibb.co/PGLq3GCG',
      ),
    ];
  }
}
