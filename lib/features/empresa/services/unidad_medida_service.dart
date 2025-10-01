// lib/features/producto/services/unidad_medida_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:inventario/features/empresa/services/base_service.dart';
import '../models/unidad_medida_model.dart';

class UnidadMedidaService extends BaseService {

  UnidadMedidaService() : super('unidades_medida');

  Future<String> createUnidadMedida(UnidadMedida unidadMedida) async {
    final newRef = dbRef.push();
    await newRef.set(unidadMedida.toJson());
    return newRef.key!;
  }

  Future<List<UnidadMedida>> getUnidadesMedida() async {
    final snapshot = await dbRef.orderByChild('deleted').equalTo(false).get();
    if (snapshot.exists) {
      final unidades = <UnidadMedida>[];
      for (var child in snapshot.children) {
        unidades.add(
          UnidadMedida.fromJson(
            Map<String, dynamic>.from(child.value as Map),
            child.key!,
          ),
        );
      }
      return unidades;
    }
    return [];
  }

  Future<UnidadMedida?> getUnidadMedidaById(String id) async {
    final snapshot = await dbRef.child(id).get();
    if (snapshot.exists) {
      final unidad = UnidadMedida.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
      return unidad.deleted ? null : unidad;
    }
    return null;
  }

  Future<void> updateUnidadMedida(UnidadMedida unidadMedida) async {
    await dbRef.child(unidadMedida.id).update(unidadMedida.toJson());
  }

  Future<void> deleteUnidadMedida(String id) async {
    await dbRef.child(id).update({
      'deleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> existsUnidadMedidaByNombre(String nombre) async {
    final nombreFormateado = UnidadMedida.formatearNombre(nombre);
    final snapshot = await dbRef
        .orderByChild('nombre')
        .equalTo(nombreFormateado)
        .once();
    if (snapshot.snapshot.exists) {
      for (var child in snapshot.snapshot.children) {
        final unidad = UnidadMedida.fromJson(
          Map<String, dynamic>.from(child.value as Map),
          child.key!,
        );
        if (!unidad.deleted) return true;
      }
    }
    return false;
  }

  Stream<List<UnidadMedida>> unidadesMedidaStream() {
    return dbRef.orderByChild('deleted').equalTo(false).onValue.map((event) {
      final unidades = <UnidadMedida>[];
      if (event.snapshot.exists) {
        for (var child in event.snapshot.children) {
          unidades.add(
            UnidadMedida.fromJson(
              Map<String, dynamic>.from(child.value as Map),
              child.key!,
            ),
          );
        }
      }
      return unidades;
    });
  }
}
