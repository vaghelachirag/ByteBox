import 'package:bytebox/widget/banner_widget.dart';
import 'package:flutter/material.dart';

class BannerScreen extends StatelessWidget {
  BannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Banners"),
        centerTitle: true,
      ),
      body: BannerSlider()
    );
  }
}
