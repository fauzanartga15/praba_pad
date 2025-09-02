import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screen.dart';
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
    print('Selected menu: $menu');
  }

  void _handleSubMenuSelection(String subMenu) {
    print('Selected submenu: $subMenu');

    // Handle specific submenu navigation
    switch (subMenu) {
      case 'Tambah Supplier Baru':
      case 'Data Supplier':
        setState(() {
          currentPage = 'supplier';
        });
        break;
      case 'Kelola Data Supplier':
        setState(() {
          currentPage = 'supplier';
        });
        break;
      case 'Laporan Supplier':
        setState(() {
          currentPage = 'supplier';
        });
        break;
      case 'Order Baru':
      case 'Template Order':
      case 'Draft Tersimpan':
        setState(() {
          currentPage = 'buat';
        });
        break;
      case 'Semua Order':
      case 'Order Pending':
      case 'Order Selesai':
        setState(() {
          currentPage = 'lihat';
        });
        break;
    }

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to: $subMenu'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 120, // Above bottom nav
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (currentPage) {
      case 'dashboard':
        return DashboardScreen();
      case 'supplier':
        return SupplierMainScreen(); // Now shows the complete supplier system
      case 'buat':
        return _buildPlaceholderScreen(
          'Buat Pembelian',
          Icons.add_shopping_cart,
        );
      case 'lihat':
        return _buildPlaceholderScreen('Lihat Pembelian', Icons.receipt_long);
      default:
        return DashboardScreen();
    }
  }

  Widget _buildPlaceholderScreen(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 80, color: Colors.grey),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This screen is under development',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
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
            // Bottom navigation for tablet/mobile
            if (!Responsive.isDesktop(context))
              ExpandableBottomNav(
                onMenuSelected: _handleMenuSelection,
                onSubMenuSelected: _handleSubMenuSelection,
              ),
          ],
        ),
      ),
    );
  }
}
