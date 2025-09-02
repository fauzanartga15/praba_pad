import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controllers/theme_controller.dart';
import '../../models/pricelist_model.dart';
import '../../responsive.dart';

class PricelistScreen extends StatefulWidget {
  const PricelistScreen({super.key});

  @override
  State<PricelistScreen> createState() => _PricelistScreenState();
}

class _PricelistScreenState extends State<PricelistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedProduct;
  String? _selectedSupplier;
  int _rowsPerPage = 10;
  int _currentPage = 0;

  // Data
  List<PricelistItem> _allPricelist = [];
  final List<int> _rowOptions = [10, 20, 50, 100, 500, 1000]; // Changed to int

  @override
  void initState() {
    super.initState();
    _allPricelist = generateSamplePricelist();
  }

  List<PricelistItem> get _filteredPricelist {
    List<PricelistItem> filtered = _allPricelist;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.productName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            item.supplierName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            item.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply product filter
    if (_selectedProduct != null) {
      filtered = filtered
          .where((item) => item.productName == _selectedProduct)
          .toList();
    }

    // Apply supplier filter
    if (_selectedSupplier != null) {
      filtered = filtered
          .where((item) => item.supplierName == _selectedSupplier)
          .toList();
    }

    return filtered;
  }

  List<PricelistItem> get _paginatedPricelist {
    final filtered = _filteredPricelist;
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filtered.length);

    return filtered.sublist(startIndex, endIndex);
  }

  int get _totalPages => _filteredPricelist.isEmpty
      ? 1
      : (_filteredPricelist.length / _rowsPerPage).ceil();

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
                _buildFilters(themeController.isDarkMode),
                SizedBox(height: defaultPadding),
                _buildActionBar(themeController.isDarkMode),
                SizedBox(height: defaultPadding),
                _buildPricelistTable(themeController.isDarkMode),
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
            Icons.price_check_outlined,
            size: 32,
            color: Colors.orange,
          ),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricelist',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: getTextColor(isDarkMode),
              ),
            ),
            Text(
              'Kelola harga dan daftar produk supplier',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_filteredPricelist.length} items',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(bool isDarkMode) {
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
            'Filter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: getTextColor(isDarkMode),
            ),
          ),
          SizedBox(height: defaultPadding),
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
        Expanded(flex: 2, child: _buildProductDropdown(isDarkMode)),
        SizedBox(width: 12),
        Expanded(flex: 2, child: _buildSupplierDropdown(isDarkMode)),
        SizedBox(width: 12),
        _buildFilterButton(),
        SizedBox(width: 8),
        _buildClearFilterButton(isDarkMode),
      ],
    );
  }

  Widget _buildMobileFilters(bool isDarkMode) {
    return Column(
      children: [
        _buildProductDropdown(isDarkMode),
        SizedBox(height: 12),
        _buildSupplierDropdown(isDarkMode),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildFilterButton()),
            SizedBox(width: 8),
            Expanded(child: _buildClearFilterButton(isDarkMode)),
          ],
        ),
      ],
    );
  }

  Widget _buildProductDropdown(bool isDarkMode) {
    final uniqueProducts =
        _allPricelist.map((e) => e.productName).toSet().toList()..sort();

    return DropdownButtonFormField<String>(
      initialValue: _selectedProduct,
      decoration: InputDecoration(
        labelText: 'Pilih Barang',
        prefixIcon: Icon(Icons.inventory_2_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: isDarkMode ? getSecondaryColor(true) : Colors.grey.shade50,
      ),
      items: [
        DropdownMenuItem<String>(value: null, child: Text('Semua Barang')),
        ...uniqueProducts.map(
          (product) => DropdownMenuItem<String>(
            value: product,
            child: Text(product, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedProduct = value;
          _currentPage = 0;
        });
      },
      isExpanded: true,
    );
  }

  Widget _buildSupplierDropdown(bool isDarkMode) {
    final uniqueSuppliers =
        _allPricelist.map((e) => e.supplierName).toSet().toList()..sort();

    return DropdownButtonFormField<String>(
      initialValue: _selectedSupplier,
      decoration: InputDecoration(
        labelText: 'Pilih Supplier',
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

  Widget _buildFilterButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Filter button pressed (already filtered automatically)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Filter diterapkan: ${_filteredPricelist.length} hasil',
            ),
            backgroundColor: Colors.green,
          ),
        );
      },
      icon: Icon(Icons.filter_list, size: 18),
      label: Text('Filter'),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Widget _buildClearFilterButton(bool isDarkMode) {
    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _selectedProduct = null;
          _selectedSupplier = null;
          _searchQuery = '';
          _searchController.clear();
          _currentPage = 0;
        });
      },
      icon: Icon(Icons.clear, size: 18),
      label: Text('Clear'),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        side: BorderSide(color: Colors.orange),
        foregroundColor: Colors.orange,
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
      child: Row(
        children: [
          // Search
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
                  hintText: 'Cari produk, supplier, atau SKU...',
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
          // Add Button
          ElevatedButton.icon(
            onPressed: _showAddPriceDialog,
            icon: Icon(Icons.add, size: 18),
            label: Text('Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SizedBox(width: 8),
          // Export Button
          ElevatedButton.icon(
            onPressed: _exportPricelist,
            icon: Icon(Icons.file_download_outlined, size: 18),
            label: Text('Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricelistTable(bool isDarkMode) {
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
                'Daftar Harga',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: getTextColor(isDarkMode),
                ),
              ),
              Spacer(),
              Text(
                'Showing ${_paginatedPricelist.length} of ${_filteredPricelist.length} records',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: defaultPadding),
          if (Responsive.isMobile(context))
            _buildMobilePriceCards(isDarkMode)
          else
            _buildDesktopPriceTable(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildDesktopPriceTable(bool isDarkMode) {
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
          DataColumn(label: _buildColumnHeader('ID', isDarkMode)),
          DataColumn(label: _buildColumnHeader('SKU', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Produk', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Supplier', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Satuan', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Rata-rata', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Stok', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Harga Min', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Harga Max', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Harga Aktual', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Aksi', isDarkMode)),
        ],
        rows: _paginatedPricelist.map((item) {
          return DataRow(
            cells: [
              // 1. ID
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.id,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ),
              // 2. SKU
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.sku,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // 3. Produk
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.productName,
                      style: TextStyle(
                        color: getTextColor(isDarkMode),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 4. Supplier
              DataCell(
                Text(
                  item.supplierName,
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 5. Satuan
              DataCell(
                Text(
                  item.satuan,
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontSize: 12,
                  ),
                ),
              ),
              // 6. Rata-rata
              DataCell(
                Text(
                  '${item.penjualanRataRata.toStringAsFixed(1)}/bulan',
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontSize: 12,
                  ),
                ),
              ),
              // 7. Stok
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStokColor(item.stok).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${item.stok}',
                    style: TextStyle(
                      color: _getStokColor(item.stok),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // 8. Harga Min
              DataCell(
                Text(
                  'Rp ${_formatNumber(item.hargaTermurah)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              // 9. Harga Max
              DataCell(
                Text(
                  'Rp ${_formatNumber(item.hargaTertinggi)}',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              // 10. Harga Aktual
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Rp ${_formatNumber(item.hargaAktual)}',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // 11. Aksi
              DataCell(
                ElevatedButton.icon(
                  onPressed: () => _beliProduk(item),
                  icon: Icon(Icons.shopping_cart, size: 16),
                  label: Text('Beli'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size(80, 32),
                    textStyle: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobilePriceCards(bool isDarkMode) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _paginatedPricelist.length,
      itemBuilder: (context, index) {
        final item = _paginatedPricelist[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: getBorderColor(isDarkMode)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.sku,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStokColor(item.stok).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Stok: ${item.stok}',
                      style: TextStyle(
                        color: _getStokColor(item.stok),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                item.productName,
                style: TextStyle(
                  color: getTextColor(isDarkMode),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                item.supplierName,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Harga Aktual',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDarkMode ? Colors.white60 : Colors.black45,
                          ),
                        ),
                        Text(
                          'Rp ${_formatNumber(item.hargaAktual)}',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _beliProduk(item),
                    icon: Icon(Icons.shopping_cart, size: 16),
                    label: Text('Beli'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      textStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Harga Minimum',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDarkMode ? Colors.white60 : Colors.black45,
                          ),
                        ),
                        Text(
                          'Rp ${_formatNumber(item.hargaTermurah)}',
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
                          'Harga Maksimum',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDarkMode ? Colors.white60 : Colors.black45,
                          ),
                        ),
                        Text(
                          'Rp ${_formatNumber(item.hargaTertinggi)}',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 12,
                    color: isDarkMode ? Colors.white60 : Colors.black45,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Update: ${_formatDateTime(item.terakhirUpdate)}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white60 : Colors.black45,
                      fontSize: 10,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${item.penjualanRataRata.toStringAsFixed(1)}/bln',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  void _beliProduk(PricelistItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Beli Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk: ${item.productName}'),
            Text('Supplier: ${item.supplierName}'),
            Text('Harga: Rp ${_formatNumber(item.hargaAktual)}'),
            Text('Stok Tersedia: ${item.stok} ${item.satuan}'),
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
                  content: Text(
                    '${item.productName} ditambahkan ke keranjang!',
                  ),
                  backgroundColor: Colors.green,
                  action: SnackBarAction(
                    label: 'Lihat',
                    textColor: Colors.white,
                    onPressed: () {
                      // Navigate to cart
                    },
                  ),
                ),
              );
            },
            icon: Icon(Icons.add_shopping_cart),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            label: Text('Tambah ke Keranjang'),
          ),
        ],
      ),
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

  Color _getStokColor(int stok) {
    if (stok > 100) return Colors.green;
    if (stok > 20) return Colors.orange;
    return Colors.red;
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showAddPriceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Harga'),
        content: Text('Form tambah harga akan dibuat di sini'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Harga berhasil ditambahkan!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _exportPricelist() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Export pricelist berhasil! ${_filteredPricelist.length} items',
        ),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'Download',
          textColor: Colors.white,
          onPressed: () {
            // Handle download
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
