// lib/features/empresa/models/venta_model.dart

class Venta {
  final String id;
  final String idTienda;
  final String idEmpresa;
  final DateTime fechaVenta;
  final double total;
  final String realizadoPor;
  final List<VentaItem> items;
  final bool deleted;
  final String updatedAt;

  Venta({
    required this.id,
    required this.idTienda,
    required this.idEmpresa,
    required this.fechaVenta,
    required this.total,
    required this.realizadoPor,
    required this.items,
    required this.deleted,
    required this.updatedAt,
  });

  // Factory constructor para crear desde JSON
  factory Venta.fromJson(Map<String, dynamic> json, String id) {
    return Venta(
      id: id,
      idTienda: json['idTienda'] ?? '',
      idEmpresa: json['idEmpresa'] ?? '',
      fechaVenta: DateTime.parse(json['fechaVenta']),
      total: (json['total'] ?? 0).toDouble(),
      realizadoPor: json['realizadoPor'] ?? '',
      items: (json['items'] as List)
          .map((item) => VentaItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      deleted: json['deleted'] ?? false,
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'idTienda': idTienda,
      'idEmpresa': idEmpresa,
      'fechaVenta': fechaVenta.toIso8601String(),
      'total': total,
      'realizadoPor': realizadoPor,
      'items': items.map((item) => item.toJson()).toList(),
      'deleted': deleted,
      'updatedAt': updatedAt,
    };
  }
}

class VentaItem {
  final String idProducto;
  final String nombreProducto;
  final String? idColor;
  final String? nombreColor;
  final String? codigoColor;
  final double precio;
  final int cantidad;
  final double subtotal;
  final String tipoVenta; // 'UNIDAD_COMPLETA' o 'UNIDAD_ABIERTA'
  final String? idStockTienda; // Referencia al stock de tienda
  final String? idStockUnidadAbierta; // Referencia a la unidad abierta

  VentaItem({
    required this.idProducto,
    required this.nombreProducto,
    this.idColor,
    this.nombreColor,
    this.codigoColor,
    required this.precio,
    required this.cantidad,
    required this.subtotal,
    required this.tipoVenta,
    this.idStockTienda,
    this.idStockUnidadAbierta,
  });

  factory VentaItem.fromJson(Map<String, dynamic> json) {
    return VentaItem(
      idProducto: json['idProducto'] ?? '',
      nombreProducto: json['nombreProducto'] ?? '',
      idColor: json['idColor'],
      nombreColor: json['nombreColor'],
      codigoColor: json['codigoColor'],
      precio: (json['precio'] ?? 0).toDouble(),
      cantidad: json['cantidad'] ?? 0,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      tipoVenta: json['tipoVenta'] ?? '',
      idStockTienda: json['idStockTienda'],
      idStockUnidadAbierta: json['idStockUnidadAbierta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idProducto': idProducto,
      'nombreProducto': nombreProducto,
      'idColor': idColor,
      'nombreColor': nombreColor,
      'codigoColor': codigoColor,
      'precio': precio,
      'cantidad': cantidad,
      'subtotal': subtotal,
      'tipoVenta': tipoVenta,
      'idStockTienda': idStockTienda,
      'idStockUnidadAbierta': idStockUnidadAbierta,
    };
  }
}
