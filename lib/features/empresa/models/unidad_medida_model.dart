// lib/features/producto/models/unidad_medida_model.dart
class UnidadMedida {
  final String id;
  final String nombre; // En mayúsculas, sin espacios al inicio o final
  final String descripcion;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  UnidadMedida({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UnidadMedida.fromJson(Map<String, dynamic> json, String id) {
    return UnidadMedida(
      id: id,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      deleted: json['deleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UnidadMedida copyWith({String? nombre, String? descripcion, bool? deleted}) {
    return UnidadMedida(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Método para formatear el nombre (eliminar espacios y convertir a mayúsculas)
  static String formatearNombre(String nombre) {
    return nombre.trim().toUpperCase();
  }
}
