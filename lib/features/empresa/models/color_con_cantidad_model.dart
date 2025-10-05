// lib/features/stock/models/color_con_cantidad_model.dart

import 'package:inventario/features/empresa/models/color_model.dart';

class ColorConCantidad {
  final ColorProducto color;
  int cantidad; // Metros por rollo/paquete
  int unidades; // Número de rollos/paquetes
  double precioCompra; // Precio específico para esta entrada
  double precioVentaMenor; // Precio específico para esta entrada
  double precioVentaMayor; // Precio específico para esta entrada
  double? precioPaquete; // Precio específico para esta entrada
  String? lote; // Lote específico para esta entrada
  DateTime?
  fechaVencimiento; // Fecha de vencimiento específica para esta entrada
  String? observaciones; // Observaciones específicas para esta entrada

  ColorConCantidad({
    required this.color,
    this.cantidad = 1, // Metros por defecto
    this.unidades = 1, // Rollos/paquetes por defecto
    required this.precioCompra,
    required this.precioVentaMenor,
    required this.precioVentaMayor,
    this.precioPaquete,
    this.lote,
    this.fechaVencimiento,
    this.observaciones,
  });

  // Método copyWith para crear copias con algunos campos modificados
  ColorConCantidad copyWith({
    ColorProducto? color,
    int? cantidad,
    int? unidades,
    double? precioCompra,
    double? precioVentaMenor,
    double? precioVentaMayor,
    double? precioPaquete,
    String? lote,
    DateTime? fechaVencimiento,
    String? observaciones,
  }) {
    return ColorConCantidad(
      color: color ?? this.color,
      cantidad: cantidad ?? this.cantidad,
      unidades: unidades ?? this.unidades,
      precioCompra: precioCompra ?? this.precioCompra,
      precioVentaMenor: precioVentaMenor ?? this.precioVentaMenor,
      precioVentaMayor: precioVentaMayor ?? this.precioVentaMayor,
      precioPaquete: precioPaquete ?? this.precioPaquete,
      lote: lote ?? this.lote,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}
