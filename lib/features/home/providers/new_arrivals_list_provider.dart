import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../model/NewArrivalModel.dart';

// Available filter options
final availableBrands = ['Dell', 'HP', 'Lenovo', 'Apple', 'Acer', 'Microsoft'];
final availableRAM = ['8GB', '16GB', '32GB'];
final availableSSD = ['256GB', '512GB', '1TB'];
final sortOptions = ['Newest First', 'Price: Low to High', 'Price: High to Low', 'Name: A-Z', 'Name: Z-A'];



final newArrivalsFirebaseProvider =
FutureProvider<List<NewArrivalModel>>((ref) async {
  final refDb = FirebaseDatabase.instance.ref('new_arrivals');

  final snapshot = await refDb.get();
  if (!snapshot.exists) return [];

  final data = snapshot.value as Map<dynamic, dynamic>;

  return data.entries.map((e) {
    return NewArrivalModel.fromMap(
      e.key.toString(),
      Map<dynamic, dynamic>.from(e.value),
    );
  }).toList();
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
}
class NewArrivalsListNotifier extends StateNotifier<FilterState> {
  final Ref ref;

  NewArrivalsListNotifier(this.ref) : super(FilterState());

  List<NewArrivalModel> get allProducts {
    return ref.watch(newArrivalsFirebaseProvider).maybeWhen(
      data: (list) => list,
      orElse: () => [],
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
    var products = List<NewArrivalModel>.from(allProducts);

    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      products = products.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.model.toLowerCase().contains(q) ||
            p.overview.toLowerCase().contains(q);
      }).toList();
    }

    if (state.selectedBrands.isNotEmpty) {
      products =
          products.where((p) => state.selectedBrands.contains(p.model)).toList();
    }

    products = products
        .where((p) => p.price >= state.minPrice && p.price <= state.maxPrice)
        .toList();

    if (state.selectedRAM.isNotEmpty) {
      products = products.where((p) {
        return state.selectedRAM.any((ram) => p.ram.contains(ram));
      }).toList();
    }

    if (state.selectedSSD.isNotEmpty) {
      products = products.where((p) {
        return state.selectedSSD.any((ssd) => p.storage.contains(ssd));
      }).toList();
    }

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
      default:
        break;
    }

    return products;
  }
}
final newArrivalsListProvider =
StateNotifierProvider<NewArrivalsListNotifier, FilterState>((ref) {
  return NewArrivalsListNotifier(ref);
});
