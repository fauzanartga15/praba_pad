// lib/screens/main/main_screen.dart (UPDATED)

import 'package:flutter/material.dart';
import 'package:praba_ipad/screens/purchase_order/purchase_order_screen.dart';
import 'package:provider/provider.dart';

import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screen.dart';
import '../purchase_status/purchase_main_screen.dart';
import '../suppliers/supplier_main_screen.dart';
import 'components/expandablebottom.dart';
import 'components/side_menu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String currentPage = 'dashboard';

  void _handleMenuSelection(String menu) {
    setState(() {
      currentPage = menu;
    });

    // Show feedback with better UX
    String displayName = _getMenuDisplayName(menu);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to $displayName'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 140, // Above bottom nav
          left: 20,
          right: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getMenuDisplayName(String menu) {
    switch (menu) {
      case 'dashboard':
        return 'Dashboard';
      case 'supplier':
        return 'Supplier Management';
      case 'buat':
        return 'Create Purchase';
      case 'lihat':
        return 'Data Pembelian';
      default:
        return 'Dashboard';
    }
  }

  Widget _getCurrentScreen() {
    switch (currentPage) {
      case 'dashboard':
        return DashboardScreen();
      case 'supplier':
        return SupplierMainScreen();
      case 'buat':
        return CreatePurchaseScreen();
      case 'lihat':
        return PurchaseMainScreen();
      default:
        return DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Side menu for desktop
                if (Responsive.isDesktop(context)) Expanded(child: SideMenu()),
                // Main content area
                Expanded(flex: 5, child: _getCurrentScreen()),
              ],
            ),
            // Bottom navigation for tablet/mobile with swipe functionality
            if (!Responsive.isDesktop(context))
              ExpandableBottomNav(onMenuSelected: _handleMenuSelection),
          ],
        ),
      ),
    );
  }
}
