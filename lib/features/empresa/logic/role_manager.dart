// lib/features/auth/logic/role_manager.dart
import 'package:flutter/material.dart';
import '../models/role_model.dart';
import '../services/role_service.dart';

class RoleManager extends ChangeNotifier {
  final RoleService _roleService = RoleService();

  List<RoleModel> _roles = [];
  bool _isLoading = false;
  String? _error;

  List<RoleModel> get roles => _roles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRoles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _roles = await _roleService.getAllRoles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addRole(RoleModel role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final roleId = await _roleService.createRole(role);
      if (roleId.isNotEmpty) {
        await loadRoles();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRole(RoleModel role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _roleService.updateRole(role);

      if (result) {
        final index = _roles.indexWhere((r) => r.id == role.id);
        if (index != -1) {
          _roles[index] = role;
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

  Future<bool> deleteRole(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _roleService.deleteRole(id);

      if (result) {
        _roles.removeWhere((r) => r.id == id);
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
}
