// lib/features/empresa/models/jornada_model.dart

class Jornada {
  final String id;
  final String idTienda;
  final String idUsuario;
  final double tipoCambioDolar;
  final DateTime fechaApertura;
  final DateTime? fechaCierre;
  final String? cerradoPor;
  final bool estaCerrada;
  final DateTime createdAt;
  final DateTime updatedAt;

  Jornada({
    required this.id,
    required this.idTienda,
    required this.idUsuario,
    required this.tipoCambioDolar,
    required this.fechaApertura,
    this.fechaCierre,
    this.cerradoPor,
    this.estaCerrada = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Jornada.fromJson(Map<String, dynamic> json, [String? id]) {
    return Jornada(
      id: id ?? json['id'] ?? '',
      idTienda: json['idTienda'] ?? '',
      idUsuario: json['idUsuario'] ?? '',
      tipoCambioDolar: (json['tipoCambioDolar'] ?? 0).toDouble(),
      fechaApertura: json['fechaApertura'] != null
          ? DateTime.parse(json['fechaApertura'])
          : DateTime.now(),
      fechaCierre: json['fechaCierre'] != null
          ? DateTime.parse(json['fechaCierre'])
          : null,
      cerradoPor: json['cerradoPor'],
      estaCerrada: json['estaCerrada'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idTienda': idTienda,
      'idUsuario': idUsuario,
      'tipoCambioDolar': tipoCambioDolar,
      'fechaApertura': fechaApertura.toIso8601String(),
      'fechaCierre': fechaCierre?.toIso8601String(),
      'cerradoPor': cerradoPor,
      'estaCerrada': estaCerrada,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Jornada copyWith({
    String? id,
    String? idTienda,
    String? idUsuario,
    double? tipoCambioDolar,
    DateTime? fechaApertura,
    DateTime? fechaCierre,
    String? cerradoPor,
    bool? estaCerrada,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Jornada(
      id: id ?? this.id,
      idTienda: idTienda ?? this.idTienda,
      idUsuario: idUsuario ?? this.idUsuario,
      tipoCambioDolar: tipoCambioDolar ?? this.tipoCambioDolar,
      fechaApertura: fechaApertura ?? this.fechaApertura,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      cerradoPor: cerradoPor ?? this.cerradoPor,
      estaCerrada: estaCerrada ?? this.estaCerrada,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
