class Empresa {
  final String id;
  final String nombre;
  final String direccion;
  final String telefono;
  final String ruc;
  final String logoUrl;
  final bool deleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;
  final String? restoredBy;

  Empresa({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.ruc,
    required this.logoUrl,
    this.deleted = false,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.restoredBy,
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
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      deletedBy: json['deletedBy'],
      restoredBy: json['restoredBy'],
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
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'deletedBy': deletedBy,
      'restoredBy': restoredBy,
    };
  }

  Empresa copyWith({
    String? id,
    String? nombre,
    String? direccion,
    String? telefono,
    String? ruc,
    String? logoUrl,
    bool? deleted,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    String? deletedBy,
    String? restoredBy,
  }) {
    return Empresa(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      ruc: ruc ?? this.ruc,
      logoUrl: logoUrl ?? this.logoUrl,
      deleted: deleted ?? this.deleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedBy: deletedBy ?? this.deletedBy,
      restoredBy: restoredBy ?? this.restoredBy,
    );
  }

  @override
  String toString() {
    return 'Empresa('
        'id: $id, '
        'nombre: $nombre, '
        'direccion: $direccion, '
        'telefono: $telefono, '
        'ruc: $ruc, '
        'logoUrl: $logoUrl, '
        'deleted: $deleted, '
        'deletedAt: ${deletedAt?.toIso8601String()}, '
        'createdAt: ${createdAt.toIso8601String()}, '
        'updatedAt: ${updatedAt.toIso8601String()}, '
        'createdBy: $createdBy, '
        'updatedBy: $updatedBy, '
        'deletedBy: $deletedBy, '
        'restoredBy: $restoredBy'
        ')';
  }
}
