// lib/features/moneda/logic/moneda_manager.dart

import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/models/moneda_model.dart';
import '../services/moneda_service.dart';

class MonedaManager with ChangeNotifier {
  final MonedaService _service = MonedaService();
  List<Moneda> _monedas = [];
  List<Moneda> _deletedMonedas = [];
  bool _isLoading = false;
  String? _error;

  List<Moneda> get monedas => _monedas;
  List<Moneda> get deletedMonedas => _deletedMonedas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar monedas activas desde Firebase
  Future<void> loadMonedas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _monedas = await _service.getMonedas();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar monedas eliminadas
  Future<void> loadDeletedMonedas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _service.deletedMonedasStream().first;
      _deletedMonedas = snapshot;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar nueva moneda
  Future<void> addMoneda(Moneda moneda, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createMoneda(moneda, userId);
      await loadMonedas(); // Recargar lista
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar moneda existente
  Future<void> updateMoneda(Moneda moneda, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateMoneda(moneda, userId);
      await loadMonedas(); // Recargar lista
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener moneda por ID
  Future<Moneda?> getMonedaById(String id) async {
    return await _service.getMonedaById(id);
  }

  // Stream para actualizaciones en tiempo real
  Stream<List<Moneda>> get monedasStream => _service.monedasStream();

  // Stream para monedas eliminadas
  Stream<List<Moneda>> get deletedMonedasStream =>
      _service.deletedMonedasStream();

  // Eliminar moneda
  Future<void> deleteMoneda(String id, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteMoneda(id, userId);
      await loadMonedas(); // Recargar lista activas
      await loadDeletedMonedas(); // Recargar lista eliminadas
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Restaurar moneda
  Future<void> restoreMoneda(String id, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.restoreMoneda(id, userId);
      await loadMonedas(); // Recargar lista activas
      await loadDeletedMonedas(); // Recargar lista eliminadas
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
