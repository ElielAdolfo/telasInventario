// lib/features/stock/models/historial_movimiento_model.dart

class HistorialMovimiento {
  final String id;
  final String idEmpresa;
  final String idTipoProducto;
  final String tipoMovimiento; // 'INGRESO', 'TRASLADO_TIENDA', 'AJUSTE', etc.
  final int cantidad;
  final String? idOrigen; // Para traslados: id de la tienda/almacén origen
  final String? idDestino; // Para traslados: id de la tienda/almacén destino
  final String? idStockEmpresa; // Referencia al stock de empresa afectado
  final String? idStockTienda; // Referencia al stock de tienda afectado
  final double? precioUnitario; // Precio en el momento del movimiento
  final String? motivo;
  final String? realizadoPor; // ID del usuario que realizó el movimiento
  final DateTime fechaMovimiento;
  final DateTime createdAt;
  final DateTime updatedAt;

  HistorialMovimiento({
    required this.id,
    required this.idEmpresa,
    required this.idTipoProducto,
    required this.tipoMovimiento,
    required this.cantidad,
    this.idOrigen,
    this.idDestino,
    this.idStockEmpresa,
    this.idStockTienda,
    this.precioUnitario,
    this.motivo,
    this.realizadoPor,
    required this.fechaMovimiento,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HistorialMovimiento.fromJson(Map<String, dynamic> json, String id) {
    return HistorialMovimiento(
      id: id,
      idEmpresa: json['idEmpresa'] ?? '',
      idTipoProducto: json['idTipoProducto'] ?? '',
      tipoMovimiento: json['tipoMovimiento'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      idOrigen: json['idOrigen'],
      idDestino: json['idDestino'],
      idStockEmpresa: json['idStockEmpresa'],
      idStockTienda: json['idStockTienda'],
      precioUnitario: json['precioUnitario']?.toDouble(),
      motivo: json['motivo'],
      realizadoPor: json['realizadoPor'],
      fechaMovimiento: DateTime.parse(json['fechaMovimiento']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEmpresa': idEmpresa,
      'idTipoProducto': idTipoProducto,
      'tipoMovimiento': tipoMovimiento,
      'cantidad': cantidad,
      'idOrigen': idOrigen,
      'idDestino': idDestino,
      'idStockEmpresa': idStockEmpresa,
      'idStockTienda': idStockTienda,
      'precioUnitario': precioUnitario,
      'motivo': motivo,
      'realizadoPor': realizadoPor,
      'fechaMovimiento': fechaMovimiento.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
