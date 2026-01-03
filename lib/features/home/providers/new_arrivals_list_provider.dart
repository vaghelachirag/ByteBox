import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_provider.dart';

// Filter State Model
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
    this.minPrice = 200,
    this.maxPrice = 1000,
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

  bool get hasActiveFilters {
    return selectedBrands.isNotEmpty ||
        selectedRAM.isNotEmpty ||
        selectedSSD.isNotEmpty ||
        minPrice != 200 ||
        maxPrice != 1000;
  }
}

// Available filter options
final availableBrands = ['Dell', 'HP', 'Lenovo', 'Apple', 'Acer', 'Microsoft'];
final availableRAM = ['8GB', '16GB', '32GB'];
final availableSSD = ['256GB', '512GB', '1TB'];
final sortOptions = ['Newest First', 'Price: Low to High', 'Price: High to Low', 'Name: A-Z', 'Name: Z-A'];

// List Page Provider
class NewArrivalsListNotifier extends StateNotifier<FilterState> {
  final List<ProductModel> allProducts;

  NewArrivalsListNotifier(this.allProducts) : super(FilterState());

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleBrand(String brand) {
    final newBrands = Set<String>.from(state.selectedBrands);
    if (newBrands.contains(brand)) {
      newBrands.remove(brand);
    } else {
      newBrands.add(brand);
    }
    state = state.copyWith(selectedBrands: newBrands);
  }

  void updatePriceRange(double min, double max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
  }

  void toggleRAM(String ram) {
    final newRAM = Set<String>.from(state.selectedRAM);
    if (newRAM.contains(ram)) {
      newRAM.remove(ram);
    } else {
      newRAM.add(ram);
    }
    state = state.copyWith(selectedRAM: newRAM);
  }

  void toggleSSD(String ssd) {
    final newSSD = Set<String>.from(state.selectedSSD);
    if (newSSD.contains(ssd)) {
      newSSD.remove(ssd);
    } else {
      newSSD.add(ssd);
    }
    state = state.copyWith(selectedSSD: newSSD);
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void clearAllFilters() {
    state = FilterState();
  }

  List<ProductModel> get filteredProducts {
    var products = List<ProductModel>.from(allProducts);

    // Filter by search query
    if (state.searchQuery.isNotEmpty) {
      products = products.where((p) {
        return p.name.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
            p.description.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
            p.brand.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
            (p.specifications != null &&
                p.specifications!.toLowerCase().contains(state.searchQuery.toLowerCase()));
      }).toList();
    }

    // Filter by brands
    if (state.selectedBrands.isNotEmpty) {
      products = products.where((p) => state.selectedBrands.contains(p.brand)).toList();
    }

    // Filter by price range
    products = products
        .where((p) => p.price >= state.minPrice && p.price <= state.maxPrice)
        .toList();

    // Filter by RAM
    if (state.selectedRAM.isNotEmpty) {
      products = products.where((p) {
        if (p.specifications == null) return false;
        return state.selectedRAM.any((ram) => p.specifications!.contains(ram));
      }).toList();
    }

    // Filter by SSD
    if (state.selectedSSD.isNotEmpty) {
      products = products.where((p) {
        if (p.specifications == null) return false;
        return state.selectedSSD.any((ssd) => p.specifications!.contains(ssd));
      }).toList();
    }

    // Sort products
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
        // Keep original order (newest first by default)
        break;
    }

    return products;
  }
}

// Provider
final newArrivalsListProvider =
    StateNotifierProvider<NewArrivalsListNotifier, FilterState>((ref) {
  final homeNotifier = ref.read(homeProvider.notifier);
  final newArrivals = homeNotifier.newArrivals;
  return NewArrivalsListNotifier(newArrivals);
});

