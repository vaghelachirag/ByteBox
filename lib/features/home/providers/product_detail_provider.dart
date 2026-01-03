import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_provider.dart';

// Product Detail State
class ProductDetailState {
  final ProductModel? product;
  final int selectedImageIndex;
  final String selectedTab; // 'Overview', 'Specifications', 'Warranty', 'Reviews'

  ProductDetailState({
    this.product,
    this.selectedImageIndex = 0,
    this.selectedTab = 'Overview',
  });

  ProductDetailState copyWith({
    ProductModel? product,
    int? selectedImageIndex,
    String? selectedTab,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      selectedImageIndex: selectedImageIndex ?? this.selectedImageIndex,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

// Product Detail Notifier
class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  ProductDetailNotifier() : super(ProductDetailState());

  void setProduct(ProductModel product) {
    final images = product.allImages;
    final safeIndex = images.isNotEmpty ? 0 : 0;
    state = ProductDetailState(
      product: product,
      selectedImageIndex: safeIndex,
      selectedTab: 'Overview',
    );
  }

  void selectImage(int index) {
    if (state.product != null) {
      final images = state.product!.allImages;
      if (images.isNotEmpty && index >= 0 && index < images.length) {
        state = state.copyWith(selectedImageIndex: index);
      }
    }
  }

  void selectTab(String tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void nextImage() {
    if (state.product != null) {
      final images = state.product!.allImages;
      if (images.isNotEmpty) {
        final nextIndex = (state.selectedImageIndex + 1) % images.length;
        state = state.copyWith(selectedImageIndex: nextIndex);
      }
    }
  }

  void previousImage() {
    if (state.product != null) {
      final images = state.product!.allImages;
      if (images.isNotEmpty) {
        final prevIndex = (state.selectedImageIndex - 1 + images.length) % images.length;
        state = state.copyWith(selectedImageIndex: prevIndex);
      }
    }
  }
}

// Provider
final productDetailProvider =
    StateNotifierProvider<ProductDetailNotifier, ProductDetailState>((ref) {
  return ProductDetailNotifier();
});

