class UnidadMedida {
  final String id;
  final String nombre;
  final String descripcion;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy; // ✅ Nuevo
  final String? updatedBy; // ✅ Nuevo

  UnidadMedida({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy, // ✅ Nuevo
    this.updatedBy, // ✅ Nuevo
  });

  factory UnidadMedida.fromJson(Map<String, dynamic> json, String id) {
    return UnidadMedida(
      id: id,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      deleted: json['deleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'], // ✅ Nuevo
      updatedBy: json['updatedBy'], // ✅ Nuevo
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy, // ✅ Nuevo
      'updatedBy': updatedBy, // ✅ Nuevo
    };
  }

  UnidadMedida copyWith({
    String? nombre,
    String? descripcion,
    bool? deleted,
    String? updatedBy, // ✅ Nuevo
  }) {
    return UnidadMedida(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      createdBy: createdBy, // ✅ Se mantiene igual
      updatedBy: updatedBy ?? this.updatedBy, // ✅ Actualizable
    );
  }

  // Método para formatear el nombre
  static String formatearNombre(String nombre) {
    return nombre.trim().toUpperCase();
  }
}
