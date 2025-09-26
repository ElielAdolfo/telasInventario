// lib/features/venta/models/venta_model.dart

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
    this.deleted = false,
    required this.updatedAt,
  });

  factory Venta.fromJson(Map<String, dynamic> json, String id) {
    var itemsList = <VentaItem>[];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((item) => VentaItem.fromJson(item))
          .toList();
    }

    return Venta(
      id: id,
      idTienda: json['idTienda'] ?? '',
      idEmpresa: json['idEmpresa'] ?? '',
      fechaVenta: json['fechaVenta'] != null
          ? DateTime.parse(json['fechaVenta'])
          : DateTime.now(), // Valor por defecto si es nulo
      total: (json['total'] ?? 0).toDouble(),
      realizadoPor: json['realizadoPor'] ?? '',
      deleted: json['deleted'] ?? false,
      updatedAt:
          json['updatedAt'] ??
          DateTime.now().toIso8601String(), // Valor por defecto si es nulo
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idTienda': idTienda,
      'idEmpresa': idEmpresa,
      'fechaVenta': fechaVenta.toIso8601String(),
      'total': total,
      'realizadoPor': realizadoPor,
      'items': items.map((item) => item.toJson()).toList(),
      'deleted': deleted, // Agregado campo deleted
      'updatedAt': updatedAt, // Agregado campo updatedAt
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

  VentaItem({
    required this.idProducto,
    required this.nombreProducto,
    required this.idColor,
    required this.nombreColor,
    required this.codigoColor,
    required this.precio,
    required this.cantidad,
    required this.subtotal,
  });

  factory VentaItem.fromJson(Map<String, dynamic> json) {
    return VentaItem(
      idProducto: json['idProducto'] ?? '',
      nombreProducto: json['nombreProducto'] ?? '',
      idColor: json['idColor'] ?? '',
      nombreColor: json['nombreColor'] ?? '',
      codigoColor: json['codigoColor'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      cantidad: json['cantidad'] ?? 0,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
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
    };
  }
}
