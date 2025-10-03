// lib/features/auth/logic/user_manager.dart

import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/models/user_role.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserManager extends ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _userService.getAllUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _userService.updateUser(user);

      if (result) {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = user;
        }
      }

      return result;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addRoleToUser(String userId, UserRole role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Verificar si el rol ya existe antes de intentar agregarlo
      final user = _users.firstWhere(
        (u) => u.id == userId,
        orElse: () => UserModel.empty(),
      );
      if (user.id.isEmpty) {
        _error = "Usuario no encontrado";
        return false;
      }

      // Verificar si el rol ya existe
      final roleExists = user.roles.any(
        (r) => r.roleId == role.roleId && r.empresaId == role.empresaId,
      );
      if (roleExists) {
        _error = "Este rol ya está asignado al usuario en esta empresa";
        return false;
      }

      final result = await _userService.addRoleToUser(userId, role);

      if (result) {
        final updatedUser = await _userService.getUserById(userId);
        if (updatedUser != null) {
          final index = _users.indexWhere((u) => u.id == userId);
          if (index != -1) {
            _users[index] = updatedUser;
            notifyListeners();
          }
        }
      }

      return result;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeRoleFromUser(String userId, String roleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _userService.removeRoleFromUser(userId, roleId);

      if (result) {
        final updatedUser = await _userService.getUserById(userId);
        if (updatedUser != null) {
          final index = _users.indexWhere((u) => u.id == userId);
          if (index != -1) {
            _users[index] = updatedUser;
            notifyListeners();
          }
        }
      }

      return result;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<UserModel>> usersStream() {
    return _userService.usersStream();
  }

  Future<bool> addMultipleRolesToUser(
    String userId,
    List<UserRole> roles,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Obtener el usuario actual
      final user = _users.firstWhere(
        (u) => u.id == userId,
        orElse: () => UserModel.empty(),
      );

      if (user.id.isEmpty) {
        _error = "Usuario no encontrado";
        return false;
      }

      // Verificar duplicados
      for (final role in roles) {
        final roleExists = user.roles.any(
          (r) => r.roleId == role.roleId && r.empresaId == role.empresaId,
        );

        if (roleExists) {
          _error =
              "El rol ${role.name} ya está asignado al usuario en esta empresa";
          return false;
        }
      }

      // Agregar todos los roles
      bool allSuccess = true;
      for (final role in roles) {
        final result = await _userService.addRoleToUser(userId, role);
        if (!result) {
          allSuccess = false;
          break;
        }
      }

      if (allSuccess) {
        // Actualizar el usuario en la lista local
        final updatedUser = await _userService.getUserById(userId);
        if (updatedUser != null) {
          final index = _users.indexWhere((u) => u.id == userId);
          if (index != -1) {
            _users[index] = updatedUser;
          }
        }
      }

      return allSuccess;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
