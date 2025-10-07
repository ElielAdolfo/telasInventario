// lib/features/stock/logic/stock_empresa_manager.dart

import 'package:flutter/material.dart';
import '../models/stock_empresa_model.dart';
import '../services/stock_empresa_service.dart';

class StockEmpresaManager with ChangeNotifier {
  final StockEmpresaService _service = StockEmpresaService();
  List<StockEmpresa> _stockEmpresa = [];
  bool _isLoading = false;
  String? _error;

  List<StockEmpresa> get stockEmpresa => _stockEmpresa;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStockByEmpresa(String idEmpresa) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stockEmpresa = await _service.getStockByEmpresa(idEmpresa);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStockEmpresa(StockEmpresa stock, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createStockEmpresa(stock, userId);
      await loadStockByEmpresa(stock.idEmpresa);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStockEmpresa(StockEmpresa stock) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateStockEmpresa(stock);
      await loadStockByEmpresa(stock.idEmpresa);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteStockEmpresa(String id, String idEmpresa) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteStockEmpresa(id);
      await loadStockByEmpresa(idEmpresa);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NUEVOS MÉTODOS PARA GESTIÓN DE RESERVAS

  // Método para reservar stock
  Future<bool> reservarStock(String stockId, int cantidad) async {
    try {
      final stock = _stockEmpresa.firstWhere((s) => s.id == stockId);

      // Verificar si hay suficiente disponible
      if (stock.cantidadDisponible < cantidad) {
        _error =
            'Stock insuficiente.. Disponible: ${stock.cantidadDisponible}, Solicitado: $cantidad';
        notifyListeners();
        return false;
      }

      // Actualizar el stock reservado
      final stockActualizado = stock.copyWith(
        cantidadReservado: stock.cantidadReservado + cantidad,
      );

      // Guardar en la base de datos
      final resultado = await _service.updateStockEmpresa(stockActualizado);
      if (!resultado) {
        _error = 'No se pudo actualizar el stock';
        notifyListeners();
        return false;
      }

      // Actualizar en la lista local
      final index = _stockEmpresa.indexWhere((s) => s.id == stockId);
      if (index != -1) {
        _stockEmpresa[index] = stockActualizado;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Método para aprobar reserva (mover de reservado a aprobado)
  Future<bool> aprobarReserva(String stockId, int cantidad) async {
    try {
      final stock = _stockEmpresa.firstWhere((s) => s.id == stockId);

      // Verificar si hay suficiente reservado
      if (stock.cantidadReservado < cantidad) {
        _error =
            'No hay suficiente stock reservado. Reservado: ${stock.cantidadReservado}, Solicitado: $cantidad';
        notifyListeners();
        return false;
      }

      // Actualizar el stock: disminuir reservado y aumentar aprobado
      final stockActualizado = stock.copyWith(
        cantidadReservado: stock.cantidadReservado - cantidad,
        cantidadAprobado: stock.cantidadAprobado + cantidad,
      );

      // Guardar en la base de datos
      final resultado = await _service.updateStockEmpresa(stockActualizado);
      if (!resultado) {
        _error = 'No se pudo actualizar el stock';
        notifyListeners();
        return false;
      }

      // Actualizar en la lista local
      final index = _stockEmpresa.indexWhere((s) => s.id == stockId);
      if (index != -1) {
        _stockEmpresa[index] = stockActualizado;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Método para liberar reserva (cuando se rechaza una solicitud)
  Future<bool> liberarReserva(String stockId, int cantidad) async {
    try {
      final stock = _stockEmpresa.firstWhere((s) => s.id == stockId);

      // Verificar si hay suficiente reservado
      if (stock.cantidadReservado < cantidad) {
        _error =
            'No hay suficiente stock reservado. Reservado: ${stock.cantidadReservado}, Solicitado: $cantidad';
        notifyListeners();
        return false;
      }

      // Actualizar el stock: disminuir reservado
      final stockActualizado = stock.copyWith(
        cantidadReservado: stock.cantidadReservado - cantidad,
      );

      // Guardar en la base de datos
      final resultado = await _service.updateStockEmpresa(stockActualizado);
      if (!resultado) {
        _error = 'No se pudo actualizar el stock';
        notifyListeners();
        return false;
      }

      // Actualizar en la lista local
      final index = _stockEmpresa.indexWhere((s) => s.id == stockId);
      if (index != -1) {
        _stockEmpresa[index] = stockActualizado;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Método para descontar stock aprobado (cuando se envía el producto)
  Future<bool> descontarStockAprobado(String stockId, int cantidad) async {
    try {
      final stock = _stockEmpresa.firstWhere((s) => s.id == stockId);

      // Verificar si hay suficiente aprobado
      if (stock.cantidadAprobado < cantidad) {
        _error =
            'No hay suficiente stock aprobado. Aprobado: ${stock.cantidadAprobado}, Solicitado: $cantidad';
        notifyListeners();
        return false;
      }

      // Actualizar el stock: disminuir aprobado y disminuir total
      final stockActualizado = stock.copyWith(
        cantidadAprobado: stock.cantidadAprobado - cantidad,
        cantidad: stock.cantidad - cantidad,
      );

      // Guardar en la base de datos
      final resultado = await _service.updateStockEmpresa(stockActualizado);
      if (!resultado) {
        _error = 'No se pudo actualizar el stock';
        notifyListeners();
        return false;
      }

      // Actualizar en la lista local
      final index = _stockEmpresa.indexWhere((s) => s.id == stockId);
      if (index != -1) {
        _stockEmpresa[index] = stockActualizado;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Stream<List<StockEmpresa>> stockByEmpresaStream(String idEmpresa) {
    return _service.stockByEmpresaStream(idEmpresa);
  }

  StockEmpresa? buscarStockPorCodigo(String codigo) {
    try {
      return _stockEmpresa.firstWhere((stock) => stock.codigoUnico == codigo);
    } catch (e) {
      return null;
    }
  }
}
