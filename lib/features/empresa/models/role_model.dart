// lib/features/auth/models/role_model.dart
class RoleModel {
  final String id;
  final String name;
  final String? description;

  RoleModel({required this.id, required this.name, this.description});

  factory RoleModel.fromJson(Map<String, dynamic> json, String id) {
    return RoleModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }

  RoleModel copyWith({String? id, String? name, String? description}) {
    return RoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
