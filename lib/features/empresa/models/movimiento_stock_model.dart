// lib/features/movimientos/models/movimiento_stock_model.dart

class MovimientoStock {
  final String id;
  final String idProducto;
  final String idEmpresa;
  final String? idTienda;
  final String
  tipoMovimiento; // "SOLICITUD", "APROBACION", "TRASLADO", "RECEPCION", "DEVOLUCION"
  final int cantidad;
  final String? idSolicitudTraslado;
  final String origen; // "EMPRESA" o "TIENDA"
  final String? destino;
  final DateTime fechaMovimiento;
  final String realizadoPor;
  final String? observaciones;

  // Campos de auditoría
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;

  MovimientoStock({
    required this.id,
    required this.idProducto,
    required this.idEmpresa,
    this.idTienda,
    required this.tipoMovimiento,
    required this.cantidad,
    this.idSolicitudTraslado,
    required this.origen,
    this.destino,
    required this.fechaMovimiento,
    required this.realizadoPor,
    this.observaciones,
    // Campos de auditoría
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
  });

  factory MovimientoStock.fromJson(Map<String, dynamic> json, String id) {
    return MovimientoStock(
      id: id,
      idProducto: json['idProducto'] ?? '',
      idEmpresa: json['idEmpresa'] ?? '',
      idTienda: json['idTienda'],
      tipoMovimiento: json['tipoMovimiento'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      idSolicitudTraslado: json['idSolicitudTraslado'],
      origen: json['origen'] ?? '',
      destino: json['destino'],
      fechaMovimiento: DateTime.parse(json['fechaMovimiento']),
      realizadoPor: json['realizadoPor'] ?? '',
      observaciones: json['observaciones'],
      // Campos de auditoría
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      deletedBy: json['deletedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idProducto': idProducto,
      'idEmpresa': idEmpresa,
      'idTienda': idTienda,
      'tipoMovimiento': tipoMovimiento,
      'cantidad': cantidad,
      'idSolicitudTraslado': idSolicitudTraslado,
      'origen': origen,
      'destino': destino,
      'fechaMovimiento': fechaMovimiento.toIso8601String(),
      'realizadoPor': realizadoPor,
      'observaciones': observaciones,
      // Campos de auditoría
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'deletedBy': deletedBy,
    };
  }
}
