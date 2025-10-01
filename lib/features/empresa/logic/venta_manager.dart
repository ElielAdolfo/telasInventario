// lib/features/empresa/logic/venta_manager.dart

import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/services/stock_lote_tienda_service.dart';
import 'package:inventario/features/empresa/services/stock_tienda_service.dart';
import '../services/venta_service.dart';
import '../models/venta_model.dart';

class VentaManager extends ChangeNotifier {
  final VentaService _ventaService = VentaService();
  final StockTiendaService _stockTiendaService = StockTiendaService();
  final StockLoteTiendaService _stockLoteTiendaService =
      StockLoteTiendaService();

  List<Venta> _ventas = [];
  bool _isLoading = false;
  String? _error;

  List<Venta> get ventas => _ventas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVentasByTienda(String idTienda) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ventas = await _ventaService.getVentasByTienda(idTienda);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registrarVenta(Venta venta) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Generar un ID único para la venta
      final nuevaVenta = Venta(
        id: '', // El ID será asignado por Firebase
        idTienda: venta.idTienda,
        idEmpresa: venta.idEmpresa,
        fechaVenta: venta.fechaVenta,
        total: venta.total,
        realizadoPor: venta.realizadoPor,
        items: venta.items,
        deleted: false,
        updatedAt: DateTime.now().toIso8601String(),
      );

      // Registrar la venta
      final idVenta = await _ventaService.createVenta(nuevaVenta);

      if (idVenta.isNotEmpty) {
        // Actualizar el stock de cada item vendido
        for (var item in venta.items) {
          if (item.tipoVenta == 'UNIDAD_COMPLETA' &&
              item.idStockTienda != null) {
            // Obtener el stock actual
            final stockTienda = await _stockTiendaService.getStockById(
              item.idStockTienda!,
            );

            if (stockTienda != null) {
              // Actualizar la cantidad vendida
              final stockActualizado = stockTienda.copyWith(
                cantidadVendida: stockTienda.cantidadVendida + item.cantidad,
              );

              // Guardar los cambios
              await _stockTiendaService.updateStockTienda(stockActualizado);
            }
          } else if (item.tipoVenta == 'UNIDAD_ABIERTA' &&
              item.idStockLoteTienda != null) {
            print(
              'DEBUG item: tipo=${item.tipoVenta}, '
              'idStockTienda=${item.idStockTienda}, '
              'idStockLoteTienda=${item.idStockLoteTienda}, '
              'idStockUnidadAbierta=${item.idStockUnidadAbierta}',
            );
            //debemos buscar el lote i actualizar la cantidad vendida
            final stockLote = await _stockLoteTiendaService.getStockLoteById(
              item.idStockLoteTienda!,
            );
            if (stockLote != null) {
              // Actualizamos la cantidadVendida
              final stockActualizado = stockLote.copyWith(
                cantidadVendida: stockLote.cantidadVendida + item.cantidad,
              );

              // Guardamos en Firebase
              await _stockLoteTiendaService.updateStockLoteTienda(
                stockActualizado,
              );

              print(
                '✅ STOCK LOTE ACTUALIZADO: ${item.idStockLoteTienda} '
                'nueva cantidadVendida = ${stockActualizado.cantidadVendida}',
              );
            } else {
              print(
                '⚠️ No se encontró el lote con ID ${item.idStockLoteTienda}',
              );
            }
          }
        }

        // Actualizar la lista de ventas
        await loadVentasByTienda(venta.idTienda);
        return true;
      } else {
        _error = 'No se pudo registrar la venta';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
