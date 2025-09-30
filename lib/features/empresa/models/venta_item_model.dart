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
    };
  }

  // Método toString para depuración
  @override
  String toString() {
    return 'VentaItem(idProducto: $idProducto, nombreProducto: $nombreProducto, idColor: $idColor, nombreColor: $nombreColor, codigoColor: $codigoColor, precio: $precio, cantidad: $cantidad, subtotal: $subtotal, tipoVenta: $tipoVenta, idStockTienda: $idStockTienda, idStockUnidadAbierta: $idStockUnidadAbierta, idStockLoteTienda: $idStockLoteTienda)';
  }
}
