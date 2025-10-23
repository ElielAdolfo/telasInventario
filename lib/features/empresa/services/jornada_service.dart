// lib/features/empresa/services/jornada_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:inventario/features/empresa/models/jornada_model.dart';
import 'package:inventario/features/empresa/services/base_service.dart';

class JornadaService extends BaseService {
  JornadaService() : super('jornadas');

  Future<String> createJornada(Jornada jornada) async {
    final newRef = dbRef.push();
    await newRef.set(jornada.toJson());
    return newRef.key!;
  }

  Future<Jornada?> getJornadaById(String id) async {
    final snapshot = await dbRef.child(id).get();
    if (snapshot.exists) {
      return Jornada.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
    }
    return null;
  }

  Future<bool> updateJornada(Jornada jornada) async {
    try {
      await dbRef.child(jornada.id).update(jornada.toJson());
      return true;
    } catch (e) {
      print("Error al actualizar jornada: $e");
      return false;
    }
  }

  // Obtener la última jornada abierta para una tienda
  Future<Jornada?> getUltimaJornadaAbierta(String idTienda) async {
    final snapshot = await dbRef
        .orderByChild('idTienda')
        .equalTo(idTienda)
        .once();

    if (snapshot.snapshot.exists) {
      final jornadas = <Jornada>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final jornada = Jornada.fromJson(Map<String, dynamic>.from(value), key);
        if (!jornada.estaCerrada) {
          jornadas.add(jornada);
        }
      });

      if (jornadas.isNotEmpty) {
        // Ordenar por fecha de apertura descendente y retornar la más reciente
        jornadas.sort((a, b) => b.fechaApertura.compareTo(a.fechaApertura));
        return jornadas.first;
      }
    }
    return null;
  }

  // Obtener el último tipo de cambio registrado
  Future<double> getUltimoTipoCambio() async {
    final snapshot = await dbRef.orderByChild('fechaApertura').once();

    if (snapshot.snapshot.exists) {
      double ultimoTipoCambio = 0.0;
      DateTime? ultimaFecha;

      (snapshot.snapshot.value as Map).forEach((key, value) {
        final jornada = Jornada.fromJson(Map<String, dynamic>.from(value), key);

        if (ultimaFecha == null ||
            jornada.fechaApertura.isAfter(ultimaFecha!)) {
          ultimaFecha = jornada.fechaApertura;
          ultimoTipoCambio = jornada.tipoCambioDolar;
        }
      });

      return ultimoTipoCambio;
    }

    // Si no hay jornadas, retornar un valor por defecto
    return 0.0;
  }

  // Verificar si hay jornadas abiertas para una tienda en una fecha específica
  Future<bool> hayJornadasAbiertasEnFecha(
    String idTienda,
    DateTime fecha,
  ) async {
    final snapshot = await dbRef
        .orderByChild('idTienda')
        .equalTo(idTienda)
        .once();

    if (snapshot.snapshot.exists) {
      final jornadas = <Jornada>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final jornada = Jornada.fromJson(Map<String, dynamic>.from(value), key);

        // Verificar si la jornada es de la fecha especificada y está abierta
        if (!jornada.estaCerrada &&
            jornada.fechaApertura.year == fecha.year &&
            jornada.fechaApertura.month == fecha.month &&
            jornada.fechaApertura.day == fecha.day) {
          jornadas.add(jornada);
        }
      });

      return jornadas.isNotEmpty;
    }
    return false;
  }

  // Verificar si un usuario tiene una jornada abierta en una fecha específica
  Future<Jornada?> getJornadaAbiertaPorUsuarioYFecha(
    String idTienda,
    String idUsuario,
    DateTime fecha,
  ) async {
    final snapshot = await dbRef
        .orderByChild('idTienda')
        .equalTo(idTienda)
        .once();

    if (snapshot.snapshot.exists) {
      Jornada? jornadaEncontrada;
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final jornada = Jornada.fromJson(Map<String, dynamic>.from(value), key);

        // Verificar si es del usuario, de la fecha especificada y está abierta
        if (jornada.idUsuario == idUsuario &&
            jornada.fechaApertura.year == fecha.year &&
            jornada.fechaApertura.month == fecha.month &&
            jornada.fechaApertura.day == fecha.day &&
            !jornada.estaCerrada) {
          jornadaEncontrada = jornada;
        }
      });
      return jornadaEncontrada;
    }
    return null;
  }

  // Verificar si un usuario cerró una jornada en una fecha específica
  Future<Jornada?> getJornadaCerradaPorUsuarioYFecha(
    String idTienda,
    String idUsuario,
    DateTime fecha,
  ) async {
    final snapshot = await dbRef
        .orderByChild('idTienda')
        .equalTo(idTienda)
        .once();

    if (snapshot.snapshot.exists) {
      Jornada? jornadaEncontrada;
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final jornada = Jornada.fromJson(Map<String, dynamic>.from(value), key);

        // Verificar si es del usuario, de la fecha especificada y está cerrada
        if (jornada.idUsuario == idUsuario &&
            jornada.fechaApertura.year == fecha.year &&
            jornada.fechaApertura.month == fecha.month &&
            jornada.fechaApertura.day == fecha.day &&
            jornada.estaCerrada) {
          jornadaEncontrada = jornada;
        }
      });
      return jornadaEncontrada;
    }
    return null;
  }

  // Verificar si la jornada abierta de un usuario es del día actual
  Future<bool> verificarJornadaEsFechaActual(
    String idTienda,
    String idUsuario,
    DateTime fechaActual,
  ) async {
    final snapshot = await dbRef
        .orderByChild('idTienda')
        .equalTo(idTienda)
        .once();

    if (snapshot.snapshot.exists) {
      Jornada? jornadaAbierta;
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final jornada = Jornada.fromJson(Map<String, dynamic>.from(value), key);

        // Verificar si es del usuario, está abierta y coincide con la fecha actual
        if (jornada.idUsuario == idUsuario &&
            !jornada.estaCerrada &&
            jornada.fechaApertura.year == fechaActual.year &&
            jornada.fechaApertura.month == fechaActual.month &&
            jornada.fechaApertura.day == fechaActual.day) {
          jornadaAbierta = jornada;
        }
      });

      return jornadaAbierta != null;
    }
    return false;
  }
}
