import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddBannerScreen extends StatefulWidget {
  const AddBannerScreen({super.key});

  @override
  State<AddBannerScreen> createState() => _AddBannerScreenState();
}

class _AddBannerScreenState extends State<AddBannerScreen> {

  final CollectionReference bannerRef =
  FirebaseFirestore.instance.collection("banners");

  final TextEditingController titleController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController orderController = TextEditingController();

  // ---------- SAVE BANNER ----------
  Future<void> saveBanner() async {
    await bannerRef.add({
      "title": titleController.text,
      "imageUrl": imageController.text,
      "order": int.tryParse(orderController.text) ?? 0,
      "isActive": true,
      "createdAt": FieldValue.serverTimestamp(),
    });

    titleController.clear();
    imageController.clear();
    orderController.clear();

    setState(() {});
  }

  // ---------- GET BANNERS ----------
  Future<List<Map<String, dynamic>>> getBanners() async {
    final snapshot = await bannerRef
        .orderBy("order")
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Web Admin Panel - Banners"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Banner Title",
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
            const SizedBox(height: 10),

            TextField(
              controller: orderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Order",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveBanner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  "SAVE BANNER",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getBanners(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final banners = snapshot.data!;

                  if (banners.isEmpty) {
                    return const Center(
                        child: Text("No banners added yet"));
                  }

                  return ListView.builder(
                    itemCount: banners.length,
                    itemBuilder: (context, index) {
                      final banner = banners[index];
                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            banner['imageUrl'] ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image),
                          ),
                          title: Text(banner['title'] ?? ''),
                          subtitle: Text("Order: ${banner['order'] ?? 0}"),
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
