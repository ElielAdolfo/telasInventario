// lib/features/empresa/logic/carrito_manager.dart
import 'package:flutter/material.dart';
import '../models/carrito_item_model.dart';
import '../services/carrito_persistence_service.dart';

class CarritoManager extends ChangeNotifier {
  final List<CarritoItem> _items = [];
  final CarritoPersistenceService _persistenceService = CarritoPersistenceService();
  bool _isLoading = false;
  String? _error;

  List<CarritoItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalItems => _items.fold(0, (sum, item) => sum + item.cantidad);

  double get total =>
      _items.fold(0, (sum, item) => sum + (item.precio * item.cantidad));

  // Cargar items del carrito desde Firebase
  Future<void> cargarCarrito(String idUsuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items.clear();
      _items.addAll(await _persistenceService.obtenerItemsCarrito(idUsuario));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar item al carrito (y a Firebase)
  Future<void> agregarUnidadCompleta(CarritoItem item, String idStockTienda) async {
    try {
      await _persistenceService.agregarItemAlCarrito(item);
      _items.add(item);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> agregarUnidadAbierta(CarritoItem item, String idStockTienda) async {
    try {
      await _persistenceService.agregarItemAlCarrito(item);
      _items.add(item);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Actualizar cantidad de un item
  Future<void> actualizarCantidad(String id, double nuevaCantidad) async {
    try {
      await _persistenceService.actualizarCantidadItem(id, nuevaCantidad);
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(cantidad: nuevaCantidad);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Eliminar un item
  Future<void> removerItem(String id) async {
    try {
      await _persistenceService.eliminarItemCarrito(id);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Vaciar carrito (marcar items como vendidos)
  Future<void> vaciarCarrito() async {
    try {
      final itemIds = _items.map((item) => item.id).toList();
      await _persistenceService.marcarItemsComoVendidos(itemIds);
      _items.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}