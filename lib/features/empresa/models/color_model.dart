// lib/features/color/models/color_model.dart

class ColorProducto {
  final String id;
  final String nombreColor;
  final String codigoColor; // Código hexadecimal
  final bool deleted;
  final DateTime? deletedAt; // Nuevo campo: fecha de eliminación
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy; // Nuevo campo: ID del usuario que creó el registro
  final String?
  updatedBy; // Nuevo campo: ID del usuario que actualizó el registro
  final String?
  deletedBy; // Nuevo campo: ID del usuario que eliminó el registro

  ColorProducto({
    required this.id,
    required this.nombreColor,
    required this.codigoColor,
    this.deleted = false,
    this.deletedAt, // Nuevo campo
    required this.createdAt,
    required this.updatedAt,
    this.createdBy, // Nuevo campo
    this.updatedBy, // Nuevo campo
    this.deletedBy, // Nuevo campo
  });

  factory ColorProducto.fromJson(Map<String, dynamic> json, String id) {
    return ColorProducto(
      id: id,
      nombreColor: json['nombreColor'] ?? '',
      codigoColor: json['codigoColor'] ?? '',
      deleted: json['deleted'] ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null, // Nuevo campo
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'], // Nuevo campo
      updatedBy: json['updatedBy'], // Nuevo campo
      deletedBy: json['deletedBy'], // Nuevo campo
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreColor': nombreColor,
      'codigoColor': codigoColor,
      'deleted': deleted,
      'deletedAt': deletedAt?.toIso8601String(), // Nuevo campo
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy, // Nuevo campo
      'updatedBy': updatedBy, // Nuevo campo
      'deletedBy': deletedBy, // Nuevo campo
    };
  }

  ColorProducto copyWith({
    String? nombreColor,
    String? codigoColor,
    bool? deleted,
    DateTime? deletedAt, // Nuevo campo
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy, // Nuevo campo
    String? updatedBy, // Nuevo campo
    String? deletedBy, // Nuevo campo
  }) {
    return ColorProducto(
      id: id,
      nombreColor: nombreColor ?? this.nombreColor,
      codigoColor: codigoColor ?? this.codigoColor,
      deleted: deleted ?? this.deleted,
      deletedAt: deletedAt ?? this.deletedAt, // Nuevo campo
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy, // Nuevo campo
      updatedBy: updatedBy ?? this.updatedBy, // Nuevo campo
      deletedBy: deletedBy ?? this.deletedBy, // Nuevo campo
    );
  }

  static ColorProducto empty() {
    return ColorProducto(
      id: '',
      nombreColor: '',
      codigoColor: '',
      deleted: false,
      deletedAt: null, // Nuevo campo
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: null, // Nuevo campo
      updatedBy: null, // Nuevo campo
      deletedBy: null, // Nuevo campo
    );
  }

  @override
  String toString() {
    return 'ColorProducto('
        'id: $id, '
        'nombreColor: $nombreColor, '
        'codigoColor: $codigoColor, '
        'deleted: $deleted, '
        'deletedAt: $deletedAt, ' // Nuevo campo
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'createdBy: $createdBy, ' // Nuevo campo
        'updatedBy: $updatedBy, ' // Nuevo campo
        'deletedBy: $deletedBy' // Nuevo campo
        ')';
  }
}
