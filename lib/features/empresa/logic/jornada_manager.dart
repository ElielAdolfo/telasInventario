// lib/features/empresa/logic/jornada_manager.dart

import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/models/jornada_model.dart';
import 'package:inventario/features/empresa/services/jornada_service.dart';

class JornadaManager with ChangeNotifier {
  final JornadaService _service = JornadaService();
  Jornada? _jornadaActual;
  bool _isLoading = false;
  String? _error;
  double _ultimoTipoCambio = 0.0;

  Jornada? get jornadaActual => _jornadaActual;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get ultimoTipoCambio => _ultimoTipoCambio;

  // Verificar si el usuario tiene jornada abierta
  Future<bool> verificarJornadaAbierta(
    String idTienda,
    String idUsuario,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final jornada = await _service.getUltimaJornadaAbierta(idTienda);

      // Si hay una jornada abierta y pertenece al usuario actual
      if (jornada != null && jornada.idUsuario == idUsuario) {
        _jornadaActual = jornada;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _jornadaActual = null;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Nuevo método para verificar si la jornada es del día actual
  Future<bool> verificarJornadaEsFechaActual(
    String idTienda,
    String idUsuario,
    DateTime fechaActual,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _service.verificarJornadaEsFechaActual(
        idTienda,
        idUsuario,
        fechaActual,
      );

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

  // Abrir una nueva jornada
  Future<bool> abrirJornada({
    required String idTienda,
    required String idUsuario,
    required double tipoCambioDolar,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Obtener la fecha actual (sin hora) para comparar
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);

      // Verificar si el usuario ya tiene una jornada abierta hoy
      final jornadaExistenteHoy = await _service
          .getJornadaAbiertaPorUsuarioYFecha(idTienda, idUsuario, hoy);

      if (jornadaExistenteHoy != null) {
        _error = 'Ya tienes una jornada abierta hoy';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verificar si el usuario ya cerró una jornada hoy
      final jornadaCerradaHoy = await _service
          .getJornadaCerradaPorUsuarioYFecha(idTienda, idUsuario, hoy);

      if (jornadaCerradaHoy != null) {
        _error = 'Ya cerraste una jornada hoy. No puedes abrir otra.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Crear nueva jornada
      final nuevaJornada = Jornada(
        id: '', // Se asignará en la base de datos
        idTienda: idTienda,
        idUsuario: idUsuario,
        tipoCambioDolar: tipoCambioDolar,
        fechaApertura: DateTime.now(),
        estaCerrada: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await _service.createJornada(nuevaJornada);
      if (id.isNotEmpty) {
        _jornadaActual = nuevaJornada.copyWith(id: id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'No se pudo crear la jornada';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cerrar la jornada actual
  Future<bool> cerrarJornada(String idUsuario) async {
    if (_jornadaActual == null) {
      _error = 'No hay una jornada abierta';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final jornadaActualizada = _jornadaActual!.copyWith(
        fechaCierre: DateTime.now(),
        cerradoPor: idUsuario,
        estaCerrada: true,
        updatedAt: DateTime.now(),
      );

      final resultado = await _service.updateJornada(jornadaActualizada);
      if (resultado) {
        _jornadaActual = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'No se pudo cerrar la jornada';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Obtener el último tipo de cambio registrado
  Future<void> cargarUltimoTipoCambio() async {
    try {
      _ultimoTipoCambio = await _service.getUltimoTipoCambio();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Verificar si hay jornadas abiertas para una fecha específica
  Future<bool> hayJornadasAbiertasEnFecha(
    String idTienda,
    DateTime fecha,
  ) async {
    try {
      return await _service.hayJornadasAbiertasEnFecha(idTienda, fecha);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
