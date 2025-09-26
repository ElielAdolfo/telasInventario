class Tienda {
  final String id;
  final String empresaId;
  final String nombre;
  final String direccion;
  final String telefono;
  final String encargado;
  final bool isWarehouse; // true: almacén, false: tienda
  final bool deleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tienda({
    required this.id,
    required this.empresaId,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.encargado,
    this.isWarehouse = false, // Por defecto es tienda
    this.deleted = false,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tienda.fromJson(Map<String, dynamic> json, String id) {
    return Tienda(
      id: id,
      empresaId: json['empresaId'] ?? '',
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      encargado: json['encargado'] ?? '',
      isWarehouse: json['isWarehouse'] ?? false,
      deleted: json['deleted'] ?? false,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empresaId': empresaId,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'encargado': encargado,
      'isWarehouse': isWarehouse,
      'deleted': deleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Tienda copyWith({
    String? nombre,
    String? direccion,
    String? telefono,
    String? encargado,
    bool? isWarehouse,
    bool? deleted,
    DateTime? deletedAt,
  }) {
    return Tienda(
      id: id,
      empresaId: empresaId,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      encargado: encargado ?? this.encargado,
      isWarehouse: isWarehouse ?? this.isWarehouse,
      deleted: deleted ?? this.deleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}