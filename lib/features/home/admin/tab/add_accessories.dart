import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddAccessoriesScreen extends StatefulWidget {
  const AddAccessoriesScreen({super.key});

  @override
  State<AddAccessoriesScreen> createState() => _AddAccessoriesScreenState();
}

class _AddAccessoriesScreenState extends State<AddAccessoriesScreen> {
  final CollectionReference accessoriesRef =
      FirebaseFirestore.instance.collection("accessories");

  // ---------- CONTROLLERS ----------
  final TextEditingController brandController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController mrpController = TextEditingController();
  final TextEditingController discountLabelController = TextEditingController();
  final TextEditingController emiTextController = TextEditingController();

  List<TextEditingController> imageControllers = [TextEditingController()];

  bool isSoldOut = false;

  // ---------- SAVE ACCESSORY ----------
  Future<void> saveAccessory() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter product name and price")),
      );
      return;
    }

    final int price = int.parse(priceController.text.trim());
    final int? mrp = int.tryParse(mrpController.text.trim());

    List<String> images = imageControllers
        .map((c) => c.text.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    await accessoriesRef.add({
      "brand": brandController.text.trim(),
      "name": nameController.text.trim(),
      "color": colorController.text.trim(),
      "price": price,
      "mrp": mrp,
      "discountLabel": discountLabelController.text.trim(),
      "emiText": emiTextController.text.trim(),
      "isSoldOut": isSoldOut,
      "images": images,
      "isActive": true,
      "createdAt": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Accessory Added Successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel – Accessories"),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTextField(brandController, "Brand (e.g. Dell, Lapcare)"),
          const SizedBox(height: 10),

          _buildTextField(nameController, "Product Name (e.g. Dell Keyboard)"),
          const SizedBox(height: 10),

          _buildTextField(colorController, "Color (e.g. White, Black, Red)"),
          const SizedBox(height: 10),

          _buildTextField(priceController, "Price", isNumber: true),
          const SizedBox(height: 10),

          _buildTextField(mrpController, "MRP (optional)", isNumber: true),
          const SizedBox(height: 10),

          _buildTextField(
            discountLabelController,
            "Discount Label (e.g. 70% OFF)",
          ),
          const SizedBox(height: 10),

          _buildTextField(
            emiTextController,
            "EMI Text (e.g. EMI at ₹114)",
          ),
          const SizedBox(height: 10),

          SwitchListTile(
            title: const Text("Sold Out"),
            value: isSoldOut,
            onChanged: (v) => setState(() => isSoldOut = v),
          ),
          const SizedBox(height: 15),

          // ---------- IMAGES ----------
          for (int i = 0; i < imageControllers.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: imageControllers[i],
                      decoration: InputDecoration(
                        labelText: "Image URL ${i + 1}",
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  if (i != 0)
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          final removed = imageControllers.removeAt(i);
                          removed.dispose();
                        });
                      },
                    ),
                ],
              ),
            ),

          TextButton.icon(
            onPressed: () =>
                setState(() => imageControllers.add(TextEditingController())),
            icon: const Icon(Icons.add),
            label: const Text("Add Image"),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: saveAccessory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: const Text(
                "SAVE ACCESSORY",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "Added Accessories",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          FutureBuilder<QuerySnapshot>(
            future: accessoriesRef
                .orderBy("createdAt", descending: true)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Failed to load accessories: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text("No accessories added yet"),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>? ?? {};
                  final images = (data['images'] as List?) ?? const [];
                  final isSoldOutValue = data['isSoldOut'] == true;
                  return Card(
                    child: ListTile(
                      leading: images.isNotEmpty
                          ? Image.network(
                              images.first.toString(),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.headphones_rounded),
                            )
                          : const Icon(Icons.headphones_rounded),
                      title: Text(
                        "${data['brand'] ?? ''} - ${data['name'] ?? ''}",
                      ),
                      subtitle: Text(
                        "₹${data['price'] ?? ''} | ${data['color'] ?? ''}",
                      ),
                      trailing: isSoldOutValue
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "SOLDOUT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    brandController.dispose();
    nameController.dispose();
    colorController.dispose();
    priceController.dispose();
    mrpController.dispose();
    discountLabelController.dispose();
    emiTextController.dispose();
    for (final c in imageControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- HELPERS ----------
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters:
          isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
