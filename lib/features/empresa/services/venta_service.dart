// lib/features/empresa/services/venta_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:inventario/features/empresa/services/base_service.dart';
import '../models/venta_model.dart';

class VentaService extends BaseService {

  VentaService() : super('ventas');

  Future<String> createVenta(Venta venta) async {
    final newRef = dbRef.push();
    await newRef.set(venta.toJson());
    return newRef.key!;
  }

  Future<List<Venta>> getVentasByTienda(String idTienda) async {
    final snapshot = await dbRef
        .orderByChild('idTienda')
        .equalTo(idTienda)
        .once();

    if (snapshot.snapshot.exists) {
      final ventas = <Venta>[];
      final data = snapshot.snapshot.value as Map;

      data.forEach((key, value) {
        // Convertir explícitamente a Map<String, dynamic>
        final Map<String, dynamic> ventaData = Map<String, dynamic>.from(value);
        final venta = Venta.fromJson(ventaData, key);
        if (!venta.deleted) {
          ventas.add(venta);
        }
      });

      // Ordenar por fecha de venta (más reciente primero)
      ventas.sort((a, b) => b.fechaVenta.compareTo(a.fechaVenta));
      return ventas;
    }
    return [];
  }

  Future<bool> updateVenta(Venta venta) async {
    try {
      await dbRef.child(venta.id).update(venta.toJson());
      return true;
    } catch (e) {
      print("Error al actualizar venta: $e");
      return false;
    }
  }

  Future<bool> deleteVenta(String id) async {
    try {
      await dbRef.child(id).update({
        'deleted': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print("Error al eliminar venta: $e");
      return false;
    }
  }

  Stream<List<Venta>> ventasByTiendaStream(String idTienda) {
    return dbRef.orderByChild('idTienda').equalTo(idTienda).onValue.map((
      event,
    ) {
      final ventas = <Venta>[];
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map;

        data.forEach((key, value) {
          // Convertir explícitamente a Map<String, dynamic>
          final Map<String, dynamic> ventaData = Map<String, dynamic>.from(
            value,
          );
          final venta = Venta.fromJson(ventaData, key);
          if (!venta.deleted) {
            ventas.add(venta);
          }
        });

        // Ordenar por fecha de venta (más reciente primero)
        ventas.sort((a, b) => b.fechaVenta.compareTo(a.fechaVenta));
      }
      return ventas;
    });
  }
}
