// lib/features/empresa/logic/stock_unidad_abierta_manager.dart

import 'package:flutter/material.dart';
import '../models/stock_unidad_abierta_model.dart';
import '../services/stock_unidad_abierta_service.dart';

class StockUnidadAbiertaManager extends ChangeNotifier {
  final StockUnidadAbiertaService _service = StockUnidadAbiertaService();
  List<StockUnidadAbierta> _unidadesAbiertas = [];
  bool _isLoading = false;
  String? _error;

  List<StockUnidadAbierta> get unidadesAbiertas => _unidadesAbiertas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarUnidadesAbiertasPorTienda(String idTienda) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _unidadesAbiertas = await _service.getUnidadesAbiertasByTienda(idTienda);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> abrirUnidad(
    String idLote,
    int cantidadTotal,
    String abiertoPor,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final unidad = StockUnidadAbierta(
        id: '',
        idStockLoteTienda: idLote,
        cantidadTotal: cantidadTotal,
        cantidadVendida: 0,
        cantidadDisponible: cantidadTotal,
        estaCerrada: false,
        fechaApertura: DateTime.now(),
        abiertoPor: abiertoPor,
        deleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await _service.createUnidadAbierta(unidad);
      _unidadesAbiertas.add(unidad.copyWith(id: id));
      _isLoading = false;
      notifyListeners();
      return id;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return '';
    }
  }

  Future<bool> venderPorMetro(String idUnidad, int cantidad) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final unidad = _unidadesAbiertas.firstWhere((u) => u.id == idUnidad);

      if (unidad.cantidadDisponible < cantidad) {
        _error = 'No hay suficiente cantidad disponible en esta unidad';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final unidadActualizada = unidad.copyWith(
        cantidadVendida: unidad.cantidadVendida + cantidad,
        cantidadDisponible: unidad.cantidadDisponible - cantidad,
      );

      final resultado = await _service.updateUnidadAbierta(unidadActualizada);
      if (resultado) {
        final index = _unidadesAbiertas.indexWhere((u) => u.id == idUnidad);
        if (index != -1) {
          _unidadesAbiertas[index] = unidadActualizada;
        }
      }

      _isLoading = false;
      notifyListeners();
      return resultado;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cerrarUnidad(String idUnidad) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final unidad = _unidadesAbiertas.firstWhere((u) => u.id == idUnidad);

      final unidadActualizada = unidad.copyWith(
        estaCerrada: true,
        fechaCierre: DateTime.now(),
      );

      final resultado = await _service.updateUnidadAbierta(unidadActualizada);
      if (resultado) {
        final index = _unidadesAbiertas.indexWhere((u) => u.id == idUnidad);
        if (index != -1) {
          _unidadesAbiertas[index] = unidadActualizada;
        }
      }

      _isLoading = false;
      notifyListeners();
      return resultado;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para obtener una unidad abierta por su ID
  Future<StockUnidadAbierta?> getUnidadAbiertaById(String id) async {
    try {
      return await _service.getUnidadAbiertaById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Método para actualizar una unidad abierta
  Future<bool> actualizarUnidadAbierta(StockUnidadAbierta unidad) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _service.updateUnidadAbierta(unidad);
      if (resultado) {
        final index = _unidadesAbiertas.indexWhere((u) => u.id == unidad.id);
        if (index != -1) {
          _unidadesAbiertas[index] = unidad;
        }
      }
      return resultado;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<StockUnidadAbierta>> unidadesAbiertasByTiendaStream(
    String idTienda,
  ) {
    return _service.unidadesAbiertasByTiendaStream(idTienda);
  }
}
