// lib/screens/purchase_status/purchase_invoice_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controllers/theme_controller.dart';
import '../../models/purchase_transaction_model.dart';
import '../../responsive.dart';

class PurchaseInvoiceScreen extends StatefulWidget {
  const PurchaseInvoiceScreen({super.key});

  @override
  State<PurchaseInvoiceScreen> createState() => _PurchaseInvoiceScreenState();
}

class _PurchaseInvoiceScreenState extends State<PurchaseInvoiceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _rowsPerPage = 10;
  int _currentPage = 0;
  String? _selectedSupplier;

  // Data
  List<PurchaseTransaction> _allTransactions = [];
  final List<int> _rowOptions = [10, 20, 50, 100];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Generate sample data for "Faktur" status only
    _allTransactions = generateSamplePurchaseTransactions(
      filterStatus: TransactionStatus.faktur,
      count: 32, // Different count from other screens
    );
  }

  List<PurchaseTransaction> get _filteredTransactions {
    List<PurchaseTransaction> filtered = _allTransactions;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.id.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            transaction.noFaktur.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            transaction.supplierName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }

    // Apply supplier filter
    if (_selectedSupplier != null) {
      filtered = filtered
          .where((transaction) => transaction.supplierName == _selectedSupplier)
          .toList();
    }

    return filtered;
  }

  List<PurchaseTransaction> get _paginatedTransactions {
    final filtered = _filteredTransactions;
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  int get _totalPages => _filteredTransactions.isEmpty
      ? 1
      : (_filteredTransactions.length / _rowsPerPage).ceil();

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
                _buildTransactionTable(themeController.isDarkMode),
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
    final totalInvoiceValue = _allTransactions.fold(
      0.0,
      (sum, t) => sum + t.total,
    );

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            size: 32,
            color: Colors.purple,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Faktur Pembelian',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: getTextColor(isDarkMode),
                ),
              ),
              Text(
                'Total nilai faktur: Rp ${_formatNumber(totalInvoiceValue)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt, size: 16, color: Colors.purple),
              SizedBox(width: 4),
              Text(
                '${_filteredTransactions.length} faktur',
                style: TextStyle(
                  color: Colors.purple,
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
                          'Cari ID pembelian, No. faktur, atau supplier...',
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
          Row(
            children: [
              Expanded(child: _buildSupplierFilter(isDarkMode)),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _clearFilters,
                icon: Icon(Icons.clear, size: 18),
                label: Text('Clear Filter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(width: 8),
              // Generate Invoice Report
              ElevatedButton.icon(
                onPressed: _generateInvoiceReport,
                icon: Icon(Icons.print, size: 18),
                label: Text('Laporan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierFilter(bool isDarkMode) {
    final uniqueSuppliers =
        _allTransactions.map((e) => e.supplierName).toSet().toList()..sort();

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

  Widget _buildTransactionTable(bool isDarkMode) {
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
                'Daftar Faktur Pembelian',
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
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Status: Faktur',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Showing ${_paginatedTransactions.length} of ${_filteredTransactions.length} records',
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
        columnSpacing: 16,
        headingRowColor: WidgetStateProperty.all(
          isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.withValues(alpha: 0.05),
        ),
        columns: [
          DataColumn(label: _buildColumnHeader('Tanggal', isDarkMode)),
          DataColumn(label: _buildColumnHeader('ID Pembelian', isDarkMode)),
          DataColumn(label: _buildColumnHeader('No Faktur', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Supplier', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Qty', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Subtotal', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Pajak', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Total', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Terbayar', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Sisa', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Due Date', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Aksi', isDarkMode)),
        ],
        rows: _paginatedTransactions.map((transaction) {
          return DataRow(
            cells: [
              // Tanggal
              DataCell(
                Text(
                  _formatDate(transaction.tanggal),
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontSize: 12,
                  ),
                ),
              ),
              // ID Pembelian
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    transaction.id,
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // No Faktur
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    transaction.noFaktur,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // Supplier
              DataCell(
                Text(
                  transaction.supplierName,
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Qty
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${transaction.totalQty}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // Sub Total
              DataCell(
                Text(
                  'Rp ${_formatNumber(transaction.subTotal)}',
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              // Pajak
              DataCell(
                Text(
                  'Rp ${_formatNumber(transaction.pajak)}',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              // Total
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Rp ${_formatNumber(transaction.total)}',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // Terbayar
              DataCell(
                Text(
                  'Rp ${_formatNumber(transaction.terbayar)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              // Sisa
              DataCell(
                Text(
                  'Rp ${_formatNumber(transaction.sisa)}',
                  style: TextStyle(
                    color: transaction.sisa > 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              // Due Date
              DataCell(
                Text(
                  transaction.dueDate != null
                      ? _formatDate(transaction.dueDate!)
                      : '-',
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontSize: 12,
                  ),
                ),
              ),
              // Detail Actions
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _viewInvoiceDetail(transaction),
                      icon: Icon(Icons.visibility, size: 16),
                      label: Text('Detail'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size(70, 28),
                        textStyle: TextStyle(fontSize: 10),
                      ),
                    ),
                    SizedBox(width: 4),
                    ElevatedButton.icon(
                      onPressed: () => _printInvoice(transaction),
                      icon: Icon(Icons.print, size: 16),
                      label: Text('Print'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size(70, 28),
                        textStyle: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
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
      itemCount: _paginatedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _paginatedTransactions[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.purple.withValues(alpha: 0.3),
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
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      transaction.id,
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'FAKTUR',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    _formatDate(transaction.tanggal),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                transaction.supplierName,
                style: TextStyle(
                  color: getTextColor(isDarkMode),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'No. Faktur: ${transaction.noFaktur}',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Payment Info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Faktur',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white60
                                      : Colors.black45,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                'Rp ${_formatNumber(transaction.total)}',
                                style: TextStyle(
                                  color: getTextColor(isDarkMode),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Qty: ${transaction.totalQty}',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Pajak: Rp ${_formatNumber(transaction.pajak)}',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Divider(height: 1),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Terbayar',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white60
                                      : Colors.black45,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                'Rp ${_formatNumber(transaction.terbayar)}',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Sisa',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white60
                                      : Colors.black45,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                'Rp ${_formatNumber(transaction.sisa)}',
                                style: TextStyle(
                                  color: transaction.sisa > 0
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewInvoiceDetail(transaction),
                      icon: Icon(Icons.visibility, size: 16),
                      label: Text('Detail'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _printInvoice(transaction),
                      icon: Icon(Icons.print, size: 16),
                      label: Text('Print'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
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
        fontSize: 13,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // Action methods
  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.file_download_outlined, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Export ${_filteredTransactions.length} data faktur berhasil!',
            ),
          ],
        ),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Download',
          textColor: Colors.white,
          onPressed: () {
            // Handle actual download
          },
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedSupplier = null;
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

  void _generateInvoiceReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.print, color: Colors.purple),
            SizedBox(width: 8),
            Text('Generate Laporan Faktur'),
          ],
        ),
        content: Text(
          'Generate laporan faktur untuk ${_filteredTransactions.length} transaksi?',
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
                      Text('Laporan faktur berhasil digenerate!'),
                    ],
                  ),
                  backgroundColor: Colors.purple,
                ),
              );
            },
            icon: Icon(Icons.print),
            label: Text('Generate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _viewInvoiceDetail(PurchaseTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.receipt_long, color: Colors.purple),
            SizedBox(width: 8),
            Text('Detail Faktur'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID Pembelian', transaction.id),
                _buildDetailRow('No. Faktur', transaction.noFaktur),
                _buildDetailRow('Supplier', transaction.supplierName),
                _buildDetailRow(
                  'Tanggal Faktur',
                  _formatDate(transaction.tanggal),
                ),
                _buildDetailRow('Status', 'Faktur Diterima', isStatus: true),
                if (transaction.dueDate != null)
                  _buildDetailRow(
                    'Jatuh Tempo',
                    _formatDate(transaction.dueDate!),
                  ),
                Divider(),
                _buildDetailRow('Total Qty', '${transaction.totalQty} items'),
                _buildDetailRow(
                  'Sub Total',
                  'Rp ${_formatNumber(transaction.subTotal)}',
                ),
                _buildDetailRow(
                  'Pajak (11%)',
                  'Rp ${_formatNumber(transaction.pajak)}',
                ),
                _buildDetailRow(
                  'Total Faktur',
                  'Rp ${_formatNumber(transaction.total)}',
                  isTotal: true,
                ),
                Divider(),
                _buildDetailRow(
                  'Terbayar',
                  'Rp ${_formatNumber(transaction.terbayar)}',
                  statusColor: Colors.green,
                ),
                _buildDetailRow(
                  'Outstanding',
                  'Rp ${_formatNumber(transaction.sisa)}',
                  statusColor: transaction.sisa > 0 ? Colors.red : Colors.green,
                ),
                if (transaction.notes != null) ...[
                  Divider(),
                  Text(
                    'Catatan:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(transaction.notes!),
                ],
                Divider(),
                Text(
                  'Info Item:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                ...transaction.items
                    .take(3)
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${item.productName} (${item.qty} ${item.satuan})',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                if (transaction.items.length > 3)
                  Text(
                    '... dan ${transaction.items.length - 3} item lainnya',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
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
              _printInvoice(transaction);
            },
            icon: Icon(Icons.print),
            label: Text('Print'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _processPayment(transaction);
            },
            icon: Icon(Icons.payment),
            label: Text('Bayar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
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
    bool isStatus = false,
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
                fontWeight: isTotal || isStatus || statusColor != null
                    ? FontWeight.bold
                    : FontWeight.normal,
                color:
                    statusColor ??
                    (isTotal
                        ? Colors.green
                        : isStatus
                        ? Colors.purple
                        : null),
                fontSize: isTotal ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _printInvoice(PurchaseTransaction transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.print, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('Print faktur ${transaction.noFaktur} berhasil!'),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Lihat',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to print preview
          },
        ),
      ),
    );
  }

  void _processPayment(PurchaseTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: Colors.green),
            SizedBox(width: 8),
            Text('Proses Pembayaran'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Faktur: ${transaction.noFaktur}'),
            Text('Supplier: ${transaction.supplierName}'),
            Text('Total: Rp ${_formatNumber(transaction.total)}'),
            Text('Terbayar: Rp ${_formatNumber(transaction.terbayar)}'),
            Text(
              'Outstanding: Rp ${_formatNumber(transaction.sisa)}',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Pembayaran ${transaction.noFaktur} berhasil diproses!',
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: Icon(Icons.payment),
            label: Text('Proses'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
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
