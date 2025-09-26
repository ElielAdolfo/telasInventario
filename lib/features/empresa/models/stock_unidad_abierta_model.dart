// lib/features/empresa/models/stock_unidad_abierta_model.dart

class StockUnidadAbierta {
  final String id;
  final String idStockLoteTienda; // Referencia al lote padre
  final int cantidadTotal; // Cantidad total de la unidad (ej: 50 metros)
  final int cantidadVendida; // Cantidad ya vendida de la unidad
  final int cantidadDisponible; // Cantidad disponible de la unidad
  final bool estaCerrada; // Indica si la unidad se ha cerrado
  final DateTime? fechaApertura; // Fecha en que se abrió la unidad
  final DateTime? fechaCierre; // Fecha en que se cerró la unidad
  final String abiertoPor; // Usuario que abrió la unidad
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockUnidadAbierta({
    required this.id,
    required this.idStockLoteTienda,
    required this.cantidadTotal,
    required this.cantidadVendida,
    required this.cantidadDisponible,
    required this.estaCerrada,
    this.fechaApertura,
    this.fechaCierre,
    required this.abiertoPor,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockUnidadAbierta.fromJson(Map<String, dynamic> json, String id) {
    return StockUnidadAbierta(
      id: id,
      idStockLoteTienda: json['idStockLoteTienda'] ?? '',
      cantidadTotal: json['cantidadTotal'] ?? 0,
      cantidadVendida: json['cantidadVendida'] ?? 0,
      cantidadDisponible: json['cantidadDisponible'] ?? 0,
      estaCerrada: json['estaCerrada'] ?? false,
      fechaApertura: json['fechaApertura'] != null
          ? DateTime.parse(json['fechaApertura'])
          : null,
      fechaCierre: json['fechaCierre'] != null
          ? DateTime.parse(json['fechaCierre'])
          : null,
      abiertoPor: json['abiertoPor'] ?? '',
      deleted: json['deleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idStockLoteTienda': idStockLoteTienda,
      'cantidadTotal': cantidadTotal,
      'cantidadVendida': cantidadVendida,
      'cantidadDisponible': cantidadDisponible,
      'estaCerrada': estaCerrada,
      'fechaApertura': fechaApertura?.toIso8601String(),
      'fechaCierre': fechaCierre?.toIso8601String(),
      'abiertoPor': abiertoPor,
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  StockUnidadAbierta copyWith({
    String? id,
    int? cantidadTotal,
    int? cantidadVendida,
    int? cantidadDisponible,
    bool? estaCerrada,
    DateTime? fechaApertura,
    DateTime? fechaCierre,
    String? abiertoPor,
    bool? deleted,
  }) {
    return StockUnidadAbierta(
      id: id ?? this.id,
      idStockLoteTienda: idStockLoteTienda,
      cantidadTotal: cantidadTotal ?? this.cantidadTotal,
      cantidadVendida: cantidadVendida ?? this.cantidadVendida,
      cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
      estaCerrada: estaCerrada ?? this.estaCerrada,
      fechaApertura: fechaApertura ?? this.fechaApertura,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      abiertoPor: abiertoPor ?? this.abiertoPor,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
