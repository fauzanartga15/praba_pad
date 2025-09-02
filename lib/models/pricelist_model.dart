class Product {
  final String id;
  final String sku;
  final String nama;
  final String kategori;
  final String satuan;

  Product({
    required this.id,
    required this.sku,
    required this.nama,
    required this.kategori,
    required this.satuan,
  });
}

class PricelistItem {
  final String id;
  final String productId;
  final String supplierId;
  final String productName;
  final String supplierName;
  final String sku;
  final String satuan;
  final double penjualanRataRata;
  final int stok;
  final double hargaTermurah;
  final double hargaTertinggi;
  final double hargaAktual;
  final DateTime terakhirUpdate;

  PricelistItem({
    required this.id,
    required this.productId,
    required this.supplierId,
    required this.productName,
    required this.supplierName,
    required this.sku,
    required this.satuan,
    required this.penjualanRataRata,
    required this.stok,
    required this.hargaTermurah,
    required this.hargaTertinggi,
    required this.hargaAktual,
    required this.terakhirUpdate,
  });

  double get averagePrice => (hargaTermurah + hargaTertinggi) / 2;

  String get statusStok {
    if (stok > 100) return 'Tersedia';
    if (stok > 20) return 'Terbatas';
    return 'Habis';
  }

  PricelistItem copyWith({
    String? id,
    String? productId,
    String? supplierId,
    String? productName,
    String? supplierName,
    String? sku,
    String? satuan,
    double? penjualanRataRata,
    int? stok,
    double? hargaTermurah,
    double? hargaTertinggi,
    double? hargaAktual,
    DateTime? terakhirUpdate,
  }) {
    return PricelistItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      supplierId: supplierId ?? this.supplierId,
      productName: productName ?? this.productName,
      supplierName: supplierName ?? this.supplierName,
      sku: sku ?? this.sku,
      satuan: satuan ?? this.satuan,
      penjualanRataRata: penjualanRataRata ?? this.penjualanRataRata,
      stok: stok ?? this.stok,
      hargaTermurah: hargaTermurah ?? this.hargaTermurah,
      hargaTertinggi: hargaTertinggi ?? this.hargaTertinggi,
      hargaAktual: hargaAktual ?? this.hargaAktual,
      terakhirUpdate: terakhirUpdate ?? this.terakhirUpdate,
    );
  }
}

// Sample data obat-obatan Indonesia
final List<Product> sampleProducts = [
  Product(
    id: '1',
    sku: 'PCT500',
    nama: 'Paracetamol 500mg',
    kategori: 'Analgesik',
    satuan: 'Strip',
  ),
  Product(
    id: '2',
    sku: 'AMX500',
    nama: 'Amoxicillin 500mg',
    kategori: 'Antibiotik',
    satuan: 'Strip',
  ),
  Product(
    id: '3',
    sku: 'IBU400',
    nama: 'Ibuprofen 400mg',
    kategori: 'NSAID',
    satuan: 'Strip',
  ),
  Product(
    id: '4',
    sku: 'OMP20',
    nama: 'Omeprazole 20mg',
    kategori: 'PPI',
    satuan: 'Strip',
  ),
  Product(
    id: '5',
    sku: 'CTM4',
    nama: 'Chlorphenamine Maleate 4mg',
    kategori: 'Antihistamin',
    satuan: 'Strip',
  ),
  Product(
    id: '6',
    sku: 'MTF500',
    nama: 'Metformin 500mg',
    kategori: 'Antidiabetik',
    satuan: 'Strip',
  ),
  Product(
    id: '7',
    sku: 'ASP100',
    nama: 'Aspirin 100mg',
    kategori: 'Antiplatelet',
    satuan: 'Strip',
  ),
  Product(
    id: '8',
    sku: 'SIM10',
    nama: 'Simvastatin 10mg',
    kategori: 'Statin',
    satuan: 'Strip',
  ),
  Product(
    id: '9',
    sku: 'CAP25',
    nama: 'Captopril 25mg',
    kategori: 'ACE Inhibitor',
    satuan: 'Strip',
  ),
  Product(
    id: '10',
    sku: 'DOM10',
    nama: 'Domperidone 10mg',
    kategori: 'Prokinetik',
    satuan: 'Strip',
  ),
  Product(
    id: '11',
    sku: 'DIC50',
    nama: 'Diclofenac 50mg',
    kategori: 'NSAID',
    satuan: 'Strip',
  ),
  Product(
    id: '12',
    sku: 'RAN150',
    nama: 'Ranitidine 150mg',
    kategori: 'H2 Blocker',
    satuan: 'Strip',
  ),
  Product(
    id: '13',
    sku: 'CET10',
    nama: 'Cetirizine 10mg',
    kategori: 'Antihistamin',
    satuan: 'Strip',
  ),
  Product(
    id: '14',
    sku: 'ANT100',
    nama: 'Antasida 100ml',
    kategori: 'Antasida',
    satuan: 'Botol',
  ),
  Product(
    id: '15',
    sku: 'VIT1000',
    nama: 'Vitamin C 1000mg',
    kategori: 'Vitamin',
    satuan: 'Strip',
  ),
  Product(
    id: '16',
    sku: 'GLI5',
    nama: 'Glimepiride 5mg',
    kategori: 'Antidiabetik',
    satuan: 'Strip',
  ),
  Product(
    id: '17',
    sku: 'AMB5',
    nama: 'Amlodipine 5mg',
    kategori: 'CCB',
    satuan: 'Strip',
  ),
  Product(
    id: '18',
    sku: 'FUR40',
    nama: 'Furosemide 40mg',
    kategori: 'Diuretik',
    satuan: 'Strip',
  ),
  Product(
    id: '19',
    sku: 'PRE5',
    nama: 'Prednisolone 5mg',
    kategori: 'Kortikosteroid',
    satuan: 'Strip',
  ),
  Product(
    id: '20',
    sku: 'KEL600',
    nama: 'Ketorolac 600mg',
    kategori: 'NSAID',
    satuan: 'Ampul',
  ),
];

// Sample supplier names (reuse dari data_supplier_screen)
final List<String> supplierNames = [
  'PT Kimia Farma Trading',
  'PT Kalbe Farma Tbk',
  'PT Sanbe Farma',
  'PT Pharos Indonesia',
  'PT Dexa Medica',
  'PT Combiphar',
  'PT Enseval Putera Megatrading',
  'PT Tempo Scan Pacific',
];

// Generate sample pricelist data
List<PricelistItem> generateSamplePricelist() {
  final List<PricelistItem> pricelist = [];

  for (int i = 0; i < sampleProducts.length; i++) {
    final product = sampleProducts[i];

    // Generate 2-4 suppliers per product
    final supplierCount = 2 + (i % 3);

    for (int j = 0; j < supplierCount; j++) {
      final supplier = supplierNames[j % supplierNames.length];
      final basePrice = 5000 + (i * 2000) + (j * 500); // Varied pricing

      pricelist.add(
        PricelistItem(
          id: 'PL${i.toString().padLeft(3, '0')}$j',
          productId: product.id,
          supplierId: 'SUP00${j + 1}',
          productName: product.nama,
          supplierName: supplier,
          sku: product.sku,
          satuan: product.satuan,
          penjualanRataRata: (50 + (i * 5) + (j * 10)).toDouble(),
          stok: 20 + (i * 10) + (j * 25),
          hargaTermurah: (basePrice - (j * 200)).toDouble(),
          hargaTertinggi: (basePrice + (j * 300)).toDouble(),
          hargaAktual: (basePrice + (j * 250)).toDouble(),
          terakhirUpdate: DateTime.now().subtract(Duration(days: j + 1)),
        ),
      );
    }
  }

  return pricelist;
}
