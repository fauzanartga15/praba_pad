import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controllers/menu_app_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../responsive.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return SafeArea(
          child: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                _buildHeader(context, themeController.isDarkMode),
                SizedBox(height: defaultPadding),

                // Main Statistics Cards
                _buildMainStatsGrid(context, themeController.isDarkMode),
                SizedBox(height: defaultPadding),

                // Charts and Details Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          _buildFinancialOverview(themeController.isDarkMode),
                          SizedBox(height: defaultPadding),
                          _buildRecentTransactions(themeController.isDarkMode),
                          if (Responsive.isMobile(context))
                            SizedBox(height: defaultPadding),
                          if (Responsive.isMobile(context))
                            _buildQuickActions(
                              context,
                              themeController.isDarkMode,
                            ),
                        ],
                      ),
                    ),
                    if (!Responsive.isMobile(context))
                      SizedBox(width: defaultPadding),
                    if (!Responsive.isMobile(context))
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildQuickActions(
                              context,
                              themeController.isDarkMode,
                            ),
                            SizedBox(height: defaultPadding),
                            _buildInventoryAlerts(themeController.isDarkMode),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              context.read<MenuAppController>().controlMenu;
            },
          ),
        if (!Responsive.isMobile(context))
          Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: getTextColor(isDarkMode),
            ),
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        Expanded(child: SearchField()),
        ThemeToggleButton(),

        // Welcome message
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.1),
                  primaryColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.waving_hand, color: Colors.orange, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang, Angelina!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: getTextColor(isDarkMode),
                        ),
                      ),
                      Text(
                        'Kelola pembelian dan supplier dengan mudah',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Online',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatsGrid(BuildContext context, bool isDarkMode) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
      crossAxisSpacing: defaultPadding,
      mainAxisSpacing: defaultPadding,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          isDarkMode,
          'Total Pembelian',
          'Rp 2.4M',
          '↗ 12.5%',
          Icons.shopping_cart_outlined,
          Colors.blue,
          'Bulan ini',
        ),
        _buildStatCard(
          isDarkMode,
          'Supplier Aktif',
          '28',
          '↗ 3 baru',
          Icons.people_outline,
          Colors.green,
          'Total supplier',
        ),
        _buildStatCard(
          isDarkMode,
          'Pending Order',
          '15',
          '↗ 5 urgent',
          Icons.pending_actions_outlined,
          Colors.orange,
          'Butuh perhatian',
        ),
        _buildStatCard(
          isDarkMode,
          'Stok Rendah',
          '8',
          '↗ 3 kritis',
          Icons.warning_amber_outlined,
          Colors.red,
          'Produk',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    bool isDarkMode,
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
    String subtitle,
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: getTextColor(isDarkMode),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: getTextColor(isDarkMode),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode ? Colors.white60 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(bool isDarkMode) {
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
              Text(
                "Ringkasan Keuangan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: getTextColor(isDarkMode),
                ),
              ),
              Spacer(),
              DropdownButton<String>(
                value: 'Bulan ini',
                items: ['Hari ini', 'Minggu ini', 'Bulan ini', 'Tahun ini']
                    .map(
                      (period) =>
                          DropdownMenuItem(value: period, child: Text(period)),
                    )
                    .toList(),
                onChanged: (value) {},
                underline: SizedBox.shrink(),
                icon: Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
          SizedBox(height: defaultPadding),

          // Financial Chart Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
            ),
            child: Stack(
              children: [
                // Simulated chart lines
                CustomPaint(
                  size: Size(double.infinity, 200),
                  painter: SimpleChartPainter(isDarkMode),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 40,
                        color: primaryColor.withValues(alpha: 0.5),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Trend Pembelian',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: defaultPadding),

          // Financial Summary
          Row(
            children: [
              Expanded(
                child: _buildFinancialSummaryItem(
                  isDarkMode,
                  'Total Pembelian',
                  'Rp 2.4M',
                  '↗ 12.5%',
                  Colors.blue,
                ),
              ),
              SizedBox(width: defaultPadding),
              Expanded(
                child: _buildFinancialSummaryItem(
                  isDarkMode,
                  'Rata-rata Harian',
                  'Rp 80K',
                  '↗ 8.2%',
                  Colors.green,
                ),
              ),
              SizedBox(width: defaultPadding),
              Expanded(
                child: _buildFinancialSummaryItem(
                  isDarkMode,
                  'Outstanding',
                  'Rp 350K',
                  '↘ 15.3%',
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryItem(
    bool isDarkMode,
    String label,
    String value,
    String change,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: getTextColor(isDarkMode),
            ),
          ),
          SizedBox(height: 2),
          Text(
            change,
            style: TextStyle(
              fontSize: 10,
              color: change.startsWith('↗') ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(bool isDarkMode) {
    final recentTransactions = [
      {
        'id': 'PO001',
        'supplier': 'PT Kimia Farma Trading',
        'amount': 'Rp 450.000',
        'status': 'Completed',
        'statusColor': Colors.green,
        'date': '2 jam lalu',
        'items': '5 items',
      },
      {
        'id': 'PO002',
        'supplier': 'PT Kalbe Farma Tbk',
        'amount': 'Rp 820.000',
        'status': 'Pending',
        'statusColor': Colors.orange,
        'date': '4 jam lalu',
        'items': '8 items',
      },
      {
        'id': 'PO003',
        'supplier': 'PT Sanbe Farma',
        'amount': 'Rp 320.000',
        'status': 'Processing',
        'statusColor': Colors.blue,
        'date': '6 jam lalu',
        'items': '3 items',
      },
      {
        'id': 'PO004',
        'supplier': 'PT Dexa Medica',
        'amount': 'Rp 680.000',
        'status': 'Completed',
        'statusColor': Colors.green,
        'date': '1 hari lalu',
        'items': '12 items',
      },
      {
        'id': 'PO005',
        'supplier': 'PT Combiphar',
        'amount': 'Rp 290.000',
        'status': 'Invoice',
        'statusColor': Colors.purple,
        'date': '1 hari lalu',
        'items': '4 items',
      },
    ];

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
              Text(
                "Transaksi Terkini",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: getTextColor(isDarkMode),
                ),
              ),
              Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.arrow_forward, size: 16),
                label: Text('Lihat Semua'),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
            ],
          ),
          SizedBox(height: defaultPadding),

          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: recentTransactions.length,
            separatorBuilder: (context, index) =>
                Divider(color: getBorderColor(isDarkMode), height: 1),
            itemBuilder: (context, index) {
              final transaction = recentTransactions[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                transaction['id'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: getTextColor(isDarkMode),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: (transaction['statusColor'] as Color)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  transaction['status'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: transaction['statusColor'] as Color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text(
                            transaction['supplier'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          transaction['amount'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: getTextColor(isDarkMode),
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              transaction['items'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode
                                    ? Colors.white60
                                    : Colors.black45,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '•',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode
                                    ? Colors.white60
                                    : Colors.black45,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              transaction['date'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode
                                    ? Colors.white60
                                    : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, isDarkMode) {
    final quickActions = [
      {
        'title': 'Buat Pembelian',
        'icon': Icons.add_shopping_cart_outlined,
        'color': Colors.green,
        'description': 'Tambah order baru',
      },
      {
        'title': 'Kelola Supplier',
        'icon': Icons.people_outline,
        'color': Colors.blue,
        'description': 'Data supplier',
      },
      {
        'title': 'Cek Stok',
        'icon': Icons.inventory_2_outlined,
        'color': Colors.orange,
        'description': 'Monitor inventory',
      },
      {
        'title': 'Laporan',
        'icon': Icons.analytics_outlined,
        'color': Colors.purple,
        'description': 'Analisis data',
      },
    ];

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
          Text(
            "Aksi Cepat",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: getTextColor(isDarkMode),
            ),
          ),
          SizedBox(height: defaultPadding),

          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.isMobile(context) ? 2 : 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: Responsive.isMobile(context) ? 1.8 : 3.5,
            ),
            itemCount: quickActions.length,
            itemBuilder: (context, index) {
              final action = quickActions[index];
              return GestureDetector(
                onTap: () {
                  // Handle quick action
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (action['color'] as Color).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (action['color'] as Color).withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                          size: 20,
                        ),
                      ),
                      if (!Responsive.isMobile(context) ||
                          Responsive.isTablet(context)) ...[
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                action['title'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: getTextColor(isDarkMode),
                                ),
                              ),
                              Text(
                                action['description'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 8),
                              Text(
                                action['title'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: getTextColor(isDarkMode),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryAlerts(bool isDarkMode) {
    final alerts = [
      {
        'product': 'Paracetamol 500mg',
        'stock': '12',
        'min': '50',
        'status': 'critical',
        'color': Colors.red,
      },
      {
        'product': 'Amoxicillin 500mg',
        'stock': '28',
        'min': '50',
        'status': 'low',
        'color': Colors.orange,
      },
      {
        'product': 'Ibuprofen 400mg',
        'stock': '35',
        'min': '50',
        'status': 'low',
        'color': Colors.orange,
      },
      {
        'product': 'Vitamin C 1000mg',
        'stock': '8',
        'min': '30',
        'status': 'critical',
        'color': Colors.red,
      },
    ];

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
              Text(
                "Peringatan Stok",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: getTextColor(isDarkMode),
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${alerts.length}',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: defaultPadding),

          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (alert['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (alert['color'] as Color).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: alert['color'] as Color,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alert['product'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: getTextColor(isDarkMode),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Stok: ${alert['stock']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: alert['color'] as Color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Min: ${alert['min']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDarkMode ? Colors.white60 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: defaultPadding),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.inventory_2_outlined, size: 16),
              label: Text('Kelola Stok'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for simple chart visualization
class SimpleChartPainter extends CustomPainter {
  final bool isDarkMode;

  SimpleChartPainter(this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [
      Offset(size.width * 0.1, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.7, size.height * 0.5),
      Offset(size.width * 0.9, size.height * 0.3),
    ];

    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(points[i].dx, points[i].dy);
      } else {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return Container(
          margin: EdgeInsets.only(left: defaultPadding / 2),
          child: IconButton(
            onPressed: themeController.toggleTheme,
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Icon(
                themeController.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                key: ValueKey(themeController.isDarkMode),
                color: themeController.isDarkMode
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
            tooltip: themeController.isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
          ),
        );
      },
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return TextField(
          style: TextStyle(color: getTextColor(themeController.isDarkMode)),
          decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(
              color: themeController.isDarkMode
                  ? Colors.white54
                  : Colors.black54,
            ),
            fillColor: getCardColor(themeController.isDarkMode),
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            suffixIcon: InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(defaultPadding * 0.75),
                margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: SvgPicture.asset(
                  "assets/icons/Search.svg",
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
