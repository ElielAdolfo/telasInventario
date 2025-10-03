// lib/features/venta/models/carrito_item_model.dart

class CarritoItem {
  final String id;
  final String idProducto;
  final String nombreProducto;
  final String? idColor;
  final String? nombreColor;
  final String? codigoColor;
  final double precio;
  int cantidad;
  double subtotal;
  final String? idStockTienda;

  // Nuevos campos para manejar ambos tipos de venta
  final String tipoVenta; // 'UNIDAD_COMPLETA' o 'UNIDAD_ABIERTA'
  final String? idStockLoteTienda; // ID del lote si es por unidad completa
  final String?
  idStockUnidadAbierta; // ID de la unidad abierta si es por unidad abierta
  final String idUsuario;

  CarritoItem({
    required this.id,
    required this.idProducto,
    required this.nombreProducto,
    required this.idColor,
    required this.nombreColor,
    required this.codigoColor,
    required this.precio,
    required this.cantidad,
    required this.tipoVenta,
    this.idStockLoteTienda,
    this.idStockTienda,
    this.idStockUnidadAbierta,
    required this.idUsuario, // Nuevo campo
  }) : subtotal = precio * cantidad;

  void actualizarCantidad(int nuevaCantidad) {
    cantidad = nuevaCantidad;
    subtotal = precio * cantidad;
  }

  // Nuevo método copyWith
  CarritoItem copyWith({
    String? id,
    String? idProducto,
    String? nombreProducto,
    String? idColor,
    String? nombreColor,
    String? codigoColor,
    double? precio,
    int? cantidad,
    double? subtotal,
    String? tipoVenta,
    String? idStockLoteTienda,
    String? idStockUnidadAbierta,
    String? idUsuario, // Nuevo parámetro
  }) {
    return CarritoItem(
      id: id ?? this.id,
      idProducto: idProducto ?? this.idProducto,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      idColor: idColor ?? this.idColor,
      nombreColor: nombreColor ?? this.nombreColor,
      codigoColor: codigoColor ?? this.codigoColor,
      precio: precio ?? this.precio,
      cantidad: cantidad ?? this.cantidad,
      tipoVenta: tipoVenta ?? this.tipoVenta,
      idStockLoteTienda: idStockLoteTienda ?? this.idStockLoteTienda,
      idStockUnidadAbierta: idStockUnidadAbierta ?? this.idStockUnidadAbierta,
      idUsuario: idUsuario ?? this.idUsuario, // Nuevo campo
    );
  }

  // Método toString para depuración
  @override
  String toString() {
    return 'CarritoItem('
        'id: $id, '
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
        'idStockLoteTienda: $idStockLoteTienda, '
        'idStockUnidadAbierta: $idStockUnidadAbierta, '
        'idUsuario: $idUsuario' // Nuevo campo
        ')';
  }
}
