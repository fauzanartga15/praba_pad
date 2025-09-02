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
        return 'View Purchases';
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
        return _buildPlaceholderScreen(
          'Create Purchase',
          Icons.add_shopping_cart,
          'Create new purchase orders',
        );
      case 'lihat':
        return _buildPlaceholderScreen(
          'View Purchases',
          Icons.receipt_long,
          'View and manage purchase orders',
        );
      default:
        return DashboardScreen();
    }
  }

  Widget _buildPlaceholderScreen(String title, IconData icon, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF2697FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF2697FF).withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Icon(icon, size: 80, color: const Color(0xFF2697FF)),
          ),
          SizedBox(height: 32),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                currentPage = 'dashboard';
              });
            },
            icon: Icon(Icons.dashboard_outlined),
            label: Text('Back to Dashboard'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: BorderSide(color: const Color(0xFF2697FF)),
              foregroundColor: const Color(0xFF2697FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
            // Bottom navigation for tablet/mobile with swipe functionality
            if (!Responsive.isDesktop(context))
              ExpandableBottomNav(onMenuSelected: _handleMenuSelection),
          ],
        ),
      ),
    );
  }
}
