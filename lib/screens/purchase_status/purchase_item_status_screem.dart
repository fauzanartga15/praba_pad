// lib/screens/purchase/purchase_items_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controllers/theme_controller.dart';
import '../../models/purchase_transaction_model.dart';
import '../../responsive.dart';

// Helper class to combine item with transaction info
class ItemWithTransaction {
  final PurchaseTransactionItem item;
  final PurchaseTransaction transaction;

  ItemWithTransaction(this.item, this.transaction);
}

class PurchaseItemsScreen extends StatefulWidget {
  const PurchaseItemsScreen({super.key});

  @override
  State<PurchaseItemsScreen> createState() => _PurchaseItemsScreenState();
}

class _PurchaseItemsScreenState extends State<PurchaseItemsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _rowsPerPage = 10;
  int _currentPage = 0;
  String? _selectedSupplier;
  ItemStatus? _selectedStatus;

  // Data
  List<ItemWithTransaction> _allItems = [];
  final List<int> _rowOptions = [10, 20, 50, 100];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Generate transactions and flatten all items
    final transactions = generateSamplePurchaseTransactions(count: 25);
    _allItems = [];

    for (final transaction in transactions) {
      for (final item in transaction.items) {
        _allItems.add(ItemWithTransaction(item, transaction));
      }
    }
  }

  List<ItemWithTransaction> get _filteredItems {
    List<ItemWithTransaction> filtered = _allItems;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((itemTx) {
        return itemTx.item.sku.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            itemTx.item.productName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            itemTx.transaction.supplierName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            itemTx.transaction.id.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }

    // Apply supplier filter
    if (_selectedSupplier != null) {
      filtered = filtered
          .where(
            (itemTx) => itemTx.transaction.supplierName == _selectedSupplier,
          )
          .toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered
          .where((itemTx) => itemTx.item.status == _selectedStatus)
          .toList();
    }

    return filtered;
  }

  List<ItemWithTransaction> get _paginatedItems {
    final filtered = _filteredItems;
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  int get _totalPages => _filteredItems.isEmpty
      ? 1
      : (_filteredItems.length / _rowsPerPage).ceil();

  Color _getStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.diproses:
        return Colors.orange;
      case ItemStatus.display:
        return Colors.blue;
      case ItemStatus.selesai:
        return Colors.green;
      case ItemStatus.pending:
        return Colors.red;
    }
  }

  String _getStatusText(ItemStatus status) {
    switch (status) {
      case ItemStatus.diproses:
        return 'Di Proses';
      case ItemStatus.display:
        return 'Display';
      case ItemStatus.selesai:
        return 'Selesai';
      case ItemStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(themeController.isDarkMode),
                SizedBox(height: defaultPadding),
                _buildActionBar(themeController.isDarkMode),
                SizedBox(height: defaultPadding),
                _buildStatsCards(themeController.isDarkMode),
                SizedBox(height: defaultPadding),
                _buildItemsTable(themeController.isDarkMode),
                SizedBox(height: defaultPadding),
                _buildPagination(themeController.isDarkMode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.inventory_2_outlined, size: 32, color: Colors.teal),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Barang Pembelian',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: getTextColor(isDarkMode),
                ),
              ),
              Text(
                'Status dan tracking barang per item SKU',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2, size: 16, color: Colors.teal),
              SizedBox(width: 4),
              Text(
                '${_filteredItems.length} items',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(bool isDarkMode) {
    final diprosesCount = _allItems
        .where((item) => item.item.status == ItemStatus.diproses)
        .length;
    final displayCount = _allItems
        .where((item) => item.item.status == ItemStatus.display)
        .length;
    final selesaiCount = _allItems
        .where((item) => item.item.status == ItemStatus.selesai)
        .length;
    final pendingCount = _allItems
        .where((item) => item.item.status == ItemStatus.pending)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            isDarkMode,
            'Total Items',
            '${_allItems.length}',
            Icons.inventory_2,
            Colors.teal,
          ),
        ),
        SizedBox(width: defaultPadding),
        Expanded(
          child: _buildStatCard(
            isDarkMode,
            'Di Proses',
            '$diprosesCount',
            Icons.hourglass_empty,
            Colors.orange,
          ),
        ),
        SizedBox(width: defaultPadding),
        Expanded(
          child: _buildStatCard(
            isDarkMode,
            'Display',
            '$displayCount',
            Icons.visibility,
            Colors.blue,
          ),
        ),
        SizedBox(width: defaultPadding),
        Expanded(
          child: _buildStatCard(
            isDarkMode,
            'Selesai',
            '$selesaiCount',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        SizedBox(width: defaultPadding),
        Expanded(
          child: _buildStatCard(
            isDarkMode,
            'Pending', // Changed from 'Selesai' to 'Pending'
            '$pendingCount', // Use pendingCount instead of selesaiCount
            Icons.warning, // Changed icon
            Colors.red, // Changed color
          ),
        ),
      ],
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(bool isDarkMode) {
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
        children: [
          // Search & Export Row
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? getSecondaryColor(true)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _currentPage = 0;
                      });
                    },
                    decoration: InputDecoration(
                      hintText:
                          'Cari SKU, produk, ID pembelian, atau supplier...',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(color: getTextColor(isDarkMode)),
                  ),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _exportData,
                icon: Icon(Icons.file_download_outlined, size: 18),
                label: Text('Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Filter Row
          if (Responsive.isMobile(context))
            _buildMobileFilters(isDarkMode)
          else
            _buildDesktopFilters(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildDesktopFilters(bool isDarkMode) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildSupplierFilter(isDarkMode)),
        SizedBox(width: 12),
        Expanded(flex: 2, child: _buildStatusFilter(isDarkMode)),
        SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _clearFilters,
          icon: Icon(Icons.clear, size: 18),
          label: Text('Clear'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _updateAllStatus,
          icon: Icon(Icons.update, size: 18),
          label: Text('Update Status'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFilters(bool isDarkMode) {
    return Column(
      children: [
        _buildSupplierFilter(isDarkMode),
        SizedBox(height: 12),
        _buildStatusFilter(isDarkMode),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _clearFilters,
                icon: Icon(Icons.clear, size: 18),
                label: Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _updateAllStatus,
                icon: Icon(Icons.update, size: 18),
                label: Text('Update'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSupplierFilter(bool isDarkMode) {
    final uniqueSuppliers =
        _allItems.map((item) => item.transaction.supplierName).toSet().toList()
          ..sort();

    return DropdownButtonFormField<String>(
      initialValue: _selectedSupplier,
      decoration: InputDecoration(
        labelText: 'Filter Supplier',
        prefixIcon: Icon(Icons.business_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: isDarkMode ? getSecondaryColor(true) : Colors.grey.shade50,
      ),
      items: [
        DropdownMenuItem<String>(value: null, child: Text('Semua Supplier')),
        ...uniqueSuppliers.map(
          (supplier) => DropdownMenuItem<String>(
            value: supplier,
            child: Text(supplier, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedSupplier = value;
          _currentPage = 0;
        });
      },
      isExpanded: true,
    );
  }

  Widget _buildStatusFilter(bool isDarkMode) {
    return DropdownButtonFormField<ItemStatus>(
      initialValue: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status Barang',
        prefixIcon: Icon(Icons.assessment_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: isDarkMode ? getSecondaryColor(true) : Colors.grey.shade50,
      ),
      items: [
        DropdownMenuItem<ItemStatus>(value: null, child: Text('Semua Status')),
        ...ItemStatus.values.map(
          (status) => DropdownMenuItem<ItemStatus>(
            value: status,
            child: Text(_getStatusText(status)),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedStatus = value;
          _currentPage = 0;
        });
      },
      isExpanded: true,
    );
  }

  Widget _buildItemsTable(bool isDarkMode) {
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
                'Status Barang Pembelian',
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
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Per Item Tracking',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Showing ${_paginatedItems.length} of ${_filteredItems.length} records',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: defaultPadding),
          if (Responsive.isMobile(context))
            _buildMobileCards(isDarkMode)
          else
            _buildDesktopTable(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        headingRowColor: WidgetStateProperty.all(
          isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.withValues(alpha: 0.05),
        ),
        columns: [
          DataColumn(label: _buildColumnHeader('SKU', isDarkMode)),
          DataColumn(label: _buildColumnHeader('ID Pembelian', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Supplier', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Produk', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Qty', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Satuan', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Total', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Status', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Tanggal', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Detail', isDarkMode)),
        ],
        rows: _paginatedItems.map((itemTx) {
          final statusColor = _getStatusColor(itemTx.item.status);

          return DataRow(
            cells: [
              // SKU
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    itemTx.item.sku,
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              // ID Pembelian
              DataCell(
                Text(
                  itemTx.transaction.id,
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontSize: 11,
                  ),
                ),
              ),
              // Supplier
              DataCell(
                Text(
                  itemTx.transaction.supplierName,
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Produk
              DataCell(
                Text(
                  itemTx.item.productName,
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Qty
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${itemTx.item.qty}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              // Satuan
              DataCell(
                Text(
                  itemTx.item.satuan,
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontSize: 11,
                  ),
                ),
              ),
              // Total
              DataCell(
                Text(
                  'Rp ${_formatNumber(itemTx.item.total)}',
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              // Status
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(itemTx.item.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              // Tanggal
              DataCell(
                Text(
                  _formatDateISO(itemTx.item.tanggal),
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontSize: 11,
                  ),
                ),
              ),
              // Detail
              DataCell(
                ElevatedButton.icon(
                  onPressed: () => _viewItemDetail(itemTx),
                  icon: Icon(Icons.visibility, size: 14),
                  label: Text('Detail'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    minimumSize: Size(60, 26),
                    textStyle: TextStyle(fontSize: 9),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileCards(bool isDarkMode) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _paginatedItems.length,
      itemBuilder: (context, index) {
        final itemTx = _paginatedItems[index];
        final statusColor = _getStatusColor(itemTx.item.status);

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      itemTx.item.sku,
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      _getStatusText(itemTx.item.status).toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    _formatDateISO(itemTx.item.tanggal),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                itemTx.item.productName,
                style: TextStyle(
                  color: getTextColor(isDarkMode),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${itemTx.transaction.supplierName} • ${itemTx.transaction.id}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Qty: ${itemTx.item.qty} ${itemTx.item.satuan}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '@Rp ${_formatNumber(itemTx.item.hargaSatuan)}',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Rp ${_formatNumber(itemTx.item.total)}',
                        style: TextStyle(
                          color: getTextColor(isDarkMode),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _viewItemDetail(itemTx),
                  icon: Icon(Icons.visibility, size: 16),
                  label: Text('Lihat Detail'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPagination(bool isDarkMode) {
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
      child: Row(
        children: [
          // Rows per page
          Text(
            'Rows per page:',
            style: TextStyle(color: getTextColor(isDarkMode), fontSize: 14),
          ),
          SizedBox(width: 8),
          DropdownButton<int>(
            value: _rowsPerPage,
            items: _rowOptions.map((rows) {
              return DropdownMenuItem<int>(value: rows, child: Text('$rows'));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _rowsPerPage = value!;
                _currentPage = 0;
              });
            },
            underline: SizedBox.shrink(),
          ),
          Spacer(),
          // Page info
          Text(
            'Page ${_currentPage + 1} of ${_totalPages}',
            style: TextStyle(color: getTextColor(isDarkMode), fontSize: 14),
          ),
          SizedBox(width: 16),
          // Navigation buttons
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 0
                    ? () {
                        setState(() {
                          _currentPage--;
                        });
                      }
                    : null,
                icon: Icon(Icons.chevron_left),
                color: getTextColor(isDarkMode),
              ),
              IconButton(
                onPressed: (_currentPage < _totalPages - 1 && _totalPages > 1)
                    ? () {
                        setState(() {
                          _currentPage++;
                        });
                      }
                    : null,
                icon: Icon(Icons.chevron_right),
                color: getTextColor(isDarkMode),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(String text, bool isDarkMode) {
    return Text(
      text,
      style: TextStyle(
        color: getTextColor(isDarkMode),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  String _formatDateISO(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Action methods
  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.file_download_outlined, color: Colors.white),
            SizedBox(width: 8),
            Text('Export ${_filteredItems.length} data barang berhasil!'),
          ],
        ),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Download',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedSupplier = null;
      _selectedStatus = null;
      _searchQuery = '';
      _searchController.clear();
      _currentPage = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filter berhasil dibersihkan'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _updateAllStatus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.update, color: Colors.teal),
            SizedBox(width: 8),
            Text('Update Status Barang'),
          ],
        ),
        content: Text(
          'Update status semua barang yang sedang di proses menjadi display?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Status barang berhasil diupdate!'),
                    ],
                  ),
                  backgroundColor: Colors.teal,
                ),
              );
            },
            icon: Icon(Icons.check),
            label: Text('Update'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _viewItemDetail(ItemWithTransaction itemTx) {
    final statusColor = _getStatusColor(itemTx.item.status);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.inventory_2, color: Colors.teal),
            SizedBox(width: 8),
            Text('Detail Barang'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('SKU', itemTx.item.sku),
              _buildDetailRow('Produk', itemTx.item.productName),
              _buildDetailRow('ID Pembelian', itemTx.transaction.id),
              _buildDetailRow('Supplier', itemTx.transaction.supplierName),
              _buildDetailRow(
                'Status',
                _getStatusText(itemTx.item.status),
                statusColor: statusColor,
              ),
              _buildDetailRow('Tanggal', _formatDateISO(itemTx.item.tanggal)),
              Divider(),
              _buildDetailRow(
                'Qty',
                '${itemTx.item.qty} ${itemTx.item.satuan}',
              ),
              _buildDetailRow(
                'Harga Satuan',
                'Rp ${_formatNumber(itemTx.item.hargaSatuan)}',
              ),
              _buildDetailRow(
                'Total',
                'Rp ${_formatNumber(itemTx.item.total)}',
                isTotal: true,
              ),
              Divider(),
              Text(
                'Info Pembelian:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              _buildDetailRow('No. Faktur', itemTx.transaction.noFaktur),
              _buildDetailRow(
                'Total Pembelian',
                'Rp ${_formatNumber(itemTx.transaction.total)}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _changeItemStatus(itemTx);
            },
            icon: Icon(Icons.edit),
            label: Text('Ubah Status'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? statusColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Text(': ', style: TextStyle(color: Colors.grey[600])),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTotal || statusColor != null
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: statusColor ?? (isTotal ? Colors.green : null),
                fontSize: isTotal ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeItemStatus(ItemWithTransaction itemTx) {
    ItemStatus? newStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.teal),
            SizedBox(width: 8),
            Text('Ubah Status Barang'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Barang: ${itemTx.item.productName}'),
            Text('SKU: ${itemTx.item.sku}'),
            Text('Status saat ini: ${_getStatusText(itemTx.item.status)}'),
            SizedBox(height: 16),
            Text('Pilih status baru:'),
            SizedBox(height: 8),
            DropdownButtonFormField<ItemStatus>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Status Baru',
              ),
              items: ItemStatus.values.map((status) {
                return DropdownMenuItem<ItemStatus>(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(_getStatusText(status)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                newStatus = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (newStatus != null) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Status ${itemTx.item.sku} berhasil diubah ke ${_getStatusText(newStatus!)}!',
                        ),
                      ],
                    ),
                    backgroundColor: Colors.teal,
                  ),
                );
              }
            },
            icon: Icon(Icons.save),
            label: Text('Simpan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
