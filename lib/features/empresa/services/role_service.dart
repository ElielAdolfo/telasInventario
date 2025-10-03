// lib/features/auth/services/role_service.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:inventario/features/empresa/services/base_service.dart';
import '../models/role_model.dart';

class RoleService extends BaseService {
  RoleService() : super('roles');

  Future<String> createRole(RoleModel role) async {
    try {
      final newRef = dbRef.push();
      await newRef.set(role.toJson());
      return newRef.key!;
    } catch (e) {
      print("Error al crear rol: $e");
      rethrow;
    }
  }

  Future<RoleModel?> getRoleById(String id) async {
    try {
      final snapshot = await dbRef.child(id).get();
      if (snapshot.exists) {
        return RoleModel.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map),
          id,
        );
      }
      return null;
    } catch (e) {
      print("Error al obtener rol por ID: $e");
      return null;
    }
  }

  Future<List<RoleModel>> getAllRoles() async {
    try {
      final snapshot = await dbRef.once();
      if (snapshot.snapshot.exists) {
        final roles = <RoleModel>[];
        (snapshot.snapshot.value as Map).forEach((key, value) {
          final role = RoleModel.fromJson(
            Map<String, dynamic>.from(value),
            key,
          );
          roles.add(role);
        });
        return roles;
      }
      return [];
    } catch (e) {
      print("Error al obtener todos los roles: $e");
      return [];
    }
  }

  Future<bool> updateRole(RoleModel role) async {
    try {
      await dbRef.child(role.id).update(role.toJson());
      return true;
    } catch (e) {
      print("Error al actualizar rol: $e");
      return false;
    }
  }

  Future<bool> deleteRole(String id) async {
    try {
      await dbRef.child(id).remove();
      return true;
    } catch (e) {
      print("Error al eliminar rol: $e");
      return false;
    }
  }
}
