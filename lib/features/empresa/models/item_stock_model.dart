// Modelo para representar un item individual de stock
import 'package:inventario/features/empresa/models/color_model.dart';

class ItemStock {
  final String id;
  final String codigo;
  final ColorProducto color;
  final double metraje;
  final double precioCompra;
  final double precioVentaMenor;
  final double precioVentaMayor;
  final double? precioPaquete;
  final String? lote;
  final DateTime? fechaVencimiento;
  final String? observaciones;

  ItemStock({
    required this.id,
    required this.codigo,
    required this.color,
    required this.metraje,
    required this.precioCompra,
    required this.precioVentaMenor,
    required this.precioVentaMayor,
    this.precioPaquete,
    this.lote,
    this.fechaVencimiento,
    this.observaciones,
  });

  ItemStock copyWith({
    String? id,
    String? codigo,
    ColorProducto? color,
    double? metraje,
    double? precioCompra,
    double? precioVentaMenor,
    double? precioVentaMayor,
    double? precioPaquete,
    String? lote,
    DateTime? fechaVencimiento,
    String? observaciones,
  }) {
    return ItemStock(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      color: color ?? this.color,
      metraje: metraje ?? this.metraje,
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
