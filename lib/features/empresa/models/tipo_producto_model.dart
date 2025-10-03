// lib/features/producto/models/tipo_producto_model.dart
class TipoProducto {
  final String id;
  final String idEmpresa;
  final String nombre;
  final String? descripcion;
  final String unidadMedida;
  final List<int> cantidadesPosibles;
  final int cantidadPrioritaria;
  final double precioCompraDefault;
  final double precioVentaDefaultMenor;
  final double precioVentaDefaultMayor;
  final double? precioPaquete; // Nuevo campo
  final bool requiereColor;
  final String? codigoColor;
  final String categoria;
  final bool permiteVentaParcial;
  final String? unidadMedidaSecundaria;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy; // Nuevo campo
  final String? updatedBy; // Nuevo campo

  TipoProducto({
    required this.id,
    required this.idEmpresa,
    required this.nombre,
    this.descripcion,
    required this.unidadMedida,
    required this.cantidadesPosibles,
    required this.cantidadPrioritaria,
    required this.precioCompraDefault,
    required this.precioVentaDefaultMenor,
    required this.precioVentaDefaultMayor,
    this.precioPaquete, // Nuevo campo
    required this.requiereColor,
    this.codigoColor,
    required this.categoria,
    this.permiteVentaParcial = true,
    this.unidadMedidaSecundaria,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy, // Nuevo campo
    this.updatedBy, // Nuevo campo
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
      descripcion: json['descripcion'],
      unidadMedida: json['unidadMedida'] ?? '',
      cantidadesPosibles: cantidades,
      cantidadPrioritaria: json['cantidadPrioritaria'] ?? 0,
      precioCompraDefault: (json['precioCompraDefault'] ?? 0).toDouble(),
      precioVentaDefaultMenor: (json['precioVentaDefaultMenor'] ?? 0)
          .toDouble(),
      precioVentaDefaultMayor: (json['precioVentaDefaultMayor'] ?? 0)
          .toDouble(),
      precioPaquete: json['precioPaquete']?.toDouble(), // Nuevo campo
      requiereColor: json['requiereColor'] ?? false,
      codigoColor: json['codigoColor'],
      categoria: json['categoria'] ?? '',
      permiteVentaParcial: json['permiteVentaParcial'] ?? true,
      unidadMedidaSecundaria: json['unidadMedidaSecundaria'],
      deleted: json['deleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'], // Nuevo campo
      updatedBy: json['updatedBy'], // Nuevo campo
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEmpresa': idEmpresa,
      'nombre': nombre,
      'descripcion': descripcion,
      'unidadMedida': unidadMedida,
      'cantidadesPosibles': cantidadesPosibles
          .map((e) => e.toString())
          .toList(),
      'cantidadPrioritaria': cantidadPrioritaria,
      'precioCompraDefault': precioCompraDefault,
      'precioVentaDefaultMenor': precioVentaDefaultMenor,
      'precioVentaDefaultMayor': precioVentaDefaultMayor,
      'precioPaquete': precioPaquete, // Nuevo campo
      'requiereColor': requiereColor,
      'codigoColor': codigoColor,
      'categoria': categoria,
      'permiteVentaParcial': permiteVentaParcial,
      'unidadMedidaSecundaria': unidadMedidaSecundaria,
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy, // Nuevo campo
      'updatedBy': updatedBy, // Nuevo campo
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
    double? precioPaquete, // Nuevo campo
    bool? requiereColor,
    String? codigoColor,
    String? categoria,
    bool? permiteVentaParcial,
    String? unidadMedidaSecundaria,
    bool? deleted,
    String? createdBy, // Nuevo campo
    String? updatedBy, // Nuevo campo
  }) {
    return TipoProducto(
      id: id,
      idEmpresa: idEmpresa ?? this.idEmpresa,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      cantidadesPosibles: cantidadesPosibles ?? this.cantidadesPosibles,
      cantidadPrioritaria: cantidadPrioritaria ?? this.cantidadPrioritaria,
      precioCompraDefault: precioCompraDefault ?? this.precioCompraDefault,
      precioVentaDefaultMenor:
          precioVentaDefaultMenor ?? this.precioVentaDefaultMenor,
      precioVentaDefaultMayor:
          precioVentaDefaultMayor ?? this.precioVentaDefaultMayor,
      precioPaquete: precioPaquete ?? this.precioPaquete, // Nuevo campo
      requiereColor: requiereColor ?? this.requiereColor,
      codigoColor: codigoColor ?? this.codigoColor,
      categoria: categoria ?? this.categoria,
      permiteVentaParcial: permiteVentaParcial ?? this.permiteVentaParcial,
      unidadMedidaSecundaria:
          unidadMedidaSecundaria ?? this.unidadMedidaSecundaria,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      createdBy: createdBy ?? this.createdBy, // Nuevo campo
      updatedBy: updatedBy ?? this.updatedBy, // Nuevo campo
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
      precioPaquete: null, // Nuevo campo
      requiereColor: false,
      categoria: '',
      permiteVentaParcial: false,
      deleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: null, // Nuevo campo
      updatedBy: null, // Nuevo campo
    );
  }
}
