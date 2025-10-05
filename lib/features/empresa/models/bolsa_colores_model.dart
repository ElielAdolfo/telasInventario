// lib/features/stock/models/bolsa_colores_model.dart

import 'package:inventario/features/empresa/models/color_con_cantidad_model.dart';

class BolsaColores {
  final String idTipoProducto;
  final List<ColorConCantidad>
  entradas; // Lista de entradas con todos sus atributos
  final String? observaciones; // Observaciones globales (si las hay)

  BolsaColores({
    required this.idTipoProducto,
    required this.entradas,
    this.observaciones,
  });
}
