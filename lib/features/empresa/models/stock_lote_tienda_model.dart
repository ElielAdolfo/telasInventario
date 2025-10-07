// lib/features/empresa/models/stock_lote_tienda_model.dart

class StockLoteTienda {
  final String id;
  final String idStockTienda;
  final double cantidad;
  final double cantidadVendida;
  final DateTime fechaApertura;
  final String abiertoPor;
  final bool estaCerrada;
  final DateTime? fechaCierre;
  final String? cerradoPor;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? codigoUnico; // ✅ Nuevo campo
  final String idTipoProducto; // ✅ Nuevo campo
  final String idEmpresa; // ✅ Nuevo campo
  final String idTienda; // ✅ Nuevo campo
  final String? idColor; // ✅ Nuevo campo opcional

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
    this.codigoUnico,
    required this.idTipoProducto,
    required this.idEmpresa,
    required this.idTienda,
    this.idColor, // ✅ agregado al constructor
  });

  double get cantidadDisponible => cantidad - cantidadVendida;

  factory StockLoteTienda.fromJson(Map<String, dynamic> json, String id) {
    return StockLoteTienda(
      id: id,
      idStockTienda: json['idStockTienda'] ?? '',
      cantidad: (json['cantidad'] ?? 0).toDouble(),
      cantidadVendida: (json['cantidadVendida'] ?? 0).toDouble(),
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
      codigoUnico: json['codigoUnico'],
      idTipoProducto: json['idTipoProducto'] ?? '',
      idEmpresa: json['idEmpresa'] ?? '',
      idTienda: json['idTienda'] ?? '',
      idColor: json['idColor'], // ✅ agregado
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
      'codigoUnico': codigoUnico,
      'idTipoProducto': idTipoProducto,
      'idEmpresa': idEmpresa,
      'idTienda': idTienda,
      'idColor': idColor, // ✅ agregado
    };
  }

  StockLoteTienda copyWith({
    String? id,
    String? idStockTienda,
    double? cantidad,
    double? cantidadVendida,
    DateTime? fechaApertura,
    String? abiertoPor,
    bool? estaCerrada,
    DateTime? fechaCierre,
    String? cerradoPor,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? codigoUnico,
    String? idTipoProducto,
    String? idEmpresa,
    String? idTienda,
    String? idColor, // ✅ agregado
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
      codigoUnico: codigoUnico ?? this.codigoUnico,
      idTipoProducto: idTipoProducto ?? this.idTipoProducto,
      idEmpresa: idEmpresa ?? this.idEmpresa,
      idTienda: idTienda ?? this.idTienda,
      idColor: idColor ?? this.idColor, // ✅ agregado
    );
  }

  @override
  String toString() {
    return 'StockLoteTienda('
        'id: $id, '
        'idStockTienda: $idStockTienda, '
        'idTipoProducto: $idTipoProducto, '
        'idEmpresa: $idEmpresa, '
        'idTienda: $idTienda, '
        'idColor: $idColor, '
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
        'updatedAt: $updatedAt, '
        'codigoUnico: $codigoUnico'
        ')';
  }
}
