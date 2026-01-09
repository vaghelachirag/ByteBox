import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/NewArrivalModel.dart';
import '../providers/new_arrivals_list_provider.dart';

class NewArrivalsPage extends ConsumerWidget {
  const NewArrivalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(newArrivalsListProvider);
    final notifier = ref.read(newArrivalsListProvider.notifier);
    final products = notifier.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Arrivals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const FilterBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(onChanged: notifier.updateSearchQuery),
          _SortDropdown(
            value: filterState.sortBy,
            onChanged: notifier.setSortBy,
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('No products found'))
                : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (_, index) {
                return ProductCard(product: products[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search laptop...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
class _SortDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SortDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        items: sortOptions
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => onChanged(v!),
        decoration: const InputDecoration(
          labelText: 'Sort By',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
class ProductCard extends StatelessWidget {
  final NewArrivalModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(14)),
              child: product.images.isEmpty
                  ? const Center(child: Icon(Icons.image_not_supported))
                  : Image.network(
                product.images.first,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  product.processor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newArrivalsListProvider);
    final notifier = ref.read(newArrivalsListProvider.notifier);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            /// BRAND FILTER
            const SizedBox(height: 16),
            const Text('Brand'),
            Wrap(
              spacing: 8,
              children: availableBrands.map((brand) {
                final selected = state.selectedBrands.contains(brand);
                return FilterChip(
                  label: Text(brand),
                  selected: selected,
                  onSelected: (_) => notifier.toggleBrand(brand),
                );
              }).toList(),
            ),

            /// RAM
            const SizedBox(height: 16),
            const Text('RAM'),
            Wrap(
              spacing: 8,
              children: availableRAM.map((ram) {
                return FilterChip(
                  label: Text(ram),
                  selected: state.selectedRAM.contains(ram),
                  onSelected: (_) => notifier.toggleRAM(ram),
                );
              }).toList(),
            ),

            /// STORAGE
            const SizedBox(height: 16),
            const Text('Storage'),
            Wrap(
              spacing: 8,
              children: availableSSD.map((ssd) {
                return FilterChip(
                  label: Text(ssd),
                  selected: state.selectedSSD.contains(ssd),
                  onSelected: (_) => notifier.toggleSSD(ssd),
                );
              }).toList(),
            ),

            /// PRICE
            const SizedBox(height: 16),
            const Text('Price Range'),
            RangeSlider(
              values: RangeValues(state.minPrice, state.maxPrice),
              min: 0,
              max: 200000,
              divisions: 100,
              labels: RangeLabels(
                '₹${state.minPrice.toInt()}',
                '₹${state.maxPrice.toInt()}',
              ),
              onChanged: (v) =>
                  notifier.updatePriceRange(v.start, v.end),
            ),

            const SizedBox(height: 20),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: notifier.clearAllFilters,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
