// lib/features/empresa/logic/carrito_manager.dart

import 'package:flutter/material.dart';
import '../models/carrito_item_model.dart';

class CarritoManager extends ChangeNotifier {
  List<CarritoItem> _items = [];

  List<CarritoItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.cantidad);

  double get total =>
      _items.fold(0, (sum, item) => sum + (item.precio * item.cantidad));

  void agregarUnidadCompleta(CarritoItem item, String idStockTienda) {
    _items.add(item);
    notifyListeners();
  }

  void agregarUnidadAbierta(CarritoItem item, String idStockTienda) {
    _items.add(item);
    notifyListeners();
  }

  void agregarPorMetro(CarritoItem item, String idUnidadAbierta) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Método para actualizar la cantidad de un item
  void actualizarCantidad(String id, int nuevaCantidad) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(cantidad: nuevaCantidad);
      notifyListeners();
    }
  }

  // Método para remover un item (renombrado para coincidir con el código)
  void removerItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void vaciarCarrito() {
    _items.clear();
    notifyListeners();
  }
}
