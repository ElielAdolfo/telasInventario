// lib/features/producto/logic/producto_manager.dart
import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../services/producto_service.dart';

class ProductoManager with ChangeNotifier {
  final ProductoService _service = ProductoService();
  List<Producto> _productos = [];
  bool _isLoading = false;
  String? _error;

  List<Producto> get productos => _productos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar todos los productos
  Future<void> loadProductos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _productos = await _service.getProductos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar productos por tipo de producto
  Future<void> loadProductosByTipo(String idTipoProducto) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _productos = await _service.getProductosByTipo(idTipoProducto);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar un nuevo producto
  Future<void> addProducto(Producto producto) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createProducto(producto);
      await loadProductosByTipo(producto.idTipoProducto);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar un producto existente
  Future<void> updateProducto(Producto producto) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateProducto(producto);
      await loadProductosByTipo(producto.idTipoProducto);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eliminar un producto (eliminación lógica)
  Future<void> deleteProducto(String id, String idTipoProducto) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteProducto(id);
      await loadProductosByTipo(idTipoProducto);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener un producto por su ID
  Future<Producto?> getProductoById(String id) async {
    return await _service.getProductoById(id);
  }

  // Stream para todos los productos
  Stream<List<Producto>> get productosStream => _service.productosStream();

  // Stream para productos por tipo
  Stream<List<Producto>> productosByTipoStream(String idTipoProducto) {
    return _service.productosByTipoStream(idTipoProducto);
  }

  // Obtener productos por color
  List<Producto> getProductosByColor(String idColor) {
    return _productos.where((producto) => producto.idColor == idColor).toList();
  }

  // Obtener productos por tipo y color
  List<Producto> getProductosByTipoYColor(
    String idTipoProducto,
    String idColor,
  ) {
    return _productos
        .where(
          (producto) =>
              producto.idTipoProducto == idTipoProducto &&
              producto.idColor == idColor,
        )
        .toList();
  }

  // Verificar si un producto existe por nombre
  bool existsProductoByNombre(String nombre, {String? idTipoProducto}) {
    return _productos.any(
      (producto) =>
          producto.nombre.toLowerCase() == nombre.toLowerCase() &&
          (idTipoProducto == null || producto.idTipoProducto == idTipoProducto),
    );
  }

  // Buscar productos por nombre o descripción
  List<Producto> searchProductos(String query, {String? idTipoProducto}) {
    final queryLower = query.toLowerCase();
    return _productos
        .where(
          (producto) =>
              (idTipoProducto == null ||
                  producto.idTipoProducto == idTipoProducto) &&
              (producto.nombre.toLowerCase().contains(queryLower) ||
                  producto.descripcion.toLowerCase().contains(queryLower)),
        )
        .toList();
  }

  // Obtener productos con precio en un rango
  List<Producto> getProductosByRangoPrecio(
    double min,
    double max, {
    String? idTipoProducto,
  }) {
    return _productos
        .where(
          (producto) =>
              (idTipoProducto == null ||
                  producto.idTipoProducto == idTipoProducto) &&
              producto.precioUnitario >= min &&
              producto.precioUnitario <= max,
        )
        .toList();
  }

  // Obtener productos ordenados por precio (ascendente o descendente)
  List<Producto> getProductosOrdenadosPorPrecio({
    bool ascendente = true,
    String? idTipoProducto,
  }) {
    var productosFiltrados = idTipoProducto != null
        ? _productos.where((p) => p.idTipoProducto == idTipoProducto).toList()
        : List<Producto>.from(_productos);

    productosFiltrados.sort(
      (a, b) => ascendente
          ? a.precioUnitario.compareTo(b.precioUnitario)
          : b.precioUnitario.compareTo(a.precioUnitario),
    );

    return productosFiltrados;
  }

  // Obtener productos con stock disponible (asumiendo que hay un campo de stock)
  List<Producto> getProductosConStock({String? idTipoProducto}) {
    // Nota: Este método asume que el modelo Producto tiene un campo 'stock'
    // Si no, deberás ajustarlo según tu modelo de datos
    return _productos
        .where(
          (producto) =>
              (idTipoProducto == null ||
              producto.idTipoProducto == idTipoProducto),
          // && producto.stock > 0  // Descomenta si tienes el campo stock
        )
        .toList();
  }

  // Calcular el precio promedio de los productos
  double getPrecioPromedio({String? idTipoProducto}) {
    final productosFiltrados = idTipoProducto != null
        ? _productos.where((p) => p.idTipoProducto == idTipoProducto).toList()
        : _productos;

    if (productosFiltrados.isEmpty) return 0.0;

    final total = productosFiltrados.fold(
      0.0,
      (sum, producto) => sum + producto.precioUnitario,
    );
    return total / productosFiltrados.length;
  }

  // Obtener el producto más caro
  Producto? getProductoMasCaro({String? idTipoProducto}) {
    final productosFiltrados = idTipoProducto != null
        ? _productos.where((p) => p.idTipoProducto == idTipoProducto).toList()
        : _productos;

    if (productosFiltrados.isEmpty) return null;

    return productosFiltrados.reduce(
      (a, b) => a.precioUnitario > b.precioUnitario ? a : b,
    );
  }

  // Obtener el producto más barato
  Producto? getProductoMasBarato({String? idTipoProducto}) {
    final productosFiltrados = idTipoProducto != null
        ? _productos.where((p) => p.idTipoProducto == idTipoProducto).toList()
        : _productos;

    if (productosFiltrados.isEmpty) return null;

    return productosFiltrados.reduce(
      (a, b) => a.precioUnitario < b.precioUnitario ? a : b,
    );
  }

  // Obtener estadísticas de productos por tipo
  Map<String, dynamic> getEstadisticasPorTipo(String idTipoProducto) {
    final productosTipo = _productos
        .where((p) => p.idTipoProducto == idTipoProducto)
        .toList();

    if (productosTipo.isEmpty) {
      return {
        'total': 0,
        'precioPromedio': 0.0,
        'precioMin': 0.0,
        'precioMax': 0.0,
      };
    }

    final precios = productosTipo.map((p) => p.precioUnitario).toList();
    precios.sort();

    return {
      'total': productosTipo.length,
      'precioPromedio': precios.reduce((a, b) => a + b) / precios.length,
      'precioMin': precios.first,
      'precioMax': precios.last,
    };
  }

  // Limpiar el error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refrescar los productos
  Future<void> refreshProductos({String? idTipoProducto}) async {
    if (idTipoProducto != null) {
      await loadProductosByTipo(idTipoProducto);
    } else {
      await loadProductos();
    }
  }

  // Agregar múltiples productos a la vez
  Future<void> addMultipleProductos(List<Producto> productos) async {
    _isLoading = true;
    notifyListeners();

    try {
      for (var producto in productos) {
        await _service.createProducto(producto);
      }

      // Recargar productos del primer tipo (asumiendo que todos son del mismo tipo)
      if (productos.isNotEmpty) {
        await loadProductosByTipo(productos.first.idTipoProducto);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar precios de múltiples productos
  Future<void> updatePreciosProductos(
    Map<String, double> preciosActualizados,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      for (var entry in preciosActualizados.entries) {
        final producto = _productos.firstWhere((p) => p.id == entry.key);
        final productoActualizado = producto.copyWith(
          precioUnitario: entry.value,
          precioCompleto:
              entry.value * producto.cantidadPorEmpaque, // Ajustar según lógica
        );
        await _service.updateProducto(productoActualizado);
      }

      // Recargar productos del tipo del primer producto actualizado
      if (preciosActualizados.isNotEmpty) {
        final primerProducto = _productos.firstWhere(
          (p) => p.id == preciosActualizados.keys.first,
        );
        await loadProductosByTipo(primerProducto.idTipoProducto);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
