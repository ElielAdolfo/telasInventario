// lib/features/empresa/models/stock_lote_tienda_model.dart

class StockLoteTienda {
  final String id;
  final String idStockTienda; // Referencia al stock general de la tienda
  final String idSolicitudTraslado; // Referencia a la solicitud original
  final int cantidadTotal; // Cantidad total del lote (ej: 3 rollos)
  final int cantidadVendida; // Cantidad ya vendida del lote
  final int cantidadDisponible; // Cantidad disponible del lote
  final int cantidadPorUnidad; // Cantidad por unidad (ej: 50 metros por rollo)
  final int unidadesAbiertas; // Unidades abiertas para venta por metro
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockLoteTienda({
    required this.id,
    required this.idStockTienda,
    required this.idSolicitudTraslado,
    required this.cantidadTotal,
    required this.cantidadVendida,
    required this.cantidadDisponible,
    required this.cantidadPorUnidad,
    required this.unidadesAbiertas,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockLoteTienda.fromJson(Map<String, dynamic> json, String id) {
    return StockLoteTienda(
      id: id,
      idStockTienda: json['idStockTienda'] ?? '',
      idSolicitudTraslado: json['idSolicitudTraslado'] ?? '',
      cantidadTotal: json['cantidadTotal'] ?? 0,
      cantidadVendida: json['cantidadVendida'] ?? 0,
      cantidadDisponible: json['cantidadDisponible'] ?? 0,
      cantidadPorUnidad: json['cantidadPorUnidad'] ?? 0,
      unidadesAbiertas: json['unidadesAbiertas'] ?? 0,
      deleted: json['deleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idStockTienda': idStockTienda,
      'idSolicitudTraslado': idSolicitudTraslado,
      'cantidadTotal': cantidadTotal,
      'cantidadVendida': cantidadVendida,
      'cantidadDisponible': cantidadDisponible,
      'cantidadPorUnidad': cantidadPorUnidad,
      'unidadesAbiertas': unidadesAbiertas,
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  StockLoteTienda copyWith({
    String? id,
    String? idStockTienda,
    String? idSolicitudTraslado,
    int? cantidadTotal,
    int? cantidadVendida,
    int? cantidadDisponible,
    int? cantidadPorUnidad,
    int? unidadesAbiertas,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockLoteTienda(
      id: id ?? this.id,
      idStockTienda: idStockTienda ?? this.idStockTienda,
      idSolicitudTraslado: idSolicitudTraslado ?? this.idSolicitudTraslado,
      cantidadTotal: cantidadTotal ?? this.cantidadTotal,
      cantidadVendida: cantidadVendida ?? this.cantidadVendida,
      cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
      cantidadPorUnidad: cantidadPorUnidad ?? this.cantidadPorUnidad,
      unidadesAbiertas: unidadesAbiertas ?? this.unidadesAbiertas,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Nuevo método estático empty
  static StockLoteTienda empty() {
    return StockLoteTienda(
      id: '',
      idStockTienda: '',
      idSolicitudTraslado: '',
      cantidadTotal: 0,
      cantidadVendida: 0,
      cantidadDisponible: 0,
      cantidadPorUnidad: 0,
      unidadesAbiertas: 0,
      deleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
