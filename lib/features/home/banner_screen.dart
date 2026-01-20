import 'package:bytebox/widget/banner_widget.dart';
import 'package:flutter/material.dart';
import '../../widget/app_header.dart';

class BannerScreen extends StatelessWidget {
  BannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: 'Banners',
        showLogo: false,
      ),
      body: BannerSlider()
    );
  }
}
