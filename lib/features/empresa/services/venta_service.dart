// lib/features/empresa/services/venta_service.dart

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

  // Nuevo método para obtener ventas por tienda y fecha
  Future<List<Venta>> getVentasByTiendaAndDate(
    String idTienda,
    DateTime fecha,
  ) async {
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
        
        // Filtrar por fecha (solo ventas del día actual)
        if (!venta.deleted && _esMismaFecha(venta.fechaVenta, fecha)) {
          ventas.add(venta);
        }
      });

      // Ordenar por fecha de venta (más reciente primero)
      ventas.sort((a, b) => b.fechaVenta.compareTo(a.fechaVenta));
      return ventas;
    }
    return [];
  }

  // Nuevo método para obtener ventas por tienda, usuario y fecha
  Future<List<Venta>> getVentasByTiendaAndUsuarioAndFecha(
    String idTienda,
    String idUsuario,
    DateTime fecha,
  ) async {
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
        
        // Filtrar por usuario y fecha
        if (!venta.deleted && 
            venta.realizadoPor == idUsuario && 
            _esMismaFecha(venta.fechaVenta, fecha)) {
          ventas.add(venta);
        }
      });

      // Ordenar por fecha de venta (más reciente primero)
      ventas.sort((a, b) => b.fechaVenta.compareTo(a.fechaVenta));
      return ventas;
    }
    return [];
  }

  // Método auxiliar para verificar si dos fechas son del mismo día
  bool _esMismaFecha(DateTime fecha1, DateTime fecha2) {
    return fecha1.year == fecha2.year &&
        fecha1.month == fecha2.month &&
        fecha1.day == fecha2.day;
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
