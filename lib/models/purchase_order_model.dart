class PurchaseOrderItem {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final String satuan;
  final double hargaSatuan;
  final int jumlah;
  final String? keterangan;
  final DateTime createdAt;

  PurchaseOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.satuan,
    required this.hargaSatuan,
    required this.jumlah,
    this.keterangan,
    required this.createdAt,
  });

  double get totalHarga => hargaSatuan * jumlah;

  PurchaseOrderItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? sku,
    String? satuan,
    double? hargaSatuan,
    int? jumlah,
    String? keterangan,
    DateTime? createdAt,
  }) {
    return PurchaseOrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      satuan: satuan ?? this.satuan,
      hargaSatuan: hargaSatuan ?? this.hargaSatuan,
      jumlah: jumlah ?? this.jumlah,
      keterangan: keterangan ?? this.keterangan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PurchaseOrder {
  final String id;
  final String supplierId;
  final String supplierName;
  final String supplierAddress;
  final List<PurchaseOrderItem> items;
  final String? notes;
  final DateTime createdAt;
  final PurchaseOrderStatus status;

  PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.supplierAddress,
    required this.items,
    this.notes,
    required this.createdAt,
    this.status = PurchaseOrderStatus.draft,
  });

  double get grandTotal => items.fold(0, (sum, item) => sum + item.totalHarga);
  int get totalItems => items.fold(0, (sum, item) => sum + item.jumlah);

  PurchaseOrder copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    String? supplierAddress,
    List<PurchaseOrderItem>? items,
    String? notes,
    DateTime? createdAt,
    PurchaseOrderStatus? status,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      supplierAddress: supplierAddress ?? this.supplierAddress,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

enum PurchaseOrderStatus { draft, pending, approved, rejected, completed }

// Helper class untuk form data
class ProductFormData {
  final String? selectedProductId;
  final String? selectedSupplierId;
  final int stokSaatIni;
  final double hargaRataRata;
  final double hargaTerakhir;
  final String satuan;
  final int jumlah;
  final String keterangan;

  ProductFormData({
    this.selectedProductId,
    this.selectedSupplierId,
    this.stokSaatIni = 0,
    this.hargaRataRata = 0.0,
    this.hargaTerakhir = 0.0,
    this.satuan = '',
    this.jumlah = 0,
    this.keterangan = '',
  });

  ProductFormData copyWith({
    String? selectedProductId,
    String? selectedSupplierId,
    int? stokSaatIni,
    double? hargaRataRata,
    double? hargaTerakhir,
    String? satuan,
    int? jumlah,
    String? keterangan,
  }) {
    return ProductFormData(
      selectedProductId: selectedProductId ?? this.selectedProductId,
      selectedSupplierId: selectedSupplierId ?? this.selectedSupplierId,
      stokSaatIni: stokSaatIni ?? this.stokSaatIni,
      hargaRataRata: hargaRataRata ?? this.hargaRataRata,
      hargaTerakhir: hargaTerakhir ?? this.hargaTerakhir,
      satuan: satuan ?? this.satuan,
      jumlah: jumlah ?? this.jumlah,
      keterangan: keterangan ?? this.keterangan,
    );
  }

  bool get isValid =>
      selectedProductId != null &&
      selectedSupplierId != null &&
      jumlah > 0 &&
      hargaTerakhir > 0;
}
