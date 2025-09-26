// lib/features/movimientos/logic/movimiento_stock_manager.dart

import 'package:flutter/material.dart';
import '../models/movimiento_stock_model.dart';
import '../services/movimiento_stock_service.dart';

class MovimientoStockManager with ChangeNotifier {
  final MovimientoStockService _service = MovimientoStockService();

  List<MovimientoStock> _movimientos = [];
  bool _isLoading = false;
  String? _error;

  List<MovimientoStock> get movimientos => _movimientos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMovimientosByEmpresa(String idEmpresa) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _movimientos = await _service.getMovimientosByEmpresa(idEmpresa);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMovimientosByTienda(String idTienda) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _movimientos = await _service.getMovimientosByTienda(idTienda);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMovimientosBySolicitud(String idSolicitud) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _movimientos = await _service.getMovimientosBySolicitud(idSolicitud);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMovimientoStock(MovimientoStock movimiento) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createMovimientoStock(movimiento);
      // Recargar movimientos según el origen
      if (movimiento.idTienda != null) {
        await loadMovimientosByTienda(movimiento.idTienda!);
      } else {
        await loadMovimientosByEmpresa(movimiento.idEmpresa);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<MovimientoStock>> movimientosByEmpresaStream(String idEmpresa) {
    return _service.movimientosByEmpresaStream(idEmpresa);
  }

  Stream<List<MovimientoStock>> movimientosByTiendaStream(String idTienda) {
    return _service.movimientosByTiendaStream(idTienda);
  }
}
