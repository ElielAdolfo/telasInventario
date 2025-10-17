// lib/features/moneda/models/moneda_model.dart

class Moneda {
  final String id;
  final String nombre;
  final String codigo; // Ej: USD, EUR, PEN, etc.
  final String simbolo; // Ej: $, €, S/, etc.
  final bool principal; // Indica si es la moneda principal del sistema
  final double
  tipoCambio; // Tipo de cambio respecto a la moneda principal (si no es principal)
  final bool deleted;

  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;
  final String? restoredBy;

  Moneda({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.simbolo,
    this.principal = false,
    this.tipoCambio = 1.0,
    this.deleted = false,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.restoredBy,
  });

  factory Moneda.fromJson(Map<String, dynamic> json, String id) {
    return Moneda(
      id: id,
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'] ?? '',
      simbolo: json['simbolo'] ?? '',
      principal: json['principal'] ?? false,
      tipoCambio: (json['tipoCambio'] ?? 1.0).toDouble(),
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
      'codigo': codigo,
      'simbolo': simbolo,
      'principal': principal,
      'tipoCambio': tipoCambio,
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

  Moneda copyWith({
    String? id,
    String? nombre,
    String? codigo,
    String? simbolo,
    bool? principal,
    double? tipoCambio,
    bool? deleted,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    String? deletedBy,
    String? restoredBy,
  }) {
    return Moneda(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      simbolo: simbolo ?? this.simbolo,
      principal: principal ?? this.principal,
      tipoCambio: tipoCambio ?? this.tipoCambio,
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
    return 'Moneda('
        'id: $id, '
        'nombre: $nombre, '
        'codigo: $codigo, '
        'simbolo: $simbolo, '
        'principal: $principal, '
        'tipoCambio: $tipoCambio, '
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

  static Moneda empty() {
    final now = DateTime.now();
    return Moneda(
      id: '',
      nombre: '',
      codigo: '',
      simbolo: '\$', // puedes cambiarlo si deseas otro por defecto
      principal: false,
      tipoCambio: 1.0,
      deleted: false,
      deletedAt: null,
      createdAt: now,
      updatedAt: now,
      createdBy: null,
      updatedBy: null,
      deletedBy: null,
      restoredBy: null,
    );
  }
}
