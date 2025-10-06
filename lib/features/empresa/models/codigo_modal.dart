// lib/features/stock/models/codigo_model.dart

class CodigoModel {
  final String id;
  final String codigo;
  final DateTime timestamp;

  CodigoModel({
    required this.id,
    required this.codigo,
    required this.timestamp,
  });

  factory CodigoModel.fromJson(Map<String, dynamic> json, String id) {
    return CodigoModel(
      id: id,
      codigo: json['codigo'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'timestamp': timestamp.millisecondsSinceEpoch};
  }

  CodigoModel copyWith({String? id, String? codigo, DateTime? timestamp}) {
    return CodigoModel(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
