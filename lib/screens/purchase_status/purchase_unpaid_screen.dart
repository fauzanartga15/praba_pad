// lib/screens/purchase/purchase_unpaid_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controllers/theme_controller.dart';
import '../../models/purchase_transaction_model.dart';
import '../../responsive.dart';

class PurchaseUnpaidScreen extends StatefulWidget {
  const PurchaseUnpaidScreen({super.key});

  @override
  State<PurchaseUnpaidScreen> createState() => _PurchaseUnpaidScreenState();
}

class _PurchaseUnpaidScreenState extends State<PurchaseUnpaidScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _rowsPerPage = 10;
  int _currentPage = 0;
  String? _selectedSupplier;

  List<PurchaseTransaction> _allTransactions = [];
  final List<int> _rowOptions = [10, 20, 50, 100];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Generate mixed status and filter only unpaid ones
    final allTransactions = generateSamplePurchaseTransactions(count: 30);
    _allTransactions = allTransactions.where((t) => t.sisa > 0).toList();
  }

  List<PurchaseTransaction> get _filteredTransactions {
    List<PurchaseTransaction> filtered = _allTransactions;

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

  bool _isOverdue(PurchaseTransaction transaction) {
    if (transaction.dueDate == null) return false;
    return DateTime.now().isAfter(transaction.dueDate!) && transaction.sisa > 0;
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
    final totalUnpaid = _allTransactions.fold(0.0, (sum, t) => sum + t.sisa);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.payment_outlined, size: 32, color: Colors.red),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Pembelian Belum Lunas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: getTextColor(isDarkMode),
                ),
              ),
              Text(
                'Total outstanding: Rp ${_formatNumber(totalUnpaid)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, size: 16, color: Colors.red),
              SizedBox(width: 4),
              Text(
                '${_filteredTransactions.length} belum lunas',
                style: TextStyle(
                  color: Colors.red,
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _currentPage = 0;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari ID pembelian, No. faktur, atau supplier...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDarkMode
                        ? getSecondaryColor(true)
                        : Colors.grey.shade100,
                  ),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _exportData(),
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
          Row(
            children: [
              Expanded(child: _buildSupplierFilter(isDarkMode)),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedSupplier = null;
                    _searchQuery = '';
                    _searchController.clear();
                    _currentPage = 0;
                  });
                },
                icon: Icon(Icons.clear, size: 18),
                label: Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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
          Text(
            'Daftar Pembelian Belum Lunas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: getTextColor(isDarkMode),
            ),
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
        columns: [
          DataColumn(
            label: Text(
              'Tanggal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'ID Pembelian',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'No Faktur',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Supplier',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text('Qty', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text(
              'Subtotal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text('Pajak', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text('Total', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text(
              'Terbayar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text('Sisa', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text(
              'Tanggal Penerima',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Detail',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        rows: _paginatedTransactions.map((transaction) {
          return DataRow(
            color: _isOverdue(transaction)
                ? WidgetStateProperty.all(Colors.red.withValues(alpha: 0.1))
                : null,
            cells: [
              DataCell(Text(_formatDate(transaction.tanggal))),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    transaction.id,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(Text(transaction.noFaktur)),
              DataCell(
                Text(transaction.supplierName, overflow: TextOverflow.ellipsis),
              ),
              DataCell(Text('${transaction.totalQty}')),
              DataCell(Text('Rp ${_formatNumber(transaction.subTotal)}')),
              DataCell(Text('Rp ${_formatNumber(transaction.pajak)}')),
              DataCell(Text('Rp ${_formatNumber(transaction.total)}')),
              DataCell(
                Text(
                  'Rp ${_formatNumber(transaction.terbayar)}',
                  style: TextStyle(color: Colors.green),
                ),
              ),
              DataCell(
                Text(
                  'Rp ${_formatNumber(transaction.sisa)}',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                Text(
                  transaction.tanggalPenerima != null
                      ? _formatDate(transaction.tanggalPenerima!)
                      : '-',
                ),
              ),
              DataCell(
                ElevatedButton(
                  onPressed: () => _viewDetail(transaction),
                  child: Text('Detail'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      itemCount: _paginatedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _paginatedTransactions[index];
        final isOverdue = _isOverdue(transaction);

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOverdue ? Colors.red : Colors.red.withValues(alpha: 0.3),
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
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      transaction.id,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isOverdue) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'OVERDUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  Spacer(),
                  Text(_formatDate(transaction.tanggal)),
                ],
              ),
              SizedBox(height: 8),
              Text(
                transaction.supplierName,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text('No. Faktur: ${transaction.noFaktur}'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total: Rp ${_formatNumber(transaction.total)}'),
                        Text('Qty: ${transaction.totalQty}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terbayar: Rp ${_formatNumber(transaction.terbayar)}',
                          style: TextStyle(color: Colors.green),
                        ),
                        Text(
                          'Sisa: Rp ${_formatNumber(transaction.sisa)}',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _viewDetail(transaction),
                  child: Text('Lihat Detail'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
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
      ),
      child: Row(
        children: [
          Text(
            'Rows per page:',
            style: TextStyle(color: getTextColor(isDarkMode)),
          ),
          SizedBox(width: 8),
          DropdownButton<int>(
            value: _rowsPerPage,
            items: _rowOptions
                .map(
                  (rows) =>
                      DropdownMenuItem<int>(value: rows, child: Text('$rows')),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _rowsPerPage = value!;
                _currentPage = 0;
              });
            },
            underline: SizedBox.shrink(),
          ),
          Spacer(),
          Text(
            'Page ${_currentPage + 1} of ${_totalPages}',
            style: TextStyle(color: getTextColor(isDarkMode)),
          ),
          SizedBox(width: 16),
          IconButton(
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
            icon: Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: _currentPage < _totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
            icon: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000000)
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Export ${_filteredTransactions.length} data belum lunas berhasil!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewDetail(PurchaseTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Pembelian Belum Lunas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${transaction.id}'),
            Text('Supplier: ${transaction.supplierName}'),
            Text('Total: Rp ${_formatNumber(transaction.total)}'),
            Text('Terbayar: Rp ${_formatNumber(transaction.terbayar)}'),
            Text(
              'Sisa: Rp ${_formatNumber(transaction.sisa)}',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            if (_isOverdue(transaction))
              Text(
                'STATUS: OVERDUE',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
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
