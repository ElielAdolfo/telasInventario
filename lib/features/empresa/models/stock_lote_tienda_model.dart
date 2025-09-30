// lib/features/empresa/models/stock_lote_tienda_model.dart

class StockLoteTienda {
  final String id;
  final String idStockTienda;
  final int cantidad;
  final int cantidadVendida;
  final DateTime fechaApertura;
  final String abiertoPor;
  final bool estaCerrada;
  final DateTime? fechaCierre;
  final String? cerradoPor;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockLoteTienda({
    required this.id,
    required this.idStockTienda,
    required this.cantidad,
    required this.cantidadVendida,
    required this.fechaApertura,
    required this.abiertoPor,
    this.estaCerrada = false,
    this.fechaCierre,
    this.cerradoPor,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  int get cantidadDisponible => cantidad - cantidadVendida;

  factory StockLoteTienda.fromJson(Map<String, dynamic> json, String id) {
    return StockLoteTienda(
      id: id,
      idStockTienda: json['idStockTienda'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      cantidadVendida: json['cantidadVendida'] ?? 0,
      fechaApertura: DateTime.parse(json['fechaApertura']),
      abiertoPor: json['abiertoPor'] ?? '',
      estaCerrada: json['estaCerrada'] ?? false,
      fechaCierre: json['fechaCierre'] != null
          ? DateTime.parse(json['fechaCierre'])
          : null,
      cerradoPor: json['cerradoPor'],
      deleted: json['deleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idStockTienda': idStockTienda,
      'cantidad': cantidad,
      'cantidadVendida': cantidadVendida,
      'fechaApertura': fechaApertura.toIso8601String(),
      'abiertoPor': abiertoPor,
      'estaCerrada': estaCerrada,
      'fechaCierre': fechaCierre?.toIso8601String(),
      'cerradoPor': cerradoPor,
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  StockLoteTienda copyWith({
    String? id,
    String? idStockTienda,
    int? cantidad,
    int? cantidadVendida,
    DateTime? fechaApertura,
    String? abiertoPor,
    bool? estaCerrada,
    DateTime? fechaCierre,
    String? cerradoPor,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockLoteTienda(
      id: id ?? this.id,
      idStockTienda: idStockTienda ?? this.idStockTienda,
      cantidad: cantidad ?? this.cantidad,
      cantidadVendida: cantidadVendida ?? this.cantidadVendida,
      fechaApertura: fechaApertura ?? this.fechaApertura,
      abiertoPor: abiertoPor ?? this.abiertoPor,
      estaCerrada: estaCerrada ?? this.estaCerrada,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      cerradoPor: cerradoPor ?? this.cerradoPor,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'StockLoteTienda('
        'id: $id, '
        'idStockTienda: $idStockTienda, '
        'cantidad: $cantidad, '
        'cantidadVendida: $cantidadVendida, '
        'cantidadDisponible: $cantidadDisponible, '
        'fechaApertura: $fechaApertura, '
        'abiertoPor: $abiertoPor, '
        'estaCerrada: $estaCerrada, '
        'fechaCierre: $fechaCierre, '
        'cerradoPor: $cerradoPor, '
        'deleted: $deleted, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}
