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
  final String?
  idStockLoteTienda; // Referencia al stock del lote tienda unidad secundaria

  // Campos de auditoría
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;

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
    this.idStockLoteTienda,
    // Campos de auditoría
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
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
      idStockLoteTienda: json['idStockLoteTienda'],
      // Campos de auditoría
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      deletedBy: json['deletedBy'],
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
      'idStockLoteTienda': idStockLoteTienda,
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
  VentaItem copyWith({
    String? idProducto,
    String? nombreProducto,
    String? idColor,
    String? nombreColor,
    String? codigoColor,
    double? precio,
    int? cantidad,
    double? subtotal,
    String? tipoVenta,
    String? idStockTienda,
    String? idStockUnidadAbierta,
    String? idStockLoteTienda,
    // Campos de auditoría
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? createdBy,
    String? updatedBy,
    String? deletedBy,
  }) {
    return VentaItem(
      idProducto: idProducto ?? this.idProducto,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      idColor: idColor ?? this.idColor,
      nombreColor: nombreColor ?? this.nombreColor,
      codigoColor: codigoColor ?? this.codigoColor,
      precio: precio ?? this.precio,
      cantidad: cantidad ?? this.cantidad,
      subtotal: subtotal ?? this.subtotal,
      tipoVenta: tipoVenta ?? this.tipoVenta,
      idStockTienda: idStockTienda ?? this.idStockTienda,
      idStockUnidadAbierta: idStockUnidadAbierta ?? this.idStockUnidadAbierta,
      idStockLoteTienda: idStockLoteTienda ?? this.idStockLoteTienda,
      // Campos de auditoría
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }

  // Método toString para depuración
  @override
  String toString() {
    return 'VentaItem('
        'idProducto: $idProducto, '
        'nombreProducto: $nombreProducto, '
        'idColor: $idColor, '
        'nombreColor: $nombreColor, '
        'codigoColor: $codigoColor, '
        'precio: $precio, '
        'cantidad: $cantidad, '
        'subtotal: $subtotal, '
        'tipoVenta: $tipoVenta, '
        'idStockTienda: $idStockTienda, '
        'idStockUnidadAbierta: $idStockUnidadAbierta, '
        'idStockLoteTienda: $idStockLoteTienda, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'createdBy: $createdBy, '
        'updatedBy: $updatedBy'
        ')';
  }
}
