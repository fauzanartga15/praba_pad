// lib/screens/purchase/purchase_main_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controllers/theme_controller.dart';
import '../../responsive.dart';
import 'piurchase_process_screen.dart';
import 'purchase_completed_screen.dart';
import 'purchase_invoice_screen.dart';
import 'purchase_item_status_screem.dart';
import 'purchase_request_screen.dart';
import 'purchase_unpaid_screen.dart';

class PurchaseMainScreen extends StatefulWidget {
  const PurchaseMainScreen({super.key});

  @override
  State<PurchaseMainScreen> createState() => _PurchaseMainScreenState();
}

class _PurchaseMainScreenState extends State<PurchaseMainScreen> {
  String currentView = 'overview';

  final Map<String, PurchaseMenuData> purchaseMenus = {
    'overview': PurchaseMenuData(
      title: 'Overview Pembelian',
      icon: Icons.dashboard_outlined,
      description: 'Ringkasan data pembelian dan statistik',
    ),
    'permintaan': PurchaseMenuData(
      title: 'Permintaan',
      icon: Icons.assignment_outlined,
      description: 'Data pembelian yang diajukan',
    ),
    'diproses': PurchaseMenuData(
      title: 'Di Proses',
      icon: Icons.hourglass_empty_outlined,
      description: 'Data pembelian yang sedang diproses',
    ),
    'faktur': PurchaseMenuData(
      title: 'Data Faktur',
      icon: Icons.receipt_long_outlined,
      description: 'Data faktur pembelian',
    ),
    'status_barang': PurchaseMenuData(
      title: 'Status Barang',
      icon: Icons.inventory_2_outlined,
      description: 'Status barang pembelian',
    ),
    'belum_lunas': PurchaseMenuData(
      title: 'Belum Lunas',
      icon: Icons.payment_outlined,
      description: 'Data pembelian belum lunas',
    ),
    'selesai': PurchaseMenuData(
      title: 'Selesai',
      icon: Icons.check_circle_outline,
      description: 'Data pembelian sudah lunas',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return SafeArea(
          child: Column(
            children: [
              // Purchase Navigation Bar (Desktop & Tablet)
              if (!Responsive.isMobile(context))
                _buildNavigationBar(themeController.isDarkMode),
              // Content Area
              Expanded(child: _getCurrentScreen()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationBar(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.all(defaultPadding),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: purchaseMenus.entries.map((entry) {
            final isActive = currentView == entry.key;
            return GestureDetector(
              onTap: () {
                setState(() {
                  currentView = entry.key;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 4),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isActive
                      ? primaryColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isActive
                      ? Border.all(
                          color: primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      entry.value.icon,
                      color: isActive
                          ? primaryColor
                          : getTextColor(isDarkMode).withValues(alpha: 0.7),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      entry.value.title,
                      style: TextStyle(
                        color: isActive
                            ? primaryColor
                            : getTextColor(isDarkMode),
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (currentView) {
      case 'permintaan':
        return PurchaseRequestScreen();
      case 'diproses':
        return PurchaseProcessScreen();
      case 'faktur':
        return PurchaseInvoiceScreen();
      case 'status_barang':
        return PurchaseItemsScreen();
      case 'belum_lunas':
        return PurchaseUnpaidScreen();
      case 'selesai':
        return PurchaseCompletedScreen();
      case 'overview':
      default:
        return _buildOverviewScreen();
    }
  }

  Widget _buildOverviewScreen() {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: primaryColor,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Pembelian',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: getTextColor(themeController.isDarkMode),
                        ),
                      ),
                      Text(
                        'Kelola semua data pembelian dan transaksi',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeController.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: defaultPadding * 2),

              // Quick Stats
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
                crossAxisSpacing: defaultPadding,
                mainAxisSpacing: defaultPadding,
                children: [
                  _buildStatCard(
                    themeController.isDarkMode,
                    'Total Pembelian',
                    '150',
                    Icons.assignment,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    themeController.isDarkMode,
                    'Dalam Proses',
                    '25',
                    Icons.hourglass_empty,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    themeController.isDarkMode,
                    'Belum Lunas',
                    '12',
                    Icons.payment,
                    Colors.red,
                  ),
                  _buildStatCard(
                    themeController.isDarkMode,
                    'Selesai',
                    '113',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              ),

              SizedBox(height: defaultPadding * 2),

              // Quick Access Menu
              Text(
                'Menu Data Pembelian',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: getTextColor(themeController.isDarkMode),
                ),
              ),
              SizedBox(height: defaultPadding),

              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: Responsive.isMobile(context) ? 1 : 2,
                crossAxisSpacing: defaultPadding,
                mainAxisSpacing: defaultPadding,
                childAspectRatio: Responsive.isMobile(context) ? 3 : 2.5,
                children: purchaseMenus.entries
                    .where((entry) => entry.key != 'overview')
                    .map((entry) {
                      return _buildMenuCard(
                        themeController.isDarkMode,
                        entry.value,
                        () {
                          setState(() {
                            currentView = entry.key;
                          });
                        },
                        _getMenuCardColor(entry.key),
                      );
                    })
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getMenuCardColor(String menuKey) {
    switch (menuKey) {
      case 'permintaan':
        return Colors.blue;
      case 'diproses':
        return Colors.orange;
      case 'faktur':
        return Colors.purple;
      case 'status_barang':
        return Colors.teal;
      case 'belum_lunas':
        return Colors.red;
      case 'selesai':
        return Colors.green;
      default:
        return primaryColor;
    }
  }

  Widget _buildStatCard(
    bool isDarkMode,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
              Icon(Icons.trending_up, color: Colors.green, size: 16),
            ],
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: getTextColor(isDarkMode),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    bool isDarkMode,
    PurchaseMenuData menu,
    VoidCallback onTap,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: getCardColor(isDarkMode),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(menu.icon, color: accentColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    menu.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: getTextColor(isDarkMode),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    menu.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: accentColor, size: 16),
          ],
        ),
      ),
    );
  }
}

class PurchaseMenuData {
  final String title;
  final IconData icon;
  final String description;

  PurchaseMenuData({
    required this.title,
    required this.icon,
    required this.description,
  });
}
