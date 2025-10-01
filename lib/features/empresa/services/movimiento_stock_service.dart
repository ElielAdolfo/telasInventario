// lib/features/movimientos/services/movimiento_stock_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:inventario/features/empresa/services/base_service.dart';
import '../models/movimiento_stock_model.dart';

class MovimientoStockService extends BaseService {

  MovimientoStockService() : super('movimientos_stock');

  Future<String> createMovimientoStock(MovimientoStock movimiento) async {
    final newRef = dbRef.push();
    await newRef.set(movimiento.toJson());
    return newRef.key!;
  }

  Future<List<MovimientoStock>> getMovimientosByEmpresa(
    String idEmpresa,
  ) async {
    final snapshot = await dbRef
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
    final snapshot = await dbRef
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
    final snapshot = await dbRef
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
    return dbRef.orderByChild('idEmpresa').equalTo(idEmpresa).onValue.map((
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
    return dbRef.orderByChild('idTienda').equalTo(idTienda).onValue.map((
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
