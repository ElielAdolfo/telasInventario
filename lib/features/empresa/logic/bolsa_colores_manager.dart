// lib/features/stock/logic/bolsa_colores_manager.dart

import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/models/moneda_model.dart';
import '../models/bolsa_colores_model.dart';
import '../services/bolsa_colores_service.dart';

class BolsaColoresManager with ChangeNotifier {
  final BolsaColoresService _service = BolsaColoresService();
  bool _isLoading = false;
  String? _error;

  // Getters para acceder al estado
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Método para procesar una bolsa de colores
  Future<void> procesarBolsaColores({
    required BolsaColores bolsa,
    required String idEmpresa,
    required String userId,
    // Campos adicionales del TipoProducto
    required String categoria,
    required String nombre,
    required String unidadMedida,
    String? unidadMedidaSecundaria,
    required bool permiteVentaParcial,
    required bool requiereColor,
    required List<double> cantidadesPosibles,
    required double cantidadPrioritaria,

    required Moneda? moneda,
    required double tipoCambio,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.procesarBolsaColores(
        bolsa,
        idEmpresa,
        userId,
        // Campos adicionales del TipoProducto
        categoria,
        nombre,
        unidadMedida,
        unidadMedidaSecundaria,
        permiteVentaParcial,
        requiereColor,
        cantidadesPosibles,
        cantidadPrioritaria,
        moneda!.id,
        tipoCambio,
      );

      // Notificar que la operación se completó exitosamente
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow; // Relanzar el error para que el llamador pueda manejarlo
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para limpiar el estado de error
  void limpiarError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // Método para resetear el estado del manager
  void reset() {
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
