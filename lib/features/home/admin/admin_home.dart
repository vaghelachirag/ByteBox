import 'package:bytebox/features/home/admin/tab/add_accessories.dart';
import 'package:bytebox/features/home/admin/tab/add_all_in_one.dart';
import 'package:bytebox/features/home/admin/tab/add_banner.dart';
import 'package:bytebox/features/home/admin/tab/add_best_deal.dart';
import 'package:bytebox/features/home/admin/tab/add_desktop.dart';
import 'package:bytebox/features/home/admin/tab/add_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Banner'),
              Tab(text: 'New Arrivals'),
              Tab(text: 'Desktop'),
              Tab(text: 'All In One'),
              Tab(text: 'Best Deals'),
              Tab(text: 'Accessories'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddBannerScreen(),
            AddProductScreen(),
            AddDesktopScreen(),
            AddAllInOneScreen(),
            AddBestDealScreen(),
            AddAccessoriesScreen(),
          ],
        ),
      ),
    );
  }
}
