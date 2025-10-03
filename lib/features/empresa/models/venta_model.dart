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
  
  // Campos de auditoría
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;

  Venta({
    required this.id,
    required this.idTienda,
    required this.idEmpresa,
    required this.fechaVenta,
    required this.total,
    required this.realizadoPor,
    required this.items,
    required this.deleted,
    // Campos de auditoría
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
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
      // Campos de auditoría
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      deletedBy: json['deletedBy'],
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
      // Campos de auditoría
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'deletedBy': deletedBy,
    };
  }
  

  // Método copyWith
  Venta copyWith({
    String? id,
    String? idTienda,
    String? idEmpresa,
    DateTime? fechaVenta,
    double? total,
    String? realizadoPor,
    List<VentaItem>? items,
    bool? deleted,
    // Campos de auditoría
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? createdBy,
    String? updatedBy,
    String? deletedBy,
  }) {
    return Venta(
      id: id ?? this.id,
      idTienda: idTienda ?? this.idTienda,
      idEmpresa: idEmpresa ?? this.idEmpresa,
      fechaVenta: fechaVenta ?? this.fechaVenta,
      total: total ?? this.total,
      realizadoPor: realizadoPor ?? this.realizadoPor,
      items: items ?? this.items,
      deleted: deleted ?? this.deleted,
      // Campos de auditoría
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }

  @override
  String toString() {
    return 'Venta('
        'id: $id, '
        'idTienda: $idTienda, '
        'idEmpresa: $idEmpresa, '
        'fechaVenta: $fechaVenta, '
        'total: $total, '
        'realizadoPor: $realizadoPor, '
        'deleted: $deleted, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'createdBy: $createdBy, '
        'updatedBy: $updatedBy, '
        'items: $items'
        ')';
  }
}
