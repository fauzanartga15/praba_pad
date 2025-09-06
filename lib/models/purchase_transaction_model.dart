// lib/models/purchase_transaction_model.dart

enum TransactionStatus { permintaan, diproses, faktur, belumLunas, selesai }

enum ItemStatus { diproses, display, selesai, pending }

class PurchaseTransactionItem {
  final String id;
  final String sku;
  final String productName;
  final String satuan;
  final int qty;
  final double hargaSatuan;
  final ItemStatus status;
  final DateTime tanggal;

  PurchaseTransactionItem({
    required this.id,
    required this.sku,
    required this.productName,
    required this.satuan,
    required this.qty,
    required this.hargaSatuan,
    required this.status,
    required this.tanggal,
  });

  double get total => hargaSatuan * qty;
}

class PurchaseTransaction {
  final String id;
  final String noFaktur;
  final String supplierId;
  final String supplierName;
  final DateTime tanggal;
  final DateTime? dueDate;
  final DateTime? tanggalPenerima;
  final TransactionStatus status;
  final List<PurchaseTransactionItem> items;
  final String? notes;

  PurchaseTransaction({
    required this.id,
    required this.noFaktur,
    required this.supplierId,
    required this.supplierName,
    required this.tanggal,
    this.dueDate,
    this.tanggalPenerima,
    required this.status,
    required this.items,
    this.notes,
  });

  // Calculated fields
  int get totalQty => items.fold(0, (sum, item) => sum + item.qty);

  double get subTotal => items.fold(0.0, (sum, item) => sum + item.total);

  double get pajak => subTotal * 0.11; // 11% tax

  double get total => subTotal + pajak;

  double get terbayar {
    // For demonstration purposes, some random payment amounts
    switch (status) {
      case TransactionStatus.permintaan:
      case TransactionStatus.diproses:
        return 0.0;
      case TransactionStatus.faktur:
        return total * 0.3; // 30% paid
      case TransactionStatus.belumLunas:
        return total * 0.7; // 70% paid
      case TransactionStatus.selesai:
        return total; // 100% paid
    }
  }

  double get sisa => total - terbayar;

  String get statusText {
    switch (status) {
      case TransactionStatus.permintaan:
        return 'Permintaan';
      case TransactionStatus.diproses:
        return 'Di Proses';
      case TransactionStatus.faktur:
        return 'Faktur';
      case TransactionStatus.belumLunas:
        return 'Belum Lunas';
      case TransactionStatus.selesai:
        return 'Selesai';
    }
  }

  PurchaseTransaction copyWith({
    String? id,
    String? noFaktur,
    String? supplierId,
    String? supplierName,
    DateTime? tanggal,
    DateTime? dueDate,
    DateTime? tanggalPenerima,
    TransactionStatus? status,
    List<PurchaseTransactionItem>? items,
    String? notes,
  }) {
    return PurchaseTransaction(
      id: id ?? this.id,
      noFaktur: noFaktur ?? this.noFaktur,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      tanggal: tanggal ?? this.tanggal,
      dueDate: dueDate ?? this.dueDate,
      tanggalPenerima: tanggalPenerima ?? this.tanggalPenerima,
      status: status ?? this.status,
      items: items ?? this.items,
      notes: notes ?? this.notes,
    );
  }
}

// Sample Indonesian medicine products
final List<String> sampleMedicineProducts = [
  'Paracetamol 500mg Tab',
  'Amoxicillin 500mg Kaps',
  'Ibuprofen 400mg Tab',
  'Omeprazole 20mg Kaps',
  'Chlorphenamine Maleate 4mg Tab',
  'Metformin 500mg Tab',
  'Aspirin 100mg Tab',
  'Simvastatin 10mg Tab',
  'Captopril 25mg Tab',
  'Domperidone 10mg Tab',
  'Diclofenac 50mg Tab',
  'Ranitidine 150mg Tab',
  'Cetirizine 10mg Tab',
  'Antasida Suspensi 120ml',
  'Vitamin C 1000mg Tab',
  'Glimepiride 5mg Tab',
  'Amlodipine 5mg Tab',
  'Furosemide 40mg Tab',
  'Prednisolone 5mg Tab',
  'Ketorolac 30mg Amp',
  'Salbutamol Inhaler 100mcg',
  'Dexamethasone 0.5mg Tab',
  'Lansoprazole 30mg Kaps',
  'Losartan 50mg Tab',
  'Atenolol 50mg Tab',
  'Ciprofloxacin 500mg Tab',
  'Azithromycin 500mg Tab',
  'Loperamide 2mg Kaps',
  'Bisoprolol 5mg Tab',
  'Candesartan 8mg Tab',
];

final List<String> sampleSatuanUnit = [
  'Strip',
  'Box',
  'Botol',
  'Tube',
  'Ampul',
  'Vial',
  'Fls',
  'Blister',
];

// Sample data generator
List<PurchaseTransaction> generateSamplePurchaseTransactions({
  TransactionStatus? filterStatus,
  int count = 30,
}) {
  final List<PurchaseTransaction> transactions = [];

  for (int i = 0; i < count; i++) {
    final transactionDate = DateTime.now().subtract(Duration(days: i));
    final status =
        filterStatus ??
        TransactionStatus.values[i % TransactionStatus.values.length];

    // Generate 2-5 items per transaction
    final itemCount = 2 + (i % 4);
    final items = List.generate(itemCount, (itemIndex) {
      final productIndex = (i + itemIndex) % sampleMedicineProducts.length;
      final product = sampleMedicineProducts[productIndex];

      return PurchaseTransactionItem(
        id: 'ITM${(i * 10 + itemIndex).toString().padLeft(4, '0')}',
        sku: 'SKU${(productIndex + 1).toString().padLeft(3, '0')}',
        productName: product,
        satuan: sampleSatuanUnit[itemIndex % sampleSatuanUnit.length],
        qty: 10 + (itemIndex * 5) + (i % 20),
        hargaSatuan: (5000 + (productIndex * 500) + (itemIndex * 200))
            .toDouble(),
        status: ItemStatus.values[itemIndex % ItemStatus.values.length],
        tanggal: transactionDate,
      );
    });

    final transaction = PurchaseTransaction(
      id: 'PO${(i + 1).toString().padLeft(4, '0')}',
      noFaktur: 'FK${DateTime.now().year}${(i + 1).toString().padLeft(4, '0')}',
      supplierId: 'SUP${((i % 8) + 1).toString().padLeft(3, '0')}',
      supplierName: supplierNames[i % supplierNames.length],
      tanggal: transactionDate,
      dueDate:
          status == TransactionStatus.faktur ||
              status == TransactionStatus.belumLunas ||
              status == TransactionStatus.selesai
          ? transactionDate.add(Duration(days: 30 + (i % 60)))
          : null,
      tanggalPenerima: status == TransactionStatus.selesai
          ? transactionDate.add(Duration(days: 5 + (i % 10)))
          : null,
      status: status,
      items: items,
      notes: i % 3 == 0 ? 'Catatan khusus untuk pembelian ${i + 1}' : null,
    );

    transactions.add(transaction);
  }

  return transactions;
}

// Reuse supplier names from existing supplier model
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
