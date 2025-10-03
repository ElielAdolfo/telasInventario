// lib/features/auth/models/user_model.dart

import 'package:inventario/features/empresa/models/user_role.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final List<UserRole> roles;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    List<UserRole> rolesList = [];

    // Manejar diferentes estructuras de datos para roles
    if (json['roles'] != null) {
      if (json['roles'] is List) {
        // Si es una lista
        final rolesData = json['roles'] as List;
        for (var roleData in rolesData) {
          if (roleData is Map) {
            // Convertir explícitamente a Map<String, dynamic>
            final roleMap = Map<String, dynamic>.from(roleData);
            rolesList.add(UserRole.fromJson(roleMap, roleMap['id'] ?? ''));
          }
        }
      } else if (json['roles'] is Map) {
        // Si es un mapa
        final rolesData = json['roles'] as Map;
        rolesData.forEach((key, value) {
          if (value is Map) {
            // Convertir explícitamente a Map<String, dynamic>
            final roleMap = Map<String, dynamic>.from(value);
            rolesList.add(UserRole.fromJson(roleMap, key));
          }
        });
      }
    }
    
    return UserModel(
      id: id,
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoURL: json['photoURL'],
      roles: rolesList, // Siempre será una lista, aunque esté vacía
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> rolesMap = {};
    for (var role in roles) {
      rolesMap[role.id] = role.toJson();
    }

    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'roles': rolesMap,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    List<UserRole>? roles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  UserModel.empty()
    : this(
        id: '',
        email: '',
        displayName: '',
        roles: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}
