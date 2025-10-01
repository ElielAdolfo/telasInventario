import 'package:inventario/features/empresa/models/empresa_model.dart';
import 'package:inventario/features/empresa/services/base_service.dart';

class EmpresaService extends BaseService {
  EmpresaService() : super('companies');

  // Crear nueva empresa
  Future<String> createEmpresa(Empresa empresa) async {
    final newRef = dbRef.push();
    final newEmpresa = empresa.copyWith(deleted: false);// agregar iud usaurio id de usuario
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
  Future<void> updateEmpresa(Empresa empresa) async {
    await dbRef.child(empresa.id).update(empresa.toJson());
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
  Future<void> deleteEmpresa(String id) async {
    await dbRef.child(id).update({
      'deleted': true,
      'deletedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Modificar el método restoreEmpresa para limpiar la fecha de eliminación
  Future<void> restoreEmpresa(String id) async {
    await dbRef.child(id).update({
      'deleted': false,
      'deletedAt': null,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
