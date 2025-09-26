import 'package:flutter/material.dart';
import '../models/tienda_model.dart';
import '../services/tienda_service.dart';

class TiendaManager with ChangeNotifier {
  final TiendaService _service = TiendaService();
  List<Tienda> _tiendas = [];
  bool _isLoading = false;
  String? _error;

  List<Tienda> get tiendas => _tiendas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTiendasByEmpresa(String empresaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tiendas = await _service.getTiendasByEmpresa(empresaId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTienda(Tienda tienda) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createTienda(tienda);
      await loadTiendasByEmpresa(tienda.empresaId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTienda(Tienda tienda) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateTienda(tienda);
      await loadTiendasByEmpresa(tienda.empresaId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTienda(String id, String empresaId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteTienda(id);
      await loadTiendasByEmpresa(empresaId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restoreTienda(String id, String empresaId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.restoreTienda(id);
      await loadTiendasByEmpresa(empresaId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<Tienda>> tiendasStream(String empresaId) {
    return _service.tiendasStreamByEmpresa(empresaId);
  }
}