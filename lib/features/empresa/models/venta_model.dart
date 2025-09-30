// lib/features/empresa/models/venta_model.dart

import 'package:inventario/features/empresa/models/venta_item_model.dart';

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
