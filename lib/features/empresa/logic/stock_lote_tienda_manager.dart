// lib/features/empresa/logic/stock_lote_tienda_manager.dart

import 'package:flutter/material.dart';
import '../models/stock_lote_tienda_model.dart';
import '../services/stock_lote_tienda_service.dart';

class StockLoteTiendaManager extends ChangeNotifier {
  final StockLoteTiendaService _service = StockLoteTiendaService();
  List<StockLoteTienda> _lotes = [];
  bool _isLoading = false;
  String? _error;

  List<StockLoteTienda> get lotes => _lotes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarLotesPorTienda(String idTienda) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lotes = await _service.getLotesByTienda(idTienda);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> crearLote(StockLoteTienda lote) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _service.createLote(lote);
      _lotes.add(lote.copyWith(id: id));
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

  Future<bool> venderUnidadCompleta(String idLote) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final lote = _lotes.firstWhere((l) => l.id == idLote);

      if (lote.cantidadDisponible < 1) {
        _error = 'No hay unidades disponibles en este lote';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final loteActualizado = lote.copyWith(
        cantidadVendida: lote.cantidadVendida + 1,
        cantidadDisponible: lote.cantidadDisponible - 1,
      );

      final resultado = await _service.updateLote(loteActualizado);
      if (resultado) {
        final index = _lotes.indexWhere((l) => l.id == idLote);
        if (index != -1) {
          _lotes[index] = loteActualizado;
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

  // Método para obtener un lote por su ID
  Future<StockLoteTienda?> getLoteById(String id) async {
    try {
      return await _service.getLoteById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Método para actualizar un lote
  Future<bool> actualizarLote(StockLoteTienda lote) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _service.updateLote(lote);
      if (resultado) {
        final index = _lotes.indexWhere((l) => l.id == lote.id);
        if (index != -1) {
          _lotes[index] = lote;
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

  Stream<List<StockLoteTienda>> lotesByTiendaStream(String idTienda) {
    return _service.lotesByTiendaStream(idTienda);
  }
}
