// lib/features/venta/services/venta_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/venta_model.dart';

class VentaService {
  late final DatabaseReference _dbRef;

  VentaService() {
    // ✅ Para Web necesitamos especificar la URL completa
    if (kIsWeb) {
      _dbRef = FirebaseDatabase(
        databaseURL:
            'https://inventario-de053-default-rtdb.firebaseio.com', // Tu URL de Firebase Realtime Database
      ).ref('ventas');
    } else {
      _dbRef = FirebaseDatabase.instance.ref('ventas');
    }
  }

  Future<String> createVenta(Venta venta) async {
    final newRef = _dbRef.push();
    await newRef.set(venta.toJson());
    return newRef.key!;
  }

  Future<List<Venta>> getVentasByTienda(String idTienda) async {
    final snapshot = await _dbRef
        .orderByChild('idTienda')
        .equalTo(idTienda)
        .get();

    if (snapshot.exists) {
      final ventas = <Venta>[];
      for (var child in snapshot.children) {
        final venta = Venta.fromJson(
          Map<String, dynamic>.from(child.value as Map),
          child.key!,
        );
        if (!venta.deleted) ventas.add(venta);
      }
      // Ordenar por fecha descendente (similar al original)
      ventas.sort((a, b) => b.fechaVenta.compareTo(a.fechaVenta));
      return ventas;
    }
    return [];
  }

  Future<Venta?> getVentaById(String id) async {
    final snapshot = await _dbRef.child(id).get();
    if (snapshot.exists) {
      final venta = Venta.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
      return venta.deleted ? null : venta;
    }
    return null;
  }

  Future<void> updateVenta(Venta venta) async {
    await _dbRef.child(venta.id).update(venta.toJson());
  }

  Future<void> deleteVenta(String id) async {
    await _dbRef.child(id).update({
      'deleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Venta>> ventasStreamByTienda(String idTienda) {
    return _dbRef.orderByChild('idTienda').equalTo(idTienda).onValue.map((
      event,
    ) {
      final ventas = <Venta>[];
      if (event.snapshot.exists) {
        for (var child in event.snapshot.children) {
          final venta = Venta.fromJson(
            Map<String, dynamic>.from(child.value as Map),
            child.key!,
          );
          if (!venta.deleted) ventas.add(venta);
        }
        // Ordenar por fecha descendente
        ventas.sort((a, b) => b.fechaVenta.compareTo(a.fechaVenta));
      }
      return ventas;
    });
  }
}
