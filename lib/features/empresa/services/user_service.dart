// lib/features/auth/services/user_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:inventario/features/empresa/models/user_role.dart';
import 'package:inventario/features/empresa/services/base_service.dart';
import '../models/user_model.dart';

class UserService extends BaseService {
  UserService() : super('users');

  Future<String> createUser(UserModel user) async {
    try {
      // Usar el ID del usuario como clave directa en lugar de push()
      await dbRef.child(user.id).set(user.toJson());
      return user.id;
    } catch (e) {
      print("Error al crear usuario: $e");
      rethrow;
    }
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      final snapshot = await dbRef.child(id).get();
      if (snapshot.exists) {
        return UserModel.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map),
          id, // Usar el ID que ya tenemos
        );
      }
      return null;
    } catch (e) {
      print("Error al obtener usuario por ID: $e");
      return null;
    }
  }

  Future<bool> updateUser(UserModel user) async {
    try {
      // Imprimir para depuración
      print("Actualizando usuario ${user.id} con ${user.roles.length} roles");

      await dbRef.child(user.id).update(user.toJson());
      return true;
    } catch (e) {
      print("Error al actualizar usuario: $e");
      return false;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await dbRef.once();
      if (snapshot.snapshot.exists) {
        final users = <UserModel>[];
        (snapshot.snapshot.value as Map).forEach((key, value) {
          final user = UserModel.fromJson(
            Map<String, dynamic>.from(value),
            key, // Usar la clave como ID
          );
          users.add(user);
        });
        return users;
      }
      return [];
    } catch (e) {
      print("Error al obtener todos los usuarios: $e");
      return [];
    }
  }

  Future<bool> addRoleToUser(String userId, UserRole role) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return false;

      // Asegurarse de que roles no sea nulo
      final List<UserRole> currentRoles = user.roles ?? [];

      // Verificar si el rol ya existe (mismo ID de rol y misma empresa)
      final roleExists = currentRoles.any(
        (r) => r.roleId == role.roleId && r.empresaId == role.empresaId,
      );

      if (roleExists) {
        print("El rol ya existe para este usuario y empresa");
        return true; // Ya existe, no hacemos nada
      }

      final updatedRoles = List<UserRole>.from(currentRoles);
      updatedRoles.add(role);

      final updatedUser = user.copyWith(
        roles: updatedRoles,
        updatedAt: DateTime.now(),
      );

      return await updateUser(updatedUser);
    } catch (e) {
      print("Error al agregar rol a usuario: $e");
      return false;
    }
  }

  Future<bool> removeRoleFromUser(String userId, String roleId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return false;

      final updatedRoles = user.roles
          .where((role) => role.id != roleId)
          .toList();
      final updatedUser = user.copyWith(
        roles: updatedRoles,
        updatedAt: DateTime.now(),
      );

      return await updateUser(updatedUser);
    } catch (e) {
      print("Error al eliminar rol de usuario: $e");
      return false;
    }
  }

  Stream<List<UserModel>> usersStream() {
    return dbRef.onValue.map((event) {
      final users = <UserModel>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          final user = UserModel.fromJson(
            Map<String, dynamic>.from(value),
            key, // Usar la clave como ID
          );
          users.add(user);
        });
      }
      return users;
    });
  }

  // Nuevo método para verificar si un usuario existe
  Future<bool> userExists(String userId) async {
    try {
      final snapshot = await dbRef.child(userId).get();
      return snapshot.exists;
    } catch (e) {
      print("Error al verificar si el usuario existe: $e");
      return false;
    }
  }

  // Nuevo método para crear o actualizar un usuario (upsert)
  Future<bool> createOrUpdateUser(UserModel user) async {
    try {
      final exists = await userExists(user.id);

      if (exists) {
        return await updateUser(user);
      } else {
        final result = await createUser(user);
        return result.isNotEmpty;
      }
    } catch (e) {
      print("Error al crear o actualizar usuario: $e");
      return false;
    }
  }
}
