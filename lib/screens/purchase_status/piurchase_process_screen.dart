// lib/screens/purchase/purchase_process_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controllers/theme_controller.dart';
import '../../models/purchase_transaction_model.dart';
import '../../responsive.dart';

class PurchaseProcessScreen extends StatefulWidget {
  const PurchaseProcessScreen({super.key});

  @override
  State<PurchaseProcessScreen> createState() => _PurchaseProcessScreenState();
}

class _PurchaseProcessScreenState extends State<PurchaseProcessScreen> {
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
    // Generate sample data for "Di Proses" status only
    _allTransactions = generateSamplePurchaseTransactions(
      filterStatus: TransactionStatus.diproses,
      count: 28, // Slightly different count from Permintaan
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
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.hourglass_empty_outlined,
            size: 32,
            color: Colors.orange,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Pembelian Di Proses',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: getTextColor(isDarkMode),
                ),
              ),
              Text(
                'Daftar pembelian yang sedang dalam tahap proses',
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
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_empty, size: 16, color: Colors.orange),
              SizedBox(width: 4),
              Text(
                '${_filteredTransactions.length} dalam proses',
                style: TextStyle(
                  color: Colors.orange,
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
              // Quick Action - Approve All
              ElevatedButton.icon(
                onPressed: _approveSelected,
                icon: Icon(Icons.check_circle_outline, size: 18),
                label: Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
                'Daftar Pembelian Dalam Proses',
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
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Status: Dalam Proses',
                  style: TextStyle(
                    color: Colors.orange,
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
          DataColumn(label: _buildColumnHeader('Jumlah', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Sub Total', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Pajak (11%)', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Total', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Detail', isDarkMode)),
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
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    transaction.id,
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // No Faktur
              DataCell(
                Text(
                  transaction.noFaktur,
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontSize: 12,
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
              // Jumlah (Quantity)
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
              // Detail Actions
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _viewDetail(transaction),
                      icon: Icon(Icons.visibility, size: 16),
                      label: Text('Detail'),
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
                    SizedBox(width: 4),
                    ElevatedButton.icon(
                      onPressed: () => _downloadFile(transaction),
                      icon: Icon(Icons.download, size: 16),
                      label: Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size(80, 28),
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
              color: Colors.orange.withValues(alpha: 0.3),
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
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      transaction.id,
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'PROSES',
                      style: TextStyle(
                        color: Colors.orange,
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
              Text(
                'No. Faktur: ${transaction.noFaktur}',
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
                          'Qty: ${transaction.totalQty}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Sub Total: Rp ${_formatNumber(transaction.subTotal)}',
                          style: TextStyle(
                            color: getTextColor(isDarkMode),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Pajak: Rp ${_formatNumber(transaction.pajak)}',
                          style: TextStyle(color: Colors.red, fontSize: 12),
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
                        'Rp ${_formatNumber(transaction.total)}',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewDetail(transaction),
                      icon: Icon(Icons.visibility, size: 16),
                      label: Text('Detail'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadFile(transaction),
                      icon: Icon(Icons.download, size: 16),
                      label: Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
              'Export ${_filteredTransactions.length} data yang sedang diproses berhasil!',
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

  void _approveSelected() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Approve Pembelian'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin meng-approve ${_filteredTransactions.length} pembelian yang sedang diproses?',
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
                        '${_filteredTransactions.length} pembelian berhasil di-approve!',
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: Icon(Icons.check_circle),
            label: Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _viewDetail(PurchaseTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.visibility, color: Colors.orange),
            SizedBox(width: 8),
            Text('Detail Pembelian'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID Pembelian', transaction.id),
              _buildDetailRow('No. Faktur', transaction.noFaktur),
              _buildDetailRow('Supplier', transaction.supplierName),
              _buildDetailRow('Tanggal', _formatDate(transaction.tanggal)),
              _buildDetailRow('Status', 'Sedang Diproses', isStatus: true),
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
                'Total',
                'Rp ${_formatNumber(transaction.total)}',
                isTotal: true,
              ),
              if (transaction.notes != null) ...[
                Divider(),
                Text('Catatan:', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(transaction.notes!),
              ],
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
              _approveTransaction(transaction);
            },
            icon: Icon(Icons.check_circle),
            label: Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _downloadFile(transaction);
            },
            icon: Icon(Icons.download),
            label: Text('Download'),
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
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
                fontWeight: isTotal || isStatus
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isTotal
                    ? Colors.green
                    : isStatus
                    ? Colors.orange
                    : null,
                fontSize: isTotal ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _approveTransaction(PurchaseTransaction transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('Pembelian ${transaction.id} berhasil di-approve!'),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Lihat',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to approved transactions
          },
        ),
      ),
    );
  }

  void _downloadFile(PurchaseTransaction transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.download, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('Download file untuk ${transaction.id} berhasil!'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Buka',
          textColor: Colors.white,
          onPressed: () {
            // Handle opening downloaded file
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
