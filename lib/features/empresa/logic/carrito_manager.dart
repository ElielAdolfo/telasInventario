// lib/features/empresa/logic/carrito_manager.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/carrito_item_model.dart';

class CarritoManager extends ChangeNotifier {
  final List<CarritoItem> _items = [];
  final StreamController<int> _cantidadItemsController =
      StreamController<int>.broadcast();

  List<CarritoItem> get items => List.unmodifiable(_items);

  Stream<int> get cantidadItemsStream => _cantidadItemsController.stream;

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.cantidad);
  }

  double get total {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  void agregarItem(CarritoItem item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index].actualizarCantidad(_items[index].cantidad + item.cantidad);
    } else {
      _items.add(item);
    }
    notifyListeners();
    _cantidadItemsController.add(totalItems);
  }

  void agregarUnidadCompleta(CarritoItem item, String idStockLoteTienda) {
    final itemConTipo = item.copyWith(
      tipoVenta: 'UNIDAD_COMPLETA',
      idStockLoteTienda: idStockLoteTienda,
    );
    agregarItem(itemConTipo);
  }

  void agregarPorMetro(CarritoItem item, String idStockUnidadAbierta) {
    final itemConTipo = item.copyWith(
      tipoVenta: 'UNIDAD_ABIERTA',
      idStockUnidadAbierta: idStockUnidadAbierta,
    );
    agregarItem(itemConTipo);
  }

  void actualizarCantidad(String id, int nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      removerItem(id);
      return;
    }

    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].actualizarCantidad(nuevaCantidad);
      notifyListeners();
      _cantidadItemsController.add(totalItems);
    }
  }

  void removerItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    _cantidadItemsController.add(totalItems);
  }

  void vaciarCarrito() {
    _items.clear();
    notifyListeners();
    _cantidadItemsController.add(0);
  }

  @override
  void dispose() {
    _cantidadItemsController.close();
    super.dispose();
  }
}
