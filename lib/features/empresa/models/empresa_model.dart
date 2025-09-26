class Empresa {
  final String id;
  final String nombre;
  final String direccion;
  final String telefono;
  final String ruc;
  final String logoUrl;
  final bool deleted;
  final DateTime? deletedAt; // Nueva: fecha de eliminación
  final DateTime createdAt;
  final DateTime updatedAt;

  Empresa({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.ruc,
    required this.logoUrl,
    this.deleted = false,
    this.deletedAt, // Puede ser nulo si no está eliminada
    required this.createdAt,
    required this.updatedAt,
  });

  factory Empresa.fromJson(Map<String, dynamic> json, String id) {
    return Empresa(
      id: id,
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      ruc: json['ruc'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      deleted: json['deleted'] ?? false,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'ruc': ruc,
      'logoUrl': logoUrl,
      'deleted': deleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Empresa copyWith({
    String? nombre,
    String? direccion,
    String? telefono,
    String? ruc,
    String? logoUrl,
    bool? deleted,
    DateTime? deletedAt,
  }) {
    return Empresa(
      id: id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      ruc: ruc ?? this.ruc,
      logoUrl: logoUrl ?? this.logoUrl,
      deleted: deleted ?? this.deleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}