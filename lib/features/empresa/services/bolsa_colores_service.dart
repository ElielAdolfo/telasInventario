// lib/features/stock/services/bolsa_colores_service.dart

import 'package:inventario/features/empresa/services/base_service.dart';
import '../models/bolsa_colores_model.dart';
import '../models/stock_empresa_model.dart';
import 'stock_empresa_service.dart';

class BolsaColoresService extends BaseService {
  final StockEmpresaService _stockService = StockEmpresaService();

  BolsaColoresService() : super('bolsa_colores');

  Future<void> procesarBolsaColores(
    BolsaColores bolsa,
    String idEmpresa,
    String userId,
    // Campos adicionales del TipoProducto
    String categoria,
    String nombre,
    String unidadMedida,
    String? unidadMedidaSecundaria,
    bool permiteVentaParcial,
    bool requiereColor,
    List<double> cantidadesPosibles,
    double cantidadPrioritaria,
  ) async {
    // Procesar cada entrada individualmente con sus propios atributos
    for (var entrada in bolsa.entradas) {
      final stock = StockEmpresa(
        id: '',
        idEmpresa: idEmpresa,
        idTipoProducto: bolsa.idTipoProducto,
        idColor: entrada.color.id,
        cantidad: entrada.cantidad, // Metros por rollo
        cantidadReservado: 0,
        cantidadAprobado: 0,
        unidades: entrada.unidades, // Número de rollos
        precioCompra: entrada.precioCompra,
        precioVentaMenor: entrada.precioVentaMenor,
        precioVentaMayor: entrada.precioVentaMayor,
        precioPaquete: entrada.precioPaquete,
        fechaIngreso: DateTime.now(),
        lote: entrada.lote,
        fechaVencimiento: entrada.fechaVencimiento,
        observaciones: entrada.observaciones ?? bolsa.observaciones,
        deleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // Campos adicionales del TipoProducto
        categoria: categoria,
        nombre: nombre,
        unidadMedida: unidadMedida,
        unidadMedidaSecundaria: unidadMedidaSecundaria,
        permiteVentaParcial: permiteVentaParcial,
        requiereColor: requiereColor,
        cantidadesPosibles: cantidadesPosibles,
        cantidadPrioritaria: cantidadPrioritaria,
        createdBy: userId,
        updatedBy: userId,
        deletedBy: null,
        deletedAt: null,
      );

      await _stockService.createStockEmpresa(stock, userId);
    }
  }
}