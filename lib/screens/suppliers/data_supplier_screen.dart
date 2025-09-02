import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controllers/theme_controller.dart';
import '../../models/supplier_model.dart';
import '../../responsive.dart';

class DataSupplierScreen extends StatefulWidget {
  const DataSupplierScreen({super.key});

  @override
  State<DataSupplierScreen> createState() => _DataSupplierScreenState();
}

class _DataSupplierScreenState extends State<DataSupplierScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample data suppliers Indonesia
  final List<Supplier> _suppliers = [
    Supplier(
      kode: 'SUP001',
      nama: 'PT Kimia Farma Trading & Distribution',
      alamat: 'Jl. Veteran No. 9, Jakarta Pusat 10110',
      email: 'trading@kimiafarma.co.id',
      contactPIC: 'Budi Santoso - 021-3847562',
      jenis: JenisSupplier.pbf,
      termin: 30,
      updated: DateTime.now().subtract(Duration(days: 2)),
    ),
    Supplier(
      kode: 'SUP002',
      nama: 'PT Kalbe Farma Tbk',
      alamat: 'Jl. Letjen. Suprapto Kav. 4, Jakarta Pusat 10510',
      email: 'info@kalbe.co.id',
      contactPIC: 'Siti Nurhaliza - 021-42873888',
      jenis: JenisSupplier.pabrik,
      termin: 45,
      updated: DateTime.now().subtract(Duration(days: 1)),
    ),
    Supplier(
      kode: 'SUP003',
      nama: 'PT Sanbe Farma',
      alamat: 'Jl. Raya Lembang No. 115, Lembang, Bandung 40391',
      email: 'contact@sanbe.co.id',
      contactPIC: 'Ahmad Wijaya - 022-2786234',
      jenis: JenisSupplier.pabrik,
      termin: 30,
      updated: DateTime.now().subtract(Duration(days: 3)),
    ),
    Supplier(
      kode: 'SUP004',
      nama: 'PT Pharos Indonesia',
      alamat: 'Jl. Raya Serpong KM 8, Tangerang, Banten 15310',
      email: 'info@pharos.co.id',
      contactPIC: 'Diana Puspa - 021-53162000',
      jenis: JenisSupplier.pabrik,
      termin: 21,
      updated: DateTime.now().subtract(Duration(days: 5)),
    ),
    Supplier(
      kode: 'SUP005',
      nama: 'PT Dexa Medica',
      alamat: 'Jl. Bambu Apus Raya No. 1-3, Jakarta Timur 13890',
      email: 'customercare@dexa-medica.com',
      contactPIC: 'Rudi Hermawan - 021-8690-7777',
      jenis: JenisSupplier.pabrik,
      termin: 30,
      updated: DateTime.now().subtract(Duration(hours: 12)),
    ),
    Supplier(
      kode: 'SUP006',
      nama: 'PT Combiphar',
      alamat: 'Jl. Raya Lenteng Agung No. 101, Jakarta Selatan 12610',
      email: 'info@combiphar.com',
      contactPIC: 'Maya Sari - 021-78840888',
      jenis: JenisSupplier.pabrik,
      termin: 14,
      updated: DateTime.now().subtract(Duration(days: 7)),
    ),
    Supplier(
      kode: 'SUP007',
      nama: 'PT Enseval Putera Megatrading',
      alamat: 'Gedung Enseval, Jl. Letjen S. Parman Kav. 53, Jakarta 11420',
      email: 'info@enseval.com',
      contactPIC: 'Andi Pratama - 021-53674000',
      jenis: JenisSupplier.pbf,
      termin: 30,
      updated: DateTime.now().subtract(Duration(days: 4)),
    ),
    Supplier(
      kode: 'SUP008',
      nama: 'PT Tempo Scan Pacific',
      alamat: 'Jl. HR. Rasuna Said Blok X-2 Kav. 11, Jakarta 12950',
      email: 'corporate@temposcanpacific.com',
      contactPIC: 'Lisa Anggraeni - 021-52921999',
      jenis: JenisSupplier.pabrik,
      termin: 30,
      updated: DateTime.now().subtract(Duration(days: 6)),
    ),
  ];

  List<Supplier> get _filteredSuppliers {
    if (_searchQuery.isEmpty) return _suppliers;
    return _suppliers.where((supplier) {
      return supplier.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          supplier.kode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          supplier.alamat.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
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
                _buildDataTable(themeController.isDarkMode),
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
        Icon(Icons.people_outline, size: 32, color: getTextColor(isDarkMode)),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Supplier',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: getTextColor(isDarkMode),
              ),
            ),
            Text(
              'Kelola informasi supplier dan distributor',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
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
          // Search Bar
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
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari supplier...',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                      filled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor, width: 2),
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
            ],
          ),
          SizedBox(height: defaultPadding),
          // Action Buttons
          Row(
            children: [
              _buildActionButton(
                isDarkMode,
                icon: Icons.add,
                label: 'Tambah Supplier',
                color: primaryColor,
                onPressed: () => _showAddSupplierDialog(),
              ),
              SizedBox(width: 12),
              _buildActionButton(
                isDarkMode,
                icon: Icons.file_download_outlined,
                label: 'Export',
                color: Colors.green,
                onPressed: () => _exportData(),
              ),
              Spacer(),
              Text(
                '${_filteredSuppliers.length} supplier ditemukan',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    bool isDarkMode, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDataTable(bool isDarkMode) {
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
            'Daftar Supplier',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: getTextColor(isDarkMode),
            ),
          ),
          SizedBox(height: defaultPadding),
          if (Responsive.isMobile(context))
            _buildMobileList(isDarkMode)
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
        columnSpacing: 20,
        headingRowColor: WidgetStateProperty.all(
          isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.withValues(alpha: 0.05),
        ),
        columns: [
          DataColumn(label: _buildColumnHeader('Kode', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Nama Supplier', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Jenis', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Contact PIC', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Termin', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Update', isDarkMode)),
          DataColumn(label: _buildColumnHeader('Aksi', isDarkMode)),
        ],
        rows: _filteredSuppliers.map((supplier) {
          return DataRow(
            cells: [
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    supplier.kode,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      supplier.nama,
                      style: TextStyle(
                        color: getTextColor(isDarkMode),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      supplier.alamat,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getJenisColor(
                      supplier.jenis,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getJenisText(supplier.jenis),
                    style: TextStyle(
                      color: _getJenisColor(supplier.jenis),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  supplier.contactPIC,
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontSize: 12,
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${supplier.termin} hari',
                  style: TextStyle(
                    color: getTextColor(isDarkMode),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataCell(
                Text(
                  _formatDateTime(supplier.updated),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.visibility_outlined, size: 18),
                      onPressed: () => _viewSupplier(supplier),
                      color: Colors.blue,
                      tooltip: 'Detail',
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => _editSupplier(supplier),
                      color: Colors.orange,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 18),
                      onPressed: () => _deleteSupplier(supplier),
                      color: Colors.red,
                      tooltip: 'Hapus',
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

  Widget _buildMobileList(bool isDarkMode) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _filteredSuppliers.length,
      itemBuilder: (context, index) {
        final supplier = _filteredSuppliers[index];
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
                      supplier.kode,
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
                      color: _getJenisColor(
                        supplier.jenis,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getJenisText(supplier.jenis),
                      style: TextStyle(
                        color: _getJenisColor(supplier.jenis),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                supplier.nama,
                style: TextStyle(
                  color: getTextColor(isDarkMode),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                supplier.alamat,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Termin: ${supplier.termin} hari',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  Spacer(),
                  Text(
                    _formatDateTime(supplier.updated),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white60 : Colors.black45,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewSupplier(supplier),
                      icon: Icon(Icons.visibility_outlined, size: 16),
                      label: Text('Detail'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editSupplier(supplier),
                      icon: Icon(Icons.edit_outlined, size: 16),
                      label: Text('Edit'),
                      style: OutlinedButton.styleFrom(
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

  Color _getJenisColor(JenisSupplier jenis) {
    switch (jenis) {
      case JenisSupplier.pabrik:
        return Colors.blue;
      case JenisSupplier.pbf:
        return Colors.green;
      case JenisSupplier.lainnya:
        return Colors.orange;
    }
  }

  String _getJenisText(JenisSupplier jenis) {
    switch (jenis) {
      case JenisSupplier.pabrik:
        return 'Pabrik';
      case JenisSupplier.pbf:
        return 'PBF';
      case JenisSupplier.lainnya:
        return 'Lainnya';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Supplier'),
        content: Text('Form tambah supplier akan dibuat di sini'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export data supplier berhasil!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewSupplier(Supplier supplier) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Lihat detail ${supplier.nama}')));
  }

  void _editSupplier(Supplier supplier) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit ${supplier.nama}')));
  }

  void _deleteSupplier(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Supplier'),
        content: Text('Yakin ingin menghapus ${supplier.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _suppliers.remove(supplier);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${supplier.nama} berhasil dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus'),
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
