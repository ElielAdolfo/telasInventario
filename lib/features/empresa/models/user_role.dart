// lib/features/auth/models/user_model.dart
class UserRole {
  final String id;
  final String roleId; // Nuevo campo para almacenar el ID del rol
  final String name;
  final String? empresaId;
  final String? empresaNombre;
  final DateTime fechaVencimiento;

  UserRole({
    required this.id,
    required this.roleId, // Campo requerido
    required this.name,
    this.empresaId,
    this.empresaNombre,
    required this.fechaVencimiento,
  });

  factory UserRole.fromJson(Map<String, dynamic> json, String id) {
    return UserRole(
      id: id,
      roleId: json['roleId'] ?? '', // Nuevo campo
      name: json['name'] ?? '',
      empresaId: json['empresaId'],
      empresaNombre: json['empresaNombre'],
      fechaVencimiento: DateTime.parse(json['fechaVencimiento']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId, // Nuevo campo
      'name': name,
      'empresaId': empresaId,
      'empresaNombre': empresaNombre,
      'fechaVencimiento': fechaVencimiento.toIso8601String(),
    };
  }

  UserRole copyWith({
    String? id,
    String? roleId, // Nuevo campo
    String? name,
    String? empresaId,
    String? empresaNombre,
    DateTime? fechaVencimiento,
  }) {
    return UserRole(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId, // Nuevo campo
      name: name ?? this.name,
      empresaId: empresaId ?? this.empresaId,
      empresaNombre: empresaNombre ?? this.empresaNombre,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
    );
  }
}
