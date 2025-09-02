enum JenisSupplier { pabrik, pbf, lainnya }

class Supplier {
  final String kode;
  final String nama;
  final String alamat;
  final String email;
  final String contactPIC;
  final JenisSupplier jenis;
  final int termin;
  final DateTime updated;

  Supplier({
    required this.kode,
    required this.nama,
    required this.alamat,
    required this.email,
    required this.contactPIC,
    required this.jenis,
    required this.termin,
    required this.updated,
  });

  Supplier copyWith({
    String? kode,
    String? nama,
    String? alamat,
    String? email,
    String? contactPIC,
    JenisSupplier? jenis,
    int? termin,
    DateTime? updated,
  }) {
    return Supplier(
      kode: kode ?? this.kode,
      nama: nama ?? this.nama,
      alamat: alamat ?? this.alamat,
      email: email ?? this.email,
      contactPIC: contactPIC ?? this.contactPIC,
      jenis: jenis ?? this.jenis,
      termin: termin ?? this.termin,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kode': kode,
      'nama': nama,
      'alamat': alamat,
      'email': email,
      'contactPIC': contactPIC,
      'jenis': jenis.index,
      'termin': termin,
      'updated': updated.millisecondsSinceEpoch,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      kode: map['kode'] ?? '',
      nama: map['nama'] ?? '',
      alamat: map['alamat'] ?? '',
      email: map['email'] ?? '',
      contactPIC: map['contactPIC'] ?? '',
      jenis: JenisSupplier.values[map['jenis'] ?? 0],
      termin: map['termin']?.toInt() ?? 0,
      updated: DateTime.fromMillisecondsSinceEpoch(map['updated']),
    );
  }
}
