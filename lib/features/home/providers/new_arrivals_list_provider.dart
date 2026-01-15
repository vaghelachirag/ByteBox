import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../model/NewArrivalModel.dart';

// Available filter options
final availableBrands = ['Dell', 'HP', 'Lenovo', 'Apple', 'Acer', 'Microsoft'];
final availableRAM = ['8GB', '16GB', '32GB'];
final availableSSD = ['256GB', '512GB', '1TB'];
final sortOptions = ['Newest First', 'Price: Low to High', 'Price: High to Low', 'Name: A-Z', 'Name: Z-A'];



/// Firebase provider to get all new arrivals products
/// Uses StreamProvider for real-time updates
final newArrivalsFirebaseProvider =
StreamProvider<List<NewArrivalModel>>((ref) {
  ref.keepAlive();
  final refDb = FirebaseDatabase.instance.ref('new_arrivals');

  return refDb.onValue.map((event) {
    final snapshot = event.snapshot;

    // If snapshot doesn't exist, return empty list
    if (!snapshot.exists || snapshot.value == null) {
      return <NewArrivalModel>[];
    }

    final data = snapshot.value;

    // Handle different data types
    if (data is! Map) {
      return <NewArrivalModel>[];
    }

    final Map<dynamic, dynamic> dataMap = data as Map<dynamic, dynamic>;

    // Parse all products from Firebase
    final List<NewArrivalModel> products = [];

    dataMap.forEach((key, value) {
      try {
        if (value is Map) {
          final product = NewArrivalModel.fromMap(
            key.toString(),
            Map<dynamic, dynamic>.from(value),
          );
          // Only include active products
          if (product.isActive) {
            products.add(product);
          }
        }
      } catch (e) {
        print('Error parsing product $key: $e');
      }
    });

    return products;
  });
});

class FilterState {
  final String searchQuery;
  final Set<String> selectedBrands;
  final double minPrice;
  final double maxPrice;
  final Set<String> selectedRAM;
  final Set<String> selectedSSD;
  final String sortBy;

  FilterState({
    this.searchQuery = '',
    Set<String>? selectedBrands,
    this.minPrice = 0,
    this.maxPrice = 200000,
    Set<String>? selectedRAM,
    Set<String>? selectedSSD,
    this.sortBy = 'Newest First',
  })  : selectedBrands = selectedBrands ?? {},
        selectedRAM = selectedRAM ?? {},
        selectedSSD = selectedSSD ?? {};

  FilterState copyWith({
    String? searchQuery,
    Set<String>? selectedBrands,
    double? minPrice,
    double? maxPrice,
    Set<String>? selectedRAM,
    Set<String>? selectedSSD,
    String? sortBy,
  }) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBrands: selectedBrands ?? this.selectedBrands,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      selectedRAM: selectedRAM ?? this.selectedRAM,
      selectedSSD: selectedSSD ?? this.selectedSSD,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
class NewArrivalsListNotifier extends StateNotifier<FilterState> {
  final Ref ref;

  NewArrivalsListNotifier(this.ref) : super(FilterState());

  List<NewArrivalModel> get allProducts {
    final asyncValue = ref.watch(newArrivalsFirebaseProvider);

    return asyncValue.when(
      data: (list) => list,
      loading: () => [],
      error: (error, stack) {
        print('Error fetching new arrivals: $error');
        return [];
      },
    );
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleBrand(String brand) {
    final brands = Set<String>.from(state.selectedBrands);
    brands.contains(brand) ? brands.remove(brand) : brands.add(brand);
    state = state.copyWith(selectedBrands: brands);
  }

  void updatePriceRange(double min, double max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
  }

  void toggleRAM(String ram) {
    final rams = Set<String>.from(state.selectedRAM);
    rams.contains(ram) ? rams.remove(ram) : rams.add(ram);
    state = state.copyWith(selectedRAM: rams);
  }

  void toggleSSD(String ssd) {
    final ssds = Set<String>.from(state.selectedSSD);
    ssds.contains(ssd) ? ssds.remove(ssd) : ssds.add(ssd);
    state = state.copyWith(selectedSSD: ssds);
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void clearAllFilters() {
    state = FilterState();
  }


  List<NewArrivalModel> get filteredProducts {
    // Start with all products
    var products = List<NewArrivalModel>.from(allProducts);

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase().trim();
      products = products.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.model.toLowerCase().contains(q) ||
            p.overview.toLowerCase().contains(q) ||
            p.processor.toLowerCase().contains(q);
      }).toList();
    }

    if (state.selectedBrands.isNotEmpty) {
      products = products.where((p) {
        final productBrand = p.model.toLowerCase();
        final productName = p.name.toLowerCase();
        return state.selectedBrands.any((brand) {
          final brandLower = brand.toLowerCase();
          return productBrand.contains(brandLower) ||
              productName.contains(brandLower);
        });
      }).toList();
    }

    products = products
        .where((p) => p.price >= state.minPrice && p.price <= state.maxPrice)
        .toList();

    // Apply RAM filter
    if (state.selectedRAM.isNotEmpty) {
      products = products.where((p) {
        return state.selectedRAM.any((ram) =>
            p.ram.toLowerCase().contains(ram.toLowerCase())
        );
      }).toList();
    }

    // Apply storage filter
    if (state.selectedSSD.isNotEmpty) {
      products = products.where((p) {
        return state.selectedSSD.any((ssd) =>
            p.storage.toLowerCase().contains(ssd.toLowerCase())
        );
      }).toList();
    }

    // Apply sorting
    switch (state.sortBy) {
      case 'Price: Low to High':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Name: A-Z':
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Name: Z-A':
        products.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Newest First':
      default:
      // Keep original order (newest first based on Firebase order)
        break;
    }

    return products;
  }
}
final newArrivalsListProvider =
StateNotifierProvider<NewArrivalsListNotifier, FilterState>((ref) {
  ref.keepAlive();
  return NewArrivalsListNotifier(ref);
});

