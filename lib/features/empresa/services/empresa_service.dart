import 'package:inventario/features/empresa/models/empresa_model.dart';
import 'package:inventario/features/empresa/services/base_service.dart';

class EmpresaService extends BaseService {
  EmpresaService() : super('companies');

  // Crear nueva empresa
  Future<String> createEmpresa(Empresa empresa, String userId) async {
    final newRef = dbRef.push();
    final newEmpresa = empresa.copyWith(
      deleted: false,
      createdBy: userId, // Agregar el ID del usuario que crea la empresa
      createdAt: DateTime.now(),
    ); // agregar iud usaurio id de usuario
    await newRef.set(newEmpresa.toJson());
    return newRef.key!;
  }

  // Obtener todas las empresas no eliminadas
  Future<List<Empresa>> getEmpresas() async {
    final snapshot = await dbRef.orderByChild('deleted').equalTo(false).get();
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
    final snapshot = await dbRef.child(id).get();
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
  Future<void> updateEmpresa(Empresa empresa, String userId) async {
    final updatedEmpresa = empresa.copyWith(
      updatedBy: userId, // Agregar el ID del usuario que actualiza la empresa
      updatedAt: DateTime.now(),
    );
    await dbRef.child(empresa.id).update(updatedEmpresa.toJson());
  }

  // Stream para empresas activas
  Stream<List<Empresa>> empresasStream() {
    return dbRef.orderByChild('deleted').equalTo(false).onValue.map((event) {
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
    return dbRef.orderByChild('deleted').equalTo(true).onValue.map((event) {
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
  Future<void> deleteEmpresa(String id, String userId) async {
    await dbRef.child(id).update({
      'deleted': true,
      'deletedAt': DateTime.now().toIso8601String(),
      'deletedBy': userId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Modificar el método restoreEmpresa para limpiar la fecha de eliminación
  Future<void> restoreEmpresa(String id, String userId) async {
    await dbRef.child(id).update({
      'deleted': false,
      'deletedAt': null,
      'restoredBy': userId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
