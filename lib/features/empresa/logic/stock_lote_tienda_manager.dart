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

  /// Carga todos los lotes de una tienda específica
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

  /// Carga los lotes de un stock de tienda específico
  Future<void> cargarLotesPorStockTienda(String idStockTienda) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lotes = await _service.getLotesByStockTienda(idStockTienda);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea un nuevo lote
  Future<String> crearLote(StockLoteTienda lote) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _service.createLote(lote);

      // Agregar el nuevo lote a la lista local
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

  /// Vende una cantidad específica de un lote
  Future<bool> venderDeLote(String idLote, int cantidad) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loteIndex = _lotes.indexWhere((l) => l.id == idLote);

      if (loteIndex == -1) {
        _error = 'Lote no encontrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final lote = _lotes[loteIndex];

      if (lote.cantidadDisponible < cantidad) {
        _error = 'Stock insuficiente... Disponible: ${lote.cantidadDisponible}';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final loteActualizado = lote.copyWith(
        cantidadVendida: lote.cantidadVendida + cantidad,
        updatedAt: DateTime.now(),
      );

      final resultado = await _service.updateLote(loteActualizado);

      if (resultado) {
        // Actualizar el lote en la lista local
        _lotes[loteIndex] = loteActualizado;
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

  /// Cierra un lote (marca como cerrado)
  Future<bool> cerrarLote(String idLote, String cerradoPor) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loteIndex = _lotes.indexWhere((l) => l.id == idLote);

      if (loteIndex == -1) {
        _error = 'Lote no encontrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final lote = _lotes[loteIndex];

      if (lote.estaCerrada) {
        _error = 'El lote ya está cerrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final loteActualizado = lote.copyWith(
        estaCerrada: true,
        fechaCierre: DateTime.now(),
        cerradoPor: cerradoPor,
        updatedAt: DateTime.now(),
      );

      final resultado = await _service.updateLote(loteActualizado);

      if (resultado) {
        // Actualizar el lote en la lista local
        _lotes[loteIndex] = loteActualizado;
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

  /// Obtiene un lote por su ID
  Future<StockLoteTienda?> getLoteById(String id) async {
    try {
      // Primero buscar en la lista local
      final loteLocal = _lotes.firstWhere(
        (l) => l.id == id,
        orElse: () => _lotes.first,
      );

      if (loteLocal.id == id) {
        return loteLocal;
      }

      // Si no está en la lista local, buscar en Firebase
      return await _service.getLoteById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Actualiza un lote existente
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

  /// Elimina un lote (marcado como eliminado)
  Future<bool> eliminarLote(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _service.deleteLote(id);

      if (resultado) {
        // Remover el lote de la lista local
        _lotes.removeWhere((l) => l.id == id);
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

  /// Obtiene un stream de lotes para una tienda específica
  Stream<List<StockLoteTienda>> lotesByTiendaStream(String idTienda) {
    return _service.lotesByTiendaStream(idTienda);
  }

  /// Obtiene un stream de lotes para un stock de tienda específico
  Stream<List<StockLoteTienda>> lotesByStockTiendaStream(String idStockTienda) {
    return _service.lotesByStockTiendaStream(idStockTienda);
  }

  /// Limpia la lista de lotes
  void limpiarLotes() {
    _lotes = [];
    notifyListeners();
  }

  /// Filtra lotes por stock de tienda
  List<StockLoteTienda> getLotesByStockTienda(String idStockTienda) {
    return _lotes.where((lote) => lote.idStockTienda == idStockTienda).toList();
  }

  /// Filtra lotes abiertos (no cerrados) con stock disponible
  List<StockLoteTienda> getLotesAbiertosDisponibles() {
    return _lotes
        .where(
          (lote) =>
              !lote.estaCerrada && !lote.deleted && lote.cantidadDisponible > 0,
        )
        .toList();
  }

  /// Filtra lotes cerrados
  List<StockLoteTienda> getLotesCerrados() {
    return _lotes.where((lote) => lote.estaCerrada && !lote.deleted).toList();
  }

  /// Calcula el total de stock disponible en lotes abiertos
  double getTotalStockDisponible() {
    return getLotesAbiertosDisponibles().fold(
      0,
      (total, lote) => total + lote.cantidadDisponible,
    );
  }

  /// Calcula el total de stock vendido en lotes abiertos
  double getTotalStockVendido() {
    return getLotesAbiertosDisponibles().fold(
      0,
      (total, lote) => total + lote.cantidadVendida,
    );
  }
}
