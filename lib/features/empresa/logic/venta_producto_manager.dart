// lib/features/empresa/logic/venta_producto_manager.dart

import 'package:flutter/material.dart';
import '../models/stock_empresa_model.dart';
import '../models/color_model.dart';
import '../models/tipo_producto_model.dart';
import '../models/carrito_item_model.dart';
import '../models/stock_tienda_model.dart';
import '../models/stock_lote_tienda_model.dart';
import '../models/stock_unidad_abierta_model.dart';
import '../services/stock_empresa_service.dart';
import '../services/color_service.dart';
import '../services/tipo_producto_service.dart';
import '../services/stock_tienda_service.dart';
import 'stock_lote_tienda_manager.dart';
import 'stock_unidad_abierta_manager.dart';

class VentaProductoManager extends ChangeNotifier {
  final StockTiendaService _stockTiendaService = StockTiendaService();
  final ColorService _colorService = ColorService();
  final TipoProductoService _tipoProductoService = TipoProductoService();
  final StockLoteTiendaManager _loteManager = StockLoteTiendaManager();
  final StockUnidadAbiertaManager _unidadAbiertaManager =
      StockUnidadAbiertaManager();

  List<StockTienda> _productosConStock = [];
  List<ColorProducto> _coloresDisponibles = [];
  List<TipoProducto> _tiposProducto = [];
  List<StockLoteTienda> _lotesDisponibles = [];
  List<StockUnidadAbierta> _unidadesAbiertasDisponibles = [];
  StockTienda? _productoSeleccionado;
  bool _isLoading = true;
  String? _error;

  List<StockTienda> get productosConStock => _productosConStock;
  List<ColorProducto> get coloresDisponibles => _coloresDisponibles;
  List<TipoProducto> get tiposProducto => _tiposProducto;
  List<StockLoteTienda> get lotesDisponibles => _lotesDisponibles;
  List<StockUnidadAbierta> get unidadesAbiertasDisponibles =>
      _unidadesAbiertasDisponibles;
  StockTienda? get productoSeleccionado => _productoSeleccionado;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarDatosIniciales(String tiendaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cargar productos con stock de la tienda
      _productosConStock = await _stockTiendaService.getStockByTienda(tiendaId);
      _productosConStock = _productosConStock
          .where((stock) => stock.cantidadDisponible > 0)
          .toList();

      // Cargar tipos de producto
      _tiposProducto = await _tipoProductoService.getTiposProductoByEmpresa(
        _productosConStock.isNotEmpty ? _productosConStock.first.idEmpresa : '',
      );

      // Cargar lotes de la tienda
      await _loteManager.cargarLotesPorTienda(tiendaId);
      _lotesDisponibles = _loteManager.lotes;

      // Cargar unidades abiertas de la tienda
      await _unidadAbiertaManager.cargarUnidadesAbiertasPorTienda(tiendaId);
      _unidadesAbiertasDisponibles = _unidadAbiertaManager.unidadesAbiertas;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> seleccionarProducto(StockTienda producto) async {
    _productoSeleccionado = producto;
    _coloresDisponibles = [];
    notifyListeners();

    try {
      // Verificar si el producto requiere color
      final tipoProducto = _tiposProducto.firstWhere(
        (tipo) => tipo.id == producto.idTipoProducto,
        orElse: () => TipoProducto.empty(),
      );

      if (tipoProducto.requiereColor) {
        // Cargar todos los colores
        final todosColores = await _colorService.getColores();

        if (producto.idColor != null && producto.idColor!.isNotEmpty) {
          // Filtrar solo el color del producto
          _coloresDisponibles = todosColores
              .where((c) => c.id == producto.idColor && !c.deleted)
              .toList();
        } else {
          // Mostrar todos los colores si no hay uno asignado
          _coloresDisponibles = todosColores.where((c) => !c.deleted).toList();
        }
      }
      // Si no requiere color, dejamos la lista vacía
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  String getNombreProducto(String idTipoProducto) {
    final tipo = _tiposProducto.firstWhere(
      (tipo) => tipo.id == idTipoProducto,
      orElse: () => TipoProducto.empty(),
    );
    return tipo.nombre;
  }

  void limpiarSeleccion() {
    _productoSeleccionado = null;
    _coloresDisponibles = [];
    notifyListeners();
  }

  // Nuevo método para abrir una unidad
  Future<bool> abrirUnidad(String idLote, String abiertoPor) async {
    try {
      final lote = _lotesDisponibles.firstWhere((l) => l.id == idLote);

      // Verificar si hay unidades disponibles para abrir
      if (lote.cantidadDisponible < 1) {
        _error = 'No hay unidades disponibles para abrir';
        notifyListeners();
        return false;
      }

      // Verificar si ya hay unidades abiertas
      final unidadesAbiertasDelLote = _unidadesAbiertasDisponibles
          .where((u) => u.idStockLoteTienda == idLote && !u.estaCerrada)
          .toList();

      if (unidadesAbiertasDelLote.isNotEmpty) {
        _error = 'Ya hay una unidad abierta de este lote';
        notifyListeners();
        return false;
      }

      // Abrir la unidad
      final idUnidad = await _unidadAbiertaManager.abrirUnidad(
        idLote,
        lote.cantidadPorUnidad,
        abiertoPor,
      );

      if (idUnidad.isNotEmpty) {
        // Actualizar el lote
        final loteActualizado = lote.copyWith(
          unidadesAbiertas: lote.unidadesAbiertas + 1,
        );

        final resultado = await _loteManager.actualizarLote(loteActualizado);

        if (resultado) {
          // Recargar unidades abiertas
          await _unidadAbiertaManager.cargarUnidadesAbiertasPorTienda(
            lote.idStockTienda,
          );
          _unidadesAbiertasDisponibles = _unidadAbiertaManager.unidadesAbiertas;
          return true;
        } else {
          _error = 'No se pudo actualizar el lote';
          notifyListeners();
          return false;
        }
      } else {
        _error = 'No se pudo abrir la unidad';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
