import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/models/user_model.dart';
import 'package:inventario/features/empresa/models/user_role.dart';
import 'package:inventario/features/empresa/services/user_service.dart';

class AuthManager extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  User? _user;
  UserModel? _userProfile;
  String? errorMessage;
  bool _isFirstLogin = false;
  bool _isLoading = false; // Add this field to track loading state

  UserRole? _selectedRole; // Rol actualmente seleccionado

  UserRole? get selectedRole => _selectedRole;

  AuthManager() {
    _user = _auth.currentUser;
    _checkUserProfile();
  }

  bool get isLoggedIn => _user != null;
  bool get isFirstLogin => _isFirstLogin;
  bool get isLoading => _isLoading; // Add this getter
  String? get userId => _user?.uid;
  String? get userEmail => _user?.email;
  User? get user => _user;
  UserModel? get userProfile => _userProfile;

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true; // Set loading to true before operation
      notifyListeners();

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      errorMessage = null;

      // Verificar si el usuario tiene perfil
      await _checkUserProfile();
      _isLoading = false; // Set loading to false after operation
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      _isLoading = false; // Set loading to false on error
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true; // Set loading to true before operation
    notifyListeners();

    await _auth.signOut();
    _user = null;
    _userProfile = null;
    _isFirstLogin = false;
    _isLoading = false; // Set loading to false after operation
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    try {
      _isLoading = true; // Set loading to true before operation
      notifyListeners();

      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      errorMessage = null;

      // Crear perfil de usuario básico
      await _createUserProfile();

      _isLoading = false; // Set loading to false after operation
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      _isLoading = false; // Set loading to false on error
      notifyListeners();
    }
  }

  Future<void> _checkUserProfile() async {
    if (_user == null) return;

    final profile = await _userService.getUserById(_user!.uid);

    if (profile == null) {
      // No existe perfil, es primer inicio de sesión
      _isFirstLogin = true;
      _userProfile = null;
    } else {
      _userProfile = profile;
      _isFirstLogin = false;
    }

    notifyListeners();
  }

  Future<void> _createUserProfile() async {
    if (_user == null) return;

    final newUser = UserModel(
      id: _user!.uid,
      email: _user!.email ?? '',
      displayName: _user!.displayName ?? _user!.email?.split('@')[0] ?? '',
      photoURL: _user?.photoURL,
      roles: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _userService.createUser(newUser);
    _userProfile = newUser;
  }

  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      _isLoading = true; // Set loading to true before operation
      notifyListeners();

      final result = await _userService.updateUser(updatedUser);
      if (result) {
        _userProfile = updatedUser;
        _isFirstLogin = false;
        _isLoading = false; // Set loading to false after operation
        notifyListeners();
        return true;
      }
      _isLoading = false; // Set loading to false if result is false
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      _isLoading = false; // Set loading to false on error
      notifyListeners();
      return false;
    }
  }

  void selectRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  // Método para verificar si el usuario tiene roles disponibles
  bool hasAvailableRoles() {
    return userProfile?.roles.isNotEmpty ?? false;
  }

  // Método para obtener la pantalla inicial según el rol seleccionado
  String getInitialRoute() {
    if (_selectedRole == null) return '/role_selection';

    switch (_selectedRole!.name.toLowerCase()) {
      case 'administrador':
        return '/empresa_list';
      case 'gerente':
        return '/empresa_list';
      case 'vendedor':
        return '/tienda_list';
      default:
        return '/role_selection';
    }
  }
}
