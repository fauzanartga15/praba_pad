import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controllers/theme_controller.dart';
import '../../responsive.dart';
import 'data_supplier_screen.dart';
import 'pricelist_screen.dart';

class SupplierMainScreen extends StatefulWidget {
  const SupplierMainScreen({super.key});

  @override
  State<SupplierMainScreen> createState() => _SupplierMainScreenState();
}

class _SupplierMainScreenState extends State<SupplierMainScreen> {
  String currentView = 'overview';

  final Map<String, SupplierMenuData> supplierMenus = {
    'overview': SupplierMenuData(
      title: 'Overview Supplier',
      icon: Icons.dashboard_outlined,
      description: 'Ringkasan data supplier dan statistik',
    ),
    'data_supplier': SupplierMenuData(
      title: 'Data Supplier',
      icon: Icons.people_outline,
      description: 'Kelola informasi supplier dan distributor',
    ),
    'pricelist': SupplierMenuData(
      title: 'Pricelist',
      icon: Icons.price_check_outlined,
      description: 'Kelola harga dan daftar produk supplier',
    ),
    'laporan': SupplierMenuData(
      title: 'Laporan Supplier',
      icon: Icons.analytics_outlined,
      description: 'Analisis performa dan laporan supplier',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return SafeArea(
          child: Column(
            children: [
              // Supplier Navigation Bar
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
      child: Row(
        children: supplierMenus.entries.map((entry) {
          final isActive = currentView == entry.key;
          return Expanded(
            child: GestureDetector(
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      entry.value.icon,
                      color: isActive
                          ? primaryColor
                          : getTextColor(isDarkMode).withValues(alpha: 0.7),
                      size: 18,
                    ),
                    if (!Responsive.isMobile(context)) ...[
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (currentView) {
      case 'data_supplier':
        return DataSupplierScreen();
      case 'pricelist':
        return PricelistScreen(); // Now shows the complete pricelist screen
      case 'laporan':
        return _buildPlaceholderScreen(
          'Laporan Supplier',
          Icons.analytics_outlined,
          'Halaman laporan akan segera tersedia',
        );
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
                      Icons.people_outline,
                      color: primaryColor,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Supplier Management',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: getTextColor(themeController.isDarkMode),
                        ),
                      ),
                      Text(
                        'Kelola semua data supplier dan distributor',
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
                    'Total Supplier',
                    '25',
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    themeController.isDarkMode,
                    'Pabrik',
                    '18',
                    Icons.factory,
                    Colors.green,
                  ),
                  _buildStatCard(
                    themeController.isDarkMode,
                    'PBF',
                    '7',
                    Icons.local_shipping,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    themeController.isDarkMode,
                    'Produk',
                    '1,247',
                    Icons.inventory_2,
                    Colors.purple,
                  ),
                ],
              ),

              SizedBox(height: defaultPadding * 2),

              // Quick Access Menu
              Text(
                'Menu Cepat',
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
                children: supplierMenus.entries
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
    SupplierMenuData menu,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: getCardColor(isDarkMode),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: getBorderColor(isDarkMode), width: 1),
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
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(menu.icon, color: primaryColor, size: 24),
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
            Icon(
              Icons.arrow_forward_ios,
              color: isDarkMode ? Colors.white54 : Colors.black54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderScreen(
    String title,
    IconData icon,
    String description,
  ) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 80, color: primaryColor),
              ),
              SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: getTextColor(themeController.isDarkMode),
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: themeController.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    currentView = 'overview';
                  });
                },
                icon: Icon(Icons.arrow_back),
                label: Text('Kembali ke Overview'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SupplierMenuData {
  final String title;
  final IconData icon;
  final String description;

  SupplierMenuData({
    required this.title,
    required this.icon,
    required this.description,
  });
}
