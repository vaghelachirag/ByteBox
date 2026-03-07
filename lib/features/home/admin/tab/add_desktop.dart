import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddDesktopScreen extends StatefulWidget {
  const AddDesktopScreen({super.key});

  @override
  State<AddDesktopScreen> createState() => _AddDesktopScreenState();
}

class _AddDesktopScreenState extends State<AddDesktopScreen> {
  final CollectionReference desktopRef =
      FirebaseFirestore.instance.collection("desktop");

  // ---------- CONTROLLERS ----------
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController overviewController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController processorController = TextEditingController();

  List<TextEditingController> imageControllers = [TextEditingController()];

  // ---------- DROPDOWN VALUES ----------
  String company = 'HP';
  String ram = '8 GB';
  String storage = '256 GB';
  String os = 'Windows 10';
  String battery = '4 hr';
  String graphics = '-';
  String display = '15 inch';
  String connectivity = '3 USB';

  // ---------- DROPDOWN OPTIONS ----------
  final List<String> companyList = ['HP', 'Lenovo', 'Dell', 'Acer', 'Apple'];
  final List<String> ramList = ['4 GB', '8 GB', '12 GB', '16 GB'];
  final List<String> storageList = ['128 GB', '256 GB', '512 GB', '1 TB'];
  final List<String> osList = [
    'Windows 7',
    'Windows 8',
    'Windows 10',
    'Windows 11'
  ];
  final List<String> batteryList = [
    '2 hr',
    '3 hr',
    '4 hr',
    'More than 4 hr'
  ];
  final List<String> graphicsList = [
    '-',
    '2 GB',
    '3 GB',
    '4 GB',
    'More than 4 GB'
  ];
  final List<String> displayList = [
    '14 inch',
    '15 inch',
    '15.5 inch',
    '16 inch',
    '17 inch',
    '18 inch',
    '20 inch'
  ];
  final List<String> connectivityList = ['3 USB', '4 USB'];

  // ---------- SAVE DESKTOP ----------
  Future<void> saveDesktop() async {
    final int price = int.parse(priceController.text.trim());

    List<String> images = imageControllers
        .map((c) => c.text.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    await desktopRef.add({
      "name": nameController.text.trim(),
      "price": price,
      "overview": overviewController.text.trim(),
      "model": modelController.text.trim(),
      "processor": processorController.text.trim(),

      "company": company,
      "ram": ram,
      "storage": storage,
      "operatingSystem": os,
      "battery": battery,
      "graphics": graphics,
      "display": display,
      "connectivity": connectivity,

      "images": images,
      "isActive": true,
      "createdAt": FieldValue.serverTimestamp(),
    });

    nameController.clear();
    priceController.clear();
    overviewController.clear();
    modelController.clear();
    processorController.clear();
    imageControllers = [TextEditingController()];

    setState(() {});
  }

  // ---------- GET DESKTOPS ----------
  Future<List<Map<String, dynamic>>> getDesktops() async {
    final snapshot = await desktopRef
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel – Desktops"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildTextField(nameController, "Desktop Name"),
            const SizedBox(height: 10),

            _buildDropdown("Company", company, companyList,
                    (v) => setState(() => company = v!)),
            const SizedBox(height: 10),

            _buildTextField(priceController, "Price", isNumber: true),
            const SizedBox(height: 10),

            _buildTextField(overviewController, "Overview", maxLines: 2),
            const SizedBox(height: 10),

            _buildTextField(modelController, "Model"),
            const SizedBox(height: 10),

            _buildTextField(processorController, "Processor"),
            const SizedBox(height: 10),

            _buildDropdown("RAM", ram, ramList,
                    (v) => setState(() => ram = v!)),
            const SizedBox(height: 10),

            _buildDropdown("Storage", storage, storageList,
                    (v) => setState(() => storage = v!)),
            const SizedBox(height: 10),

            _buildDropdown("Operating System", os, osList,
                    (v) => setState(() => os = v!)),
            const SizedBox(height: 10),

            _buildDropdown("Battery", battery, batteryList,
                    (v) => setState(() => battery = v!)),
            const SizedBox(height: 10),

            _buildDropdown("Graphics", graphics, graphicsList,
                    (v) => setState(() => graphics = v!)),
            const SizedBox(height: 10),

            _buildDropdown("Display", display, displayList,
                    (v) => setState(() => display = v!)),
            const SizedBox(height: 10),

            _buildDropdown("Connectivity", connectivity, connectivityList,
                    (v) => setState(() => connectivity = v!)),
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
                        icon:
                            const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            imageControllers.removeAt(i);
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
                onPressed: saveDesktop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  "SAVE DESKTOP",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- HELPERS ----------
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false, int maxLines = 1}) {
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

  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((item) =>
              DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

