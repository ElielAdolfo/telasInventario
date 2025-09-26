// lib/features/empresa/logic/venta_manager.dart
import 'package:flutter/material.dart';
import '../models/venta_model.dart';
import '../services/venta_service.dart';

class VentaManager extends ChangeNotifier {
  final VentaService _service = VentaService();
  List<Venta> _ventas = [];
  bool _isLoading = false;
  String? _error;

  List<Venta> get ventas => _ventas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVentasByTienda(String idTienda) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ventas = await _service.getVentasByTienda(idTienda);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registrarVenta(Venta venta) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _service.createVenta(venta);
      if (id != null) {
        // Actualizar la lista de ventas
        await loadVentasByTienda(venta.idTienda);
        return true;
      } else {
        _error = 'No se pudo registrar la venta';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
