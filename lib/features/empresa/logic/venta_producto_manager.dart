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
      // Buscar el tipo de producto
      final tipoProducto = _tiposProducto.firstWhere(
        (tipo) => tipo.id == producto.idTipoProducto,
        orElse: () => TipoProducto.empty(),
      );

      // Si el tipo requiere color
      if (tipoProducto.requiereColor) {
        // Obtener todos los colores activos
        final todosColores = (await _colorService.getColores())
            .where((c) => !c.deleted)
            .toList();

        // Si el producto tiene color asignado -> mostrar solo ese color
        _coloresDisponibles =
            (producto.idColor != null && producto.idColor!.isNotEmpty)
            ? todosColores.where((c) => c.id == producto.idColor).toList()
            : todosColores;
      }

      notifyListeners();
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

  // Método para obtener lotes de un producto específico por nombre y color
  Future<List<StockLoteTienda>> getLotesPorProductoColor(
    String nombreProducto,
    String colorNombre,
  ) async {
    try {
      // Filtrar los stocks de tienda que coincidan con el nombre y color
      final stocksTienda = _productosConStock
          .where(
            (s) => s.nombre == nombreProducto && s.colorNombre == colorNombre,
          )
          .toList();

      // Obtener los IDs de los stocks de tienda
      final idsStockTienda = stocksTienda.map((s) => s.id).toList();

      // Filtrar los lotes que pertenezcan a esos stocks de tienda
      final lotesFiltrados = _lotesDisponibles
          .where(
            (lote) =>
                idsStockTienda.contains(lote.idStockTienda) && !lote.deleted,
          )
          .toList();

      return lotesFiltrados;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Método para obtener unidades abiertas de un producto específico por nombre y color
  Future<List<StockUnidadAbierta>> getUnidadesAbiertasPorProductoColor(
    String nombreProducto,
    String colorNombre,
  ) async {
    try {
      // Primero obtenemos los lotes del producto
      final lotes = await getLotesPorProductoColor(nombreProducto, colorNombre);

      // Filtrar las unidades abiertas que pertenezcan a esos lotes
      final unidadesAbiertasFiltradas = <StockUnidadAbierta>[];

      for (var lote in lotes) {
        final unidadesDelLote = _unidadesAbiertasDisponibles
            .where(
              (u) =>
                  u.idStockLoteTienda == lote.id &&
                  !u.estaCerrada &&
                  !u.deleted,
            )
            .toList();

        unidadesAbiertasFiltradas.addAll(unidadesDelLote);
      }

      return unidadesAbiertasFiltradas;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Nuevo método para abrir una unidad
  Future<bool> abrirRollo(
    String idLote,
    String abiertoPor,
    String idTienda,
  ) async {
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
          await _unidadAbiertaManager.cargarUnidadesAbiertasPorTienda(idTienda);
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

  // Método para vender un rollo completo
  Future<bool> venderRollo(String idLote, int cantidad, String idTienda) async {
    try {
      // Obtener el lote actualizado desde el servidor
      final lote = await _loteManager.getLoteById(idLote);

      if (lote == null) {
        _error = 'No se encontró el lote';
        notifyListeners();
        return false;
      }

      // Verificar si hay suficiente stock
      if (lote.cantidadDisponible < cantidad) {
        _error = 'Stock insuficiente';
        notifyListeners();
        return false;
      }

      // Actualizar el lote
      final loteActualizado = lote.copyWith(
        cantidadVendida: lote.cantidadVendida + cantidad,
        cantidadDisponible: lote.cantidadDisponible - cantidad,
      );

      final resultado = await _loteManager.actualizarLote(loteActualizado);

      if (resultado) {
        // Recargar lotes
        await _loteManager.cargarLotesPorTienda(idTienda);
        _lotesDisponibles = _loteManager.lotes;
        return true;
      } else {
        _error = 'No se pudo actualizar el lote';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Método para vender por metro
  Future<bool> venderPorMetro(
    String idUnidadAbierta,
    int cantidad,
    String idTienda,
  ) async {
    try {
      // Obtener la unidad abierta actualizada desde el servidor
      final unidad = await _unidadAbiertaManager.getUnidadAbiertaById(
        idUnidadAbierta,
      );

      if (unidad == null) {
        _error = 'No se encontró la unidad abierta';
        notifyListeners();
        return false;
      }

      // Verificar si hay suficiente stock
      if (unidad.cantidadDisponible < cantidad) {
        _error = 'Stock insuficiente';
        notifyListeners();
        return false;
      }

      // Actualizar la unidad abierta
      final unidadActualizada = unidad.copyWith(
        cantidadVendida: unidad.cantidadVendida + cantidad,
        cantidadDisponible: unidad.cantidadDisponible - cantidad,
      );

      final resultado = await _unidadAbiertaManager.actualizarUnidadAbierta(
        unidadActualizada,
      );

      if (resultado) {
        // Recargar unidades abiertas
        await _unidadAbiertaManager.cargarUnidadesAbiertasPorTienda(idTienda);
        _unidadesAbiertasDisponibles = _unidadAbiertaManager.unidadesAbiertas;
        return true;
      } else {
        _error = 'No se pudo actualizar la unidad abierta';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Método para recargar los datos de un producto específico
  Future<void> recargarDatosProducto(
    String nombreProducto,
    String colorNombre,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Recargar lotes de la tienda
      await _loteManager.cargarLotesPorTienda(
        _productosConStock.first.idTienda,
      );
      _lotesDisponibles = _loteManager.lotes;

      // Recargar unidades abiertas de la tienda
      await _unidadAbiertaManager.cargarUnidadesAbiertasPorTienda(
        _productosConStock.first.idTienda,
      );
      _unidadesAbiertasDisponibles = _unidadAbiertaManager.unidadesAbiertas;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para obtener stocks de tienda de un producto específico por nombre y color
  Future<List<StockTienda>> getStocksTiendaPorProductoColor(
    String nombreProducto,
    String colorNombre,
    String idTienda,
  ) async {
    print("datos: " + nombreProducto + " " + colorNombre + " " + idTienda);
    try {
      // Filtrar los stocks de tienda que coincidan con el nombre y color

      print(_productosConStock.toString());
      final stocksTienda = _productosConStock
          .where(
            (s) => s.nombre == nombreProducto && s.colorNombre == colorNombre,
          )
          .toList();

      return stocksTienda;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Método para vender stock de tienda
  Future<bool> venderStockTienda(
    String idStockTienda,
    int cantidad,
    String idTienda,
  ) async {
    try {
      // Obtener el stock de tienda actualizado desde el servidor
      final stockTienda = await _stockTiendaService.getStockById(idStockTienda);

      if (stockTienda == null) {
        _error = 'No se encontró el stock de tienda';
        notifyListeners();
        return false;
      }

      // Verificar si hay suficiente stock
      if (stockTienda.cantidadDisponible < cantidad) {
        _error = 'Stock insuficiente';
        notifyListeners();
        return false;
      }

      // Actualizar el stock de tienda
      final stockTiendaActualizado = stockTienda.copyWith(
        cantidadVendida: stockTienda.cantidadVendida + cantidad,
      );

      final resultado = await _stockTiendaService.updateStockTienda(
        stockTiendaActualizado,
      );

      if (resultado) {
        // Recargar stocks de tienda
        await cargarDatosIniciales(idTienda);
        return true;
      } else {
        _error = 'No se pudo actualizar el stock de tienda';
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
