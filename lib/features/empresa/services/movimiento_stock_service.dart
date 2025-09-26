// lib/features/movimientos/services/movimiento_stock_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/movimiento_stock_model.dart';

class MovimientoStockService {
  late final DatabaseReference _dbRef;

  MovimientoStockService() {
    if (kIsWeb) {
      _dbRef = FirebaseDatabase(
        databaseURL: 'https://inventario-de053-default-rtdb.firebaseio.com',
      ).ref('movimientos_stock');
    } else {
      _dbRef = FirebaseDatabase.instance.ref('movimientos_stock');
    }
  }

  Future<String> createMovimientoStock(MovimientoStock movimiento) async {
    final newRef = _dbRef.push();
    await newRef.set(movimiento.toJson());
    return newRef.key!;
  }

  Future<List<MovimientoStock>> getMovimientosByEmpresa(
    String idEmpresa,
  ) async {
    final snapshot = await _dbRef
        .orderByChild('idEmpresa')
        .equalTo(idEmpresa)
        .once();

    if (snapshot.snapshot.exists) {
      final movimientos = <MovimientoStock>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        movimientos.add(
          MovimientoStock.fromJson(Map<String, dynamic>.from(value), key),
        );
      });
      return movimientos;
    }
    return [];
  }

  Future<List<MovimientoStock>> getMovimientosByTienda(String idTienda) async {
    final snapshot = await _dbRef
        .orderByChild('idTienda')
        .equalTo(idTienda)
        .once();

    if (snapshot.snapshot.exists) {
      final movimientos = <MovimientoStock>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        movimientos.add(
          MovimientoStock.fromJson(Map<String, dynamic>.from(value), key),
        );
      });
      return movimientos;
    }
    return [];
  }

  Future<List<MovimientoStock>> getMovimientosBySolicitud(
    String idSolicitud,
  ) async {
    final snapshot = await _dbRef
        .orderByChild('idSolicitudTraslado')
        .equalTo(idSolicitud)
        .once();

    if (snapshot.snapshot.exists) {
      final movimientos = <MovimientoStock>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        movimientos.add(
          MovimientoStock.fromJson(Map<String, dynamic>.from(value), key),
        );
      });
      return movimientos;
    }
    return [];
  }

  Stream<List<MovimientoStock>> movimientosByEmpresaStream(String idEmpresa) {
    return _dbRef.orderByChild('idEmpresa').equalTo(idEmpresa).onValue.map((
      event,
    ) {
      final movimientos = <MovimientoStock>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          movimientos.add(
            MovimientoStock.fromJson(Map<String, dynamic>.from(value), key),
          );
        });
      }
      return movimientos;
    });
  }

  Stream<List<MovimientoStock>> movimientosByTiendaStream(String idTienda) {
    return _dbRef.orderByChild('idTienda').equalTo(idTienda).onValue.map((
      event,
    ) {
      final movimientos = <MovimientoStock>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          movimientos.add(
            MovimientoStock.fromJson(Map<String, dynamic>.from(value), key),
          );
        });
      }
      return movimientos;
    });
  }
}
