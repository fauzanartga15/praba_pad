import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controllers/theme_controller.dart';
import '../../models/pricelist_model.dart';
import '../../models/purchase_order_model.dart';
import '../../responsive.dart';

class CreatePurchaseScreen extends StatefulWidget {
  const CreatePurchaseScreen({super.key});

  @override
  State<CreatePurchaseScreen> createState() => _CreatePurchaseScreenState();
}

class _CreatePurchaseScreenState extends State<CreatePurchaseScreen> {
  // Controllers
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Form Data
  ProductFormData _formData = ProductFormData();
  final List<PurchaseOrderItem> _cartItems = [];

  // Data
  List<PricelistItem> _pricelistData = [];
  List<Product> _products = [];
  List<String> _suppliers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load sample data
    _pricelistData = generateSamplePricelist();
    _products = sampleProducts;
    _suppliers = supplierNames;
  }

  void _onProductChanged(String? productId) {
    if (productId == null) return;

    setState(() {
      _formData = _formData.copyWith(selectedProductId: productId);
      _updateProductData();
    });
  }

  void _onSupplierChanged(String? supplierName) {
    if (supplierName == null) return;

    setState(() {
      _formData = _formData.copyWith(selectedSupplierId: supplierName);
      _updateProductData();
    });
  }

  void _updateProductData() {
    if (_formData.selectedProductId == null ||
        _formData.selectedSupplierId == null) {
      return;
    }

    // Find matching pricelist item
    final pricelistItem = _pricelistData.firstWhere(
      (item) =>
          item.productId == _formData.selectedProductId &&
          item.supplierName == _formData.selectedSupplierId,
      orElse: () => _pricelistData.first,
    );

    // Find product info
    final product = _products.firstWhere(
      (p) => p.id == _formData.selectedProductId,
      orElse: () => _products.first,
    );

    setState(() {
      _formData = _formData.copyWith(
        stokSaatIni: pricelistItem.stok,
        hargaRataRata: pricelistItem.averagePrice,
        hargaTerakhir: pricelistItem.hargaAktual,
        satuan: product.satuan,
      );
    });
  }

  void _addToCart() {
    if (!_formData.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final product = _products.firstWhere(
      (p) => p.id == _formData.selectedProductId,
    );

    final newItem = PurchaseOrderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: _formData.selectedProductId!,
      productName: product.nama,
      sku: product.sku,
      satuan: _formData.satuan,
      hargaSatuan: _formData.hargaTerakhir,
      jumlah: _formData.jumlah,
      keterangan: _formData.keterangan.isEmpty ? null : _formData.keterangan,
      createdAt: DateTime.now(),
    );

    setState(() {
      _cartItems.add(newItem);
      _clearForm();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.nama} added to cart'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearForm() {
    _jumlahController.clear();
    _keteranganController.clear();
    setState(() {
      _formData = ProductFormData(
        selectedProductId: _formData.selectedProductId,
        selectedSupplierId: _formData.selectedSupplierId,
      );
      _updateProductData();
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item removed from cart'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _submitPurchaseOrder() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart is empty'), backgroundColor: Colors.red),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.shopping_cart_checkout, color: primaryColor),
            SizedBox(width: 8),
            Text('Confirm Purchase Order'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Supplier: ${_formData.selectedSupplierId}'),
            SizedBox(height: 8),
            Text('Total Items: ${_cartItems.length} products'),
            Text(
              'Total Quantity: ${_cartItems.fold(0, (sum, item) => sum + item.jumlah)} units',
            ),
            SizedBox(height: 8),
            Text(
              'Grand Total: Rp ${_formatNumber(_cartItems.fold(0.0, (sum, item) => sum + item.totalHarga))}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPurchaseOrder();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Submit Order'),
          ),
        ],
      ),
    );
  }

  void _processPurchaseOrder() {
    // Process the purchase order
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Purchase Order submitted successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Clear everything
    setState(() {
      _cartItems.clear();
      _formData = ProductFormData();
      _jumlahController.clear();
      _keteranganController.clear();
      _notesController.clear();
    });
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
                if (Responsive.isMobile(context))
                  _buildMobileLayout(themeController.isDarkMode)
                else
                  _buildDesktopLayout(themeController.isDarkMode),
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
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.add_shopping_cart_outlined,
            size: 32,
            color: Colors.green,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Purchase Order',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: getTextColor(isDarkMode),
                ),
              ),
              Text(
                'Add products to create new purchase order',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        if (_cartItems.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_cartItems.length} items in cart',
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

  Widget _buildMobileLayout(bool isDarkMode) {
    return Column(
      children: [
        _buildLeftPanel(isDarkMode),
        SizedBox(height: defaultPadding),
        _buildRightPanel(isDarkMode),
      ],
    );
  }

  Widget _buildDesktopLayout(bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: _buildLeftPanel(isDarkMode)),
        SizedBox(width: defaultPadding),
        Expanded(flex: 1, child: _buildRightPanel(isDarkMode)),
      ],
    );
  }

  Widget _buildLeftPanel(bool isDarkMode) {
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
              Icon(Icons.inventory_2_outlined, color: primaryColor),
              SizedBox(width: 8),
              Text(
                'Product Selection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: getTextColor(isDarkMode),
                ),
              ),
            ],
          ),
          SizedBox(height: defaultPadding),

          // Product Dropdown
          _buildDropdown(
            label: 'Select Product *',
            value: _formData.selectedProductId,
            items: _products
                .map(
                  (product) => DropdownMenuItem<String>(
                    value: product.id,
                    child: Text(
                      '${product.nama} (${product.sku})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: _onProductChanged,
            isDarkMode: isDarkMode,
            hint: 'Choose a product...',
          ),

          SizedBox(height: 16),

          // Supplier Dropdown
          _buildDropdown(
            label: 'Select Supplier *',
            value: _formData.selectedSupplierId,
            items: _suppliers
                .map(
                  (supplier) => DropdownMenuItem<String>(
                    value: supplier,
                    child: Text(supplier, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: _onSupplierChanged,
            isDarkMode: isDarkMode,
            hint: 'Choose a supplier...',
          ),

          SizedBox(height: 20),

          // Product Info (Read-only)
          _buildInfoCard(isDarkMode),

          SizedBox(height: 20),

          // Quantity Input
          _buildQuantityInput(isDarkMode),

          SizedBox(height: 16),

          // Notes Input
          _buildNotesInput(isDarkMode),

          SizedBox(height: 20),

          // Add to Cart Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _formData.isValid ? _addToCart : null,
              icon: Icon(Icons.add_shopping_cart),
              label: Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: _formData.isValid ? 2 : 0,
              ),
            ),
          ),

          // Quick Clear Form
          if (_formData.selectedProductId != null ||
              _formData.selectedSupplierId != null)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _formData = ProductFormData();
                    _jumlahController.clear();
                    _keteranganController.clear();
                  });
                },
                icon: Icon(Icons.refresh, size: 18),
                label: Text('Reset Form'),
                style: TextButton.styleFrom(foregroundColor: Colors.orange),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(bool isDarkMode) {
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
          _buildSupplierHeader(isDarkMode),
          SizedBox(height: defaultPadding),
          _buildCartItems(isDarkMode),
          if (_cartItems.isNotEmpty) ...[
            SizedBox(height: defaultPadding),
            _buildCartSummary(isDarkMode),
            SizedBox(height: defaultPadding),
            _buildPurchaseActions(isDarkMode),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required bool isDarkMode,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: getTextColor(isDarkMode),
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: isDarkMode
                ? getSecondaryColor(true)
                : Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: hint,
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down),
        ),
      ],
    );
  }

  Widget _buildInfoCard(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: getBorderColor(isDarkMode)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: primaryColor),
              SizedBox(width: 8),
              Text(
                'Product Information',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: getTextColor(isDarkMode),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            'Current Stock',
            '${_formData.stokSaatIni} ${_formData.satuan}',
            isDarkMode,
            icon: Icons.inventory_2_outlined,
            color: _formData.stokSaatIni > 50
                ? Colors.green
                : _formData.stokSaatIni > 20
                ? Colors.orange
                : Colors.red,
          ),
          Divider(height: 16),
          _buildInfoRow(
            'Average Price',
            'Rp ${_formatNumber(_formData.hargaRataRata)}',
            isDarkMode,
            icon: Icons.show_chart,
            color: Colors.blue,
          ),
          Divider(height: 16),
          _buildInfoRow(
            'Last Purchase Price',
            'Rp ${_formatNumber(_formData.hargaTerakhir)}',
            isDarkMode,
            icon: Icons.price_check,
            color: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    bool isDarkMode, {
    IconData? icon,
    Color? color,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: color ?? getTextColor(isDarkMode)),
          SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? getTextColor(isDarkMode),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityInput(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity *',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: getTextColor(isDarkMode),
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    _formData = _formData.copyWith(
                      jumlah: int.tryParse(value) ?? 0,
                    );
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? getSecondaryColor(true)
                      : Colors.grey.shade50,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  hintText: '0',
                  prefixIcon: Icon(Icons.add_circle_outline),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: getBorderColor(isDarkMode)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _formData.satuan.isEmpty ? 'Unit' : _formData.satuan,
                      style: TextStyle(
                        color: getTextColor(isDarkMode),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_formData.jumlah > 0 && _formData.hargaTerakhir > 0)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Subtotal: Rp ${_formatNumber(_formData.jumlah * _formData.hargaTerakhir)}',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotesInput(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item Notes (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: getTextColor(isDarkMode),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _keteranganController,
          maxLines: 2,
          onChanged: (value) {
            setState(() {
              _formData = _formData.copyWith(keterangan: value);
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: isDarkMode
                ? getSecondaryColor(true)
                : Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: 'Add notes for this item...',
            prefixIcon: Icon(Icons.note_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierHeader(bool isDarkMode) {
    final supplierName = _formData.selectedSupplierId ?? 'No Supplier Selected';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.business, color: primaryColor, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplierName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: getTextColor(isDarkMode),
                  ),
                ),
                SizedBox(height: 4),
                if (supplierName != 'No Supplier Selected')
                  Text(
                    'JL. PRABU GAJAH AGUNG NO.22 SUMEDANG',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  )
                else
                  Text(
                    'Please select a supplier first',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          if (supplierName != 'No Supplier Selected')
            Icon(Icons.verified, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildCartItems(bool isDarkMode) {
    if (_cartItems.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: isDarkMode ? Colors.white30 : Colors.black26,
            ),
            SizedBox(height: 16),
            Text(
              'Cart is empty',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white54 : Colors.black45,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add products to start creating purchase order',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white38 : Colors.black38,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shopping_cart, color: primaryColor, size: 18),
            SizedBox(width: 8),
            Text(
              'Cart Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: getTextColor(isDarkMode),
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_cartItems.length} items',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _cartItems.length,
          itemBuilder: (context, index) {
            final item = _cartItems[index];
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: getBorderColor(isDarkMode)),
              ),
              child: Row(
                children: [
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.sku,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.productName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: getTextColor(isDarkMode),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 14,
                              color: isDarkMode
                                  ? Colors.white60
                                  : Colors.black54,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${item.jumlah} ${item.satuan}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(
                              Icons.price_change_outlined,
                              size: 14,
                              color: isDarkMode
                                  ? Colors.white60
                                  : Colors.black54,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Rp ${_formatNumber(item.hargaSatuan)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        if (item.keterangan != null) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.note,
                                size: 12,
                                color: isDarkMode
                                    ? Colors.white54
                                    : Colors.black45,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.keterangan!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: isDarkMode
                                        ? Colors.white60
                                        : Colors.black45,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Price & Actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${_formatNumber(item.totalHarga)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _removeFromCart(index),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCartSummary(bool isDarkMode) {
    final grandTotal = _cartItems.fold(
      0.0,
      (sum, item) => sum + item.totalHarga,
    );
    final totalItems = _cartItems.fold(0, (sum, item) => sum + item.jumlah);
    final uniqueProducts = _cartItems.length;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? primaryColor.withValues(alpha: 0.1)
            : primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: primaryColor, size: 18),
              SizedBox(width: 8),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: getTextColor(isDarkMode),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildSummaryRow(
            'Unique Products',
            '$uniqueProducts products',
            isDarkMode,
          ),
          SizedBox(height: 8),
          _buildSummaryRow('Total Quantity', '$totalItems units', isDarkMode),
          Divider(height: 20, color: primaryColor.withValues(alpha: 0.3)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: TextStyle(
                  color: getTextColor(isDarkMode),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rp ${_formatNumber(grandTotal)}',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: getTextColor(isDarkMode),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseActions(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'General Notes (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: getTextColor(isDarkMode),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: isDarkMode
                ? getSecondaryColor(true)
                : Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            hintText: 'Add general notes for this purchase order...',
            prefixIcon: Icon(Icons.description_outlined),
          ),
        ),
        SizedBox(height: 20),

        // Action Buttons
        Row(
          children: [
            // Clear Cart Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _cartItems.isNotEmpty
                    ? () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Clear Cart'),
                            content: Text(
                              'Are you sure you want to clear all items from the cart?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _cartItems.clear();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Cart cleared successfully',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: Text('Clear All'),
                              ),
                            ],
                          ),
                        );
                      }
                    : null,
                icon: Icon(Icons.clear_all),
                label: Text('Clear Cart'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.orange),
                  foregroundColor: Colors.orange,
                ),
              ),
            ),
            SizedBox(width: 12),

            // Submit Purchase Order Button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _cartItems.isNotEmpty ? _submitPurchaseOrder : null,
                icon: Icon(Icons.shopping_cart_checkout),
                label: Text('Submit Purchase Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: _cartItems.isNotEmpty ? 2 : 0,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12),

        // Save as Draft Button
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _cartItems.isNotEmpty
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.save_outlined, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Purchase order saved as draft'),
                          ],
                        ),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                : null,
            icon: Icon(Icons.save_outlined),
            label: Text('Save as Draft'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
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

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
