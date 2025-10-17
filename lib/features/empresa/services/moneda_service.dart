// lib/features/moneda/services/moneda_service.dart

import 'package:inventario/features/empresa/models/moneda_model.dart';
import 'package:inventario/features/empresa/services/base_service.dart';

class MonedaService extends BaseService {
  MonedaService() : super('currencies');

  // Crear nueva moneda
  Future<String> createMoneda(Moneda moneda, String userId) async {
    final newRef = dbRef.push();
    final newMoneda = moneda.copyWith(
      deleted: false,
      createdBy: userId,
      createdAt: DateTime.now(),
    );
    await newRef.set(newMoneda.toJson());
    return newRef.key!;
  }

  // Obtener todas las monedas no eliminadas
  Future<List<Moneda>> getMonedas() async {
    final snapshot = await dbRef.orderByChild('deleted').equalTo(false).get();
    if (snapshot.exists) {
      final monedas = <Moneda>[];
      for (var child in snapshot.children) {
        monedas.add(
          Moneda.fromJson(
            Map<String, dynamic>.from(child.value as Map),
            child.key!,
          ),
        );
      }
      return monedas;
    }
    return [];
  }

  // Obtener moneda por ID
  Future<Moneda?> getMonedaById(String id) async {
    final snapshot = await dbRef.child(id).get();
    if (snapshot.exists) {
      final moneda = Moneda.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
      return moneda.deleted ? null : moneda;
    }
    return null;
  }

  // Actualizar moneda
  Future<void> updateMoneda(Moneda moneda, String userId) async {
    final updatedMoneda = moneda.copyWith(
      updatedBy: userId,
      updatedAt: DateTime.now(),
    );
    await dbRef.child(moneda.id).update(updatedMoneda.toJson());
  }

  // Stream para monedas activas
  Stream<List<Moneda>> monedasStream() {
    return dbRef.orderByChild('deleted').equalTo(false).onValue.map((event) {
      final monedas = <Moneda>[];
      if (event.snapshot.exists) {
        for (var child in event.snapshot.children) {
          monedas.add(
            Moneda.fromJson(
              Map<String, dynamic>.from(child.value as Map),
              child.key!,
            ),
          );
        }
      }
      return monedas;
    });
  }

  // Stream para monedas eliminadas
  Stream<List<Moneda>> deletedMonedasStream() {
    return dbRef.orderByChild('deleted').equalTo(true).onValue.map((event) {
      final monedas = <Moneda>[];
      if (event.snapshot.exists) {
        for (var child in event.snapshot.children) {
          monedas.add(
            Moneda.fromJson(
              Map<String, dynamic>.from(child.value as Map),
              child.key!,
            ),
          );
        }
      }
      return monedas;
    });
  }

  // Eliminar moneda (marcar como eliminada)
  Future<void> deleteMoneda(String id, String userId) async {
    await dbRef.child(id).update({
      'deleted': true,
      'deletedAt': DateTime.now().toIso8601String(),
      'deletedBy': userId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Restaurar moneda
  Future<void> restoreMoneda(String id, String userId) async {
    await dbRef.child(id).update({
      'deleted': false,
      'deletedAt': null,
      'restoredBy': userId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
