import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final CollectionReference productRef =
  FirebaseFirestore.instance.collection("products");


  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  // ---------- SAVE PRODUCT ----------
  Future<void> saveProduct() async {
    await productRef.add({
      "name": nameController.text,
      "price": int.tryParse(priceController.text) ?? 0,
      "imageUrl": imageController.text,
      "isActive": true,
      "createdAt": FieldValue.serverTimestamp(),
    });

    nameController.clear();
    priceController.clear();
    imageController.clear();

    setState(() {});
  }

  // ---------- GET PRODUCTS ----------
  Future<List<Map<String, dynamic>>> getProducts() async {
    final snapshot = await productRef
        .where("isActive", isEqualTo: true)
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return {
        "id": doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Web Admin Panel"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // -------- INPUT FIELDS --------
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                labelText: "Image URL",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // -------- SAVE BUTTON --------
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  "SAVE PRODUCT",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // -------- PRODUCT LIST --------
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getProducts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!;

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            product['imageUrl'],
                            width: 60,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image),
                          ),
                          title: Text(product['name']),
                          subtitle: Text("₹${product['price']}"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}