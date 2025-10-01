// lib/features/solicitudes/services/solicitud_traslado_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/solicitud_traslado_model.dart';

class SolicitudTrasladoService {
  late final DatabaseReference _dbRef;

  SolicitudTrasladoService() {
    if (kIsWeb) {
      _dbRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://inventario-de053-default-rtdb.firebaseio.com',
      ).ref('solicitudes_traslado');
    } else {
      _dbRef = FirebaseDatabase.instance.ref('solicitudes_traslado');
    }
  }

  Future<String> createSolicitudTraslado(SolicitudTraslado solicitud) async {
    final newRef = _dbRef.push();
    await newRef.set(solicitud.toJson());
    return newRef.key!;
  }

  Future<List<SolicitudTraslado>> getSolicitudesByEmpresa(
    String idEmpresa,
  ) async {
    final snapshot = await _dbRef
        .orderByChild('idEmpresa')
        .equalTo(idEmpresa)
        .once();

    if (snapshot.snapshot.exists) {
      final solicitudes = <SolicitudTraslado>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final solicitud = SolicitudTraslado.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );
        solicitudes.add(solicitud);
      });
      return solicitudes;
    }
    return [];
  }

  Future<List<SolicitudTraslado>> getSolicitudesByTienda(
    String idTienda,
  ) async {
    final snapshot = await _dbRef
        .orderByChild('idTienda')
        .equalTo(idTienda)
        .once();

    if (snapshot.snapshot.exists) {
      final solicitudes = <SolicitudTraslado>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final solicitud = SolicitudTraslado.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );
        solicitudes.add(solicitud);
      });
      return solicitudes;
    }
    return [];
  }

  Future<List<SolicitudTraslado>> getSolicitudesPendientesByTienda(
    String idTienda,
  ) async {
    final snapshot = await _dbRef
        .orderByChild('idTienda')
        .equalTo(idTienda)
        .once();

    if (snapshot.snapshot.exists) {
      final solicitudes = <SolicitudTraslado>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final solicitud = SolicitudTraslado.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );
        // Filtrar solo solicitudes pendientes de recepción
        if (solicitud.estado == 'APROBADO' ||
            (solicitud.tipoSolicitud == 'TIENDA_A_EMPRESA' &&
                solicitud.estado == 'PENDIENTE')) {
          solicitudes.add(solicitud);
        }
      });
      return solicitudes;
    }
    return [];
  }

  Future<SolicitudTraslado?> getSolicitudById(String id) async {
    final snapshot = await _dbRef.child(id).get();
    if (snapshot.exists) {
      return SolicitudTraslado.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
    }
    return null;
  }

  Future<bool> updateSolicitudTraslado(SolicitudTraslado solicitud) async {
    try {
      await _dbRef.child(solicitud.id).update(solicitud.toJson());
      return true;
    } catch (e) {
      print("Error al actualizar solicitud: $e");
      return false;
    }
  }

  Future<void> cancelarSolicitud(String id, String motivo) async {
    await _dbRef.child(id).update({
      'estado': 'CANCELADO',
      'motivoRechazo': motivo,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // NUEVO: Método para obtener el siguiente correlativo
  Future<int> getSiguienteCorrelativo(String idEmpresa) async {
    final snapshot = await _dbRef
        .orderByChild('idEmpresa')
        .equalTo(idEmpresa)
        .once();

    int maxCorrelativo = 0;

    if (snapshot.snapshot.exists) {
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final solicitud = SolicitudTraslado.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );

        // Extraer el número del correlativo (asumiendo formato "PED-00001")
        if (solicitud.correlativo != null) {
          final correlativoStr = solicitud.correlativo!.replaceAll('PED-', '');
          final correlativoNum = int.tryParse(correlativoStr) ?? 0;
          if (correlativoNum > maxCorrelativo) {
            maxCorrelativo = correlativoNum;
          }
        }
      });
    }

    return maxCorrelativo + 1;
  }

  // NUEVO: Método para generar un correlativo con formato
  String generarCorrelativo(int numero) {
    return 'PED-${numero.toString().padLeft(5, '0')}';
  }

  Stream<List<SolicitudTraslado>> solicitudesByEmpresaStream(String idEmpresa) {
    return _dbRef.orderByChild('idEmpresa').equalTo(idEmpresa).onValue.map((
      event,
    ) {
      final solicitudes = <SolicitudTraslado>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          solicitudes.add(
            SolicitudTraslado.fromJson(Map<String, dynamic>.from(value), key),
          );
        });
      }
      return solicitudes;
    });
  }

  Stream<List<SolicitudTraslado>> solicitudesByTiendaStream(String idTienda) {
    return _dbRef.orderByChild('idTienda').equalTo(idTienda).onValue.map((
      event,
    ) {
      final solicitudes = <SolicitudTraslado>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          solicitudes.add(
            SolicitudTraslado.fromJson(Map<String, dynamic>.from(value), key),
          );
        });
      }
      return solicitudes;
    });
  }
}
