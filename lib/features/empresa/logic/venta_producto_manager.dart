// lib/features/empresa/logic/venta_producto_manager.dart

import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/services/stock_lote_tienda_service.dart';
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
import '../services/stock_tienda_service.dart';

class VentaProductoManager extends ChangeNotifier {
  final StockTiendaService _stockTiendaService = StockTiendaService();
  final ColorService _colorService = ColorService();
  final TipoProductoService _tipoProductoService = TipoProductoService();
  final StockLoteTiendaManager _loteManager = StockLoteTiendaManager();
  final StockUnidadAbiertaManager _unidadAbiertaManager =
      StockUnidadAbiertaManager();

  final StockLoteTiendaService _stockLoteTiendaService =
      StockLoteTiendaService();

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

  Future<bool> cerrarLote(String idLote, String cerradoPor) async {
    try {
      // Obtener el lote actualizado
      final lote = await _stockLoteTiendaService.getLoteById(idLote);

      if (lote == null) {
        _error = 'No se encontró el lote';
        notifyListeners();
        return false;
      }

      // Actualizar el lote como cerrado
      final loteActualizado = lote.copyWith(
        estaCerrada: true,
        fechaCierre: DateTime.now(),
        cerradoPor: cerradoPor,
      );

      final resultado = await _stockLoteTiendaService.updateLote(
        loteActualizado,
      );

      if (resultado) {
        return true;
      } else {
        _error = 'No se pudo cerrar el lote';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

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

  // Método para obtener unidades abiertas de un producto específico por nombre y color
  Future<List<StockUnidadAbierta>> getUnidadesAbiertasPorProductoColor(
    String nombreProducto,
    String colorNombre,
    tiendaId,
  ) async {
    try {
      // Primero obtenemos los lotes del producto
      final lotes = await getLotesPorProductoColor(
        nombreProducto,
        colorNombre,
        tiendaId,
      );

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

  /*Future<bool> abrirRollo(
    String idStockTienda,
    String abiertoPor,
    String idTienda,
  ) async {
    try {
      // Obtener el stock de tienda actualizado
      final stockTienda = await _stockTiendaService.getStockById(idStockTienda);

      if (stockTienda == null) {
        _error = 'No se encontró el stock de tienda';
        notifyListeners();
        return false;
      }

      // Verificar si hay stock disponible para abrir
      if (stockTienda.cantidadDisponible < 1) {
        _error = 'No hay stock disponible para abrir';
        notifyListeners();
        return false;
      }

      // Crear un nuevo lote para el rollo abierto
      final nuevoLote = StockLoteTienda(
        id: '', // El ID será generado por Firebase
        idStockTienda: idStockTienda,
        cantidad: stockTienda.cantidadPrioritaria,
        cantidadVendida: 0,
        fechaApertura: DateTime.now(),
        abiertoPor: abiertoPor,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Registrar el nuevo lote
      final idLote = await _stockLoteTiendaService.createStockLoteTienda(
        nuevoLote,
      );

      if (idLote.isNotEmpty) {
        // Actualizar el stock de tienda
        final stockActualizado = stockTienda.copyWith(
          cantidadAperturada: stockTienda.cantidadAperturada + 1,
        );

        final resultado = await _stockTiendaService.updateStockTienda(
          stockActualizado,
        );

        if (resultado) {
          // Recargar datos
          await cargarDatosIniciales(idTienda);
          return true;
        } else {
          _error = 'No se pudo actualizar el stock de tienda';
          notifyListeners();
          return false;
        }
      } else {
        _error = 'No se pudo crear el lote';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
*/
  // Método para vender por metro
  Future<bool> venderPorMetro(
    String idLote,
    int cantidad,
    String idTienda,
  ) async {
    try {
      // Obtener el lote actualizado
      final lote = await _stockLoteTiendaService.getLoteById(idLote);

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
      );

      /*final resultado = await _stockLoteTiendaService.updateStockLoteTienda(
        loteActualizado,
      );

      if (resultado) {
        // Recargar datos
        await cargarDatosIniciales(idTienda);
        return true;
      } else {
        _error = 'No se pudo actualizar el lote';
        notifyListeners();
        return false;
      }*/
      return false;
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

  // Modificar el método getStocksTiendaPorProductoColor
  Future<List<StockTienda>> getStocksTiendaPorProductoColor(
    String nombreProducto,
    String colorNombre,
    String idTienda,
  ) async {
    try {
      print(
        "Buscando stocks para: $nombreProducto, color: $colorNombre, tienda: $idTienda",
      );

      // Obtener todos los stocks de tienda para el producto y color
      final stocksTienda = _productosConStock
          .where(
            (s) => s.nombre == nombreProducto && s.colorNombre == colorNombre,
          )
          .toList();

      // Si no hay stocks, devolver lista vacía
      if (stocksTienda.isEmpty) {
        print(
          "No se encontraron stocks de tienda para el producto y color especificados",
        );
        return [];
      }

      // Obtener todos los lotes de la tienda para el producto y color
      final List<StockLoteTienda> todosLotes = [];
      for (var stock in stocksTienda) {
        final lotes = await _stockLoteTiendaService.getLotesByStockTienda(
          stock.id,
        );
        todosLotes.addAll(lotes);
      }

      // Crear un mapa para saber qué stocks tienen lotes abiertos
      final Map<String, bool> stockTieneLoteAbierto = {};
      for (var lote in todosLotes) {
        if (!lote.estaCerrada) {
          // Si el lote está abierto
          stockTieneLoteAbierto[lote.idStockTienda] = true;
        }
      }

      // Filtrar solo los stocks que NO tienen lotes abiertos
      final stocksFiltrados = stocksTienda.where((stock) {
        return !stockTieneLoteAbierto.containsKey(stock.id);
      }).toList();

      print("Stocks filtrados (no abiertos): ${stocksFiltrados.length}");
      return stocksFiltrados;
    } catch (e) {
      print("Error en getStocksTiendaPorProductoColor: $e");
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Asegurar que getLotesPorProductoColor solo devuelva lotes abiertos
  Future<List<StockLoteTienda>> getLotesPorProductoColor(
    String nombreProducto,
    String colorNombre,
    String tiendaId,
  ) async {
    try {
      print(
        "Buscando lotes para producto: $nombreProducto, color: $colorNombre, tienda: $tiendaId",
      );

      // Obtener stocks de tienda para la tienda específica
      final stocksTienda = await _stockTiendaService.getStockByTienda(tiendaId);

      // Filtrar los stocks de tienda que coincidan con el nombre y color
      final stocksFiltrados = stocksTienda
          .where(
            (s) => s.nombre == nombreProducto && s.colorNombre == colorNombre,
          )
          .toList();

      if (stocksFiltrados.isEmpty) {
        print(
          "No se encontraron stocks de tienda para el producto y color especificados",
        );
        return [];
      }

      // Obtener los IDs de los stocks de tienda filtrados
      final idsStockTienda = stocksFiltrados.map((s) => s.id).toList();

      // Obtener todos los lotes disponibles
      final List<StockLoteTienda> todosLotes = [];

      for (String idStockTienda in idsStockTienda) {
        final lotes = await _stockLoteTiendaService.getLotesByStockTienda(
          idStockTienda,
        );
        todosLotes.addAll(lotes);
      }

      // Filtrar los lotes que estén abiertos y tengan stock disponible
      final lotesFiltrados = todosLotes
          .where((lote) => !lote.estaCerrada && lote.cantidadDisponible > 0)
          .toList();

      print("Lotes filtrados (abiertos): ${lotesFiltrados.length}");
      return lotesFiltrados;
    } catch (e) {
      print("Error en getLotesPorProductoColor: $e");
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

  Future<bool> abrirUnidad(
    String idStockTienda,
    double cantidad,
    String abiertoPor,
    String idTienda,
    String? codigoUnico,
    String idTipoProducto, // ✅ Nuevo campo
    String idEmpresa, // ✅ Nuevo campo
    String? idColor,
    double metraje,

    double precioCompra,
    double precioVentaMenor,
    double precioVentaMayor,
    double precioPaquete,
    String idMoneda,
    double tipoCambio,
  ) async {
    try {
      // Obtener el stock de tienda actualizado
      final stockTienda = await _stockTiendaService.getStockById(idStockTienda);

      if (stockTienda == null) {
        _error = 'No se encontró el stock de tienda';
        notifyListeners();
        return false;
      }

      // Verificar si hay stock disponible para abrir
      if (stockTienda.cantidadDisponible < cantidad) {
        _error =
            'Stock insuficiente.... Disponible: ${stockTienda.cantidadDisponible}';
        notifyListeners();
        return false;
      }

      // Crear un nuevo lote para cada unidad abierta
      for (int i = 0; i < cantidad; i++) {
        final nuevoLote = StockLoteTienda(
          id: '', // El ID será generado por Firebase
          idStockTienda: idStockTienda,
          cantidad: metraje,
          cantidadVendida: 0,
          fechaApertura: DateTime.now(),
          abiertoPor: abiertoPor,
          estaCerrada: false,
          deleted: false,
          createdAt: DateTime.now(),
          codigoUnico: codigoUnico,
          updatedAt: DateTime.now(),
          idTipoProducto: idTipoProducto,
          idEmpresa: idEmpresa,
          idTienda: idTienda,
          idColor: idColor,
          precioCompra: precioCompra,
          precioPaquete: precioPaquete,
          precioVentaMayor: precioVentaMayor,
          precioVentaMenor: precioVentaMenor,
          idMoneda: idMoneda,
          tipoCambio: tipoCambio,
        );

        // Registrar el nuevo lote
        final idLote = await _stockLoteTiendaService.createLote(nuevoLote);

        if (idLote.isEmpty) {
          _error = 'No se pudo crear el lote';
          notifyListeners();
          return false;
        }
      }

      // Actualizar el stock de tienda
      final stockActualizado = stockTienda.copyWith(
        cantidadAperturada: stockTienda.cantidadAperturada + cantidad,
      );

      final resultado = await _stockTiendaService.updateStockTienda(
        stockActualizado,
      );

      if (resultado) {
        // Recargar datos
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
