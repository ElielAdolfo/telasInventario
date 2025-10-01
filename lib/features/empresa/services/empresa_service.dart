import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:inventario/features/empresa/models/empresa_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EmpresaService {
  late final DatabaseReference _dbRef;

  EmpresaService() {
    // Para Web necesitamos especificar la URL completa
    if (kIsWeb) {
      _dbRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(), // Esto obtiene la app por defecto
        databaseURL:
            'https://inventario-de053-default-rtdb.firebaseio.com', // ✅ Tu URL de Firebase Realtime Database
      ).ref('companies');
    } else {
      _dbRef = FirebaseDatabase.instance.ref('companies');
    }
  }

  // Crear nueva empresa
  Future<String> createEmpresa(Empresa empresa) async {
    final newRef = _dbRef.push();
    final newEmpresa = empresa.copyWith(deleted: false);
    await newRef.set(newEmpresa.toJson());
    return newRef.key!;
  }

  // Obtener todas las empresas no eliminadas
  Future<List<Empresa>> getEmpresas() async {
    final snapshot = await _dbRef.orderByChild('deleted').equalTo(false).get();
    if (snapshot.exists) {
      final empresas = <Empresa>[];
      for (var child in snapshot.children) {
        empresas.add(
          Empresa.fromJson(
            Map<String, dynamic>.from(child.value as Map),
            child.key!,
          ),
        );
      }
      return empresas;
    }
    return [];
  }

  // Obtener empresa por ID
  Future<Empresa?> getEmpresaById(String id) async {
    final snapshot = await _dbRef.child(id).get();
    if (snapshot.exists) {
      final empresa = Empresa.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
      return empresa.deleted ? null : empresa;
    }
    return null;
  }

  // Actualizar empresa
  Future<void> updateEmpresa(Empresa empresa) async {
    await _dbRef.child(empresa.id).update(empresa.toJson());
  }

  // Stream para empresas activas
  Stream<List<Empresa>> empresasStream() {
    return _dbRef.orderByChild('deleted').equalTo(false).onValue.map((event) {
      final empresas = <Empresa>[];
      if (event.snapshot.exists) {
        for (var child in event.snapshot.children) {
          empresas.add(
            Empresa.fromJson(
              Map<String, dynamic>.from(child.value as Map),
              child.key!,
            ),
          );
        }
      }
      return empresas;
    });
  }

  // Stream para empresas eliminadas
  Stream<List<Empresa>> deletedEmpresasStream() {
    return _dbRef.orderByChild('deleted').equalTo(true).onValue.map((event) {
      final empresas = <Empresa>[];
      if (event.snapshot.exists) {
        for (var child in event.snapshot.children) {
          empresas.add(
            Empresa.fromJson(
              Map<String, dynamic>.from(child.value as Map),
              child.key!,
            ),
          );
        }
      }
      return empresas;
    });
  }

  // Modificar el método deleteEmpresa para incluir la fecha de eliminación
  Future<void> deleteEmpresa(String id) async {
    await _dbRef.child(id).update({
      'deleted': true,
      'deletedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Modificar el método restoreEmpresa para limpiar la fecha de eliminación
  Future<void> restoreEmpresa(String id) async {
    await _dbRef.child(id).update({
      'deleted': false,
      'deletedAt': null,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
