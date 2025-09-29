// lib/features/color/models/color_model.dart

class ColorProducto {
  final String id;
  final String nombreColor;
  final String codigoColor; // Código hexadecimal
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  ColorProducto({
    required this.id,
    required this.nombreColor,
    required this.codigoColor,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ColorProducto.fromJson(Map<String, dynamic> json, String id) {
    return ColorProducto(
      id: id,
      nombreColor: json['nombreColor'] ?? '',
      codigoColor: json['codigoColor'] ?? '',
      deleted: json['deleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreColor': nombreColor,
      'codigoColor': codigoColor,
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ColorProducto copyWith({
    String? nombreColor,
    String? codigoColor,
    bool? deleted,
  }) {
    return ColorProducto(
      id: id,
      nombreColor: nombreColor ?? this.nombreColor,
      codigoColor: codigoColor ?? this.codigoColor,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static ColorProducto empty() {
    return ColorProducto(
      id: '',
      nombreColor: '',
      codigoColor: '',
      deleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ColorProducto('
        'id: $id, '
        'nombreColor: $nombreColor, '
        'codigoColor: $codigoColor, '
        'deleted: $deleted, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}
