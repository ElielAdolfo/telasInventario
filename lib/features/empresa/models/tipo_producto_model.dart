// lib/features/producto/models/tipo_producto_model.dart
class TipoProducto {
  final String id;
  final String idEmpresa;
  final String nombre;
  final String? descripcion; // Ahora es opcional
  final String unidadMedida;
  final List<int> cantidadesPosibles;
  final int cantidadPrioritaria;
  final double precioCompraDefault; // Nuevo campo
  final double precioVentaDefaultMenor; // Nuevo campo
  final double precioVentaDefaultMayor; // Nuevo campo
  final bool requiereColor;
  final String? codigoColor;
  final String categoria;
  final bool permiteVentaParcial;
  final String? unidadMedidaSecundaria;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  TipoProducto({
    required this.id,
    required this.idEmpresa,
    required this.nombre,
    this.descripcion, // Ahora es opcional
    required this.unidadMedida,
    required this.cantidadesPosibles,
    required this.cantidadPrioritaria,
    required this.precioCompraDefault,
    required this.precioVentaDefaultMenor,
    required this.precioVentaDefaultMayor,
    required this.requiereColor,
    this.codigoColor, // Nuevo campo
    required this.categoria,
    this.permiteVentaParcial = true,
    this.unidadMedidaSecundaria, // Nuevo campo
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TipoProducto.fromJson(Map<String, dynamic> json, String id) {
    // Convertir la lista de cantidades desde JSON
    List<int> cantidades = [];
    if (json['cantidadesPosibles'] != null) {
      for (var item in json['cantidadesPosibles']) {
        cantidades.add(int.parse(item.toString()));
      }
    }

    return TipoProducto(
      id: id,
      idEmpresa: json['idEmpresa'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'], // Puede ser nulo
      unidadMedida: json['unidadMedida'] ?? '',
      cantidadesPosibles: cantidades,
      cantidadPrioritaria: json['cantidadPrioritaria'] ?? 0,
      precioCompraDefault: (json['precioCompraDefault'] ?? 0).toDouble(),
      precioVentaDefaultMenor: (json['precioVentaDefaultMenor'] ?? 0)
          .toDouble(),
      precioVentaDefaultMayor: (json['precioVentaDefaultMayor'] ?? 0)
          .toDouble(),
      requiereColor: json['requiereColor'] ?? false,
      codigoColor: json['codigoColor'], // Nuevo campo
      categoria: json['categoria'] ?? '',
      permiteVentaParcial: json['permiteVentaParcial'] ?? true,
      unidadMedidaSecundaria: json['unidadMedidaSecundaria'], // Nuevo campo
      deleted: json['deleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEmpresa': idEmpresa,
      'nombre': nombre,
      'descripcion': descripcion, // Puede ser nulo
      'unidadMedida': unidadMedida,
      'cantidadesPosibles': cantidadesPosibles
          .map((e) => e.toString())
          .toList(),
      'cantidadPrioritaria': cantidadPrioritaria,
      'precioCompraDefault': precioCompraDefault,
      'precioVentaDefaultMenor': precioVentaDefaultMenor,
      'precioVentaDefaultMayor': precioVentaDefaultMayor,
      'requiereColor': requiereColor,
      'codigoColor': codigoColor, // Nuevo campo
      'categoria': categoria,
      'permiteVentaParcial': permiteVentaParcial,
      'unidadMedidaSecundaria': unidadMedidaSecundaria, // Nuevo campo
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TipoProducto copyWith({
    String? idEmpresa,
    String? nombre,
    String? descripcion,
    String? unidadMedida,
    List<int>? cantidadesPosibles,
    int? cantidadPrioritaria,
    double? precioCompraDefault,
    double? precioVentaDefaultMenor,
    double? precioVentaDefaultMayor,
    bool? requiereColor,
    String? codigoColor,
    String? categoria,
    bool? permiteVentaParcial,
    String? unidadMedidaSecundaria,
    bool? deleted,
  }) {
    return TipoProducto(
      id: id,
      idEmpresa: idEmpresa ?? this.idEmpresa,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion, // Permite nulo
      unidadMedida: unidadMedida ?? this.unidadMedida,
      cantidadesPosibles: cantidadesPosibles ?? this.cantidadesPosibles,
      cantidadPrioritaria: cantidadPrioritaria ?? this.cantidadPrioritaria,
      precioCompraDefault: precioCompraDefault ?? this.precioCompraDefault,
      precioVentaDefaultMenor:
          precioVentaDefaultMenor ?? this.precioVentaDefaultMenor,
      precioVentaDefaultMayor:
          precioVentaDefaultMayor ?? this.precioVentaDefaultMayor,
      requiereColor: requiereColor ?? this.requiereColor,
      codigoColor: codigoColor ?? this.codigoColor,
      categoria: categoria ?? this.categoria,
      permiteVentaParcial: permiteVentaParcial ?? this.permiteVentaParcial,
      unidadMedidaSecundaria:
          unidadMedidaSecundaria ?? this.unidadMedidaSecundaria,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static TipoProducto empty() {
    return TipoProducto(
      id: '',
      idEmpresa: '',
      nombre: '',
      unidadMedida: '',
      cantidadesPosibles: [],
      cantidadPrioritaria: 0,
      precioCompraDefault: 0.0,
      precioVentaDefaultMenor: 0.0,
      precioVentaDefaultMayor: 0.0,
      requiereColor: false,
      categoria: '',
      permiteVentaParcial: false,
      deleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
