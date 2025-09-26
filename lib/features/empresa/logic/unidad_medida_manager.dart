// lib/features/producto/logic/unidad_medida_manager.dart
import 'package:flutter/material.dart';
import '../models/unidad_medida_model.dart';
import '../services/unidad_medida_service.dart';

class UnidadMedidaManager with ChangeNotifier {
  final UnidadMedidaService _service = UnidadMedidaService();
  List<UnidadMedida> _unidadesMedida = [];
  bool _isLoading = false;
  String? _error;

  List<UnidadMedida> get unidadesMedida => _unidadesMedida;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUnidadesMedida() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _unidadesMedida = await _service.getUnidadesMedida();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUnidadMedida(UnidadMedida unidadMedida) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createUnidadMedida(unidadMedida);
      await loadUnidadesMedida();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUnidadMedida(UnidadMedida unidadMedida) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateUnidadMedida(unidadMedida);
      await loadUnidadesMedida();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUnidadMedida(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteUnidadMedida(id);
      await loadUnidadesMedida();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UnidadMedida?> getUnidadMedidaById(String id) async {
    return await _service.getUnidadMedidaById(id);
  }

  Future<bool> existsUnidadMedidaByNombre(String nombre) async {
    return await _service.existsUnidadMedidaByNombre(nombre);
  }

  Stream<List<UnidadMedida>> get unidadesMedidaStream =>
      _service.unidadesMedidaStream();
}
