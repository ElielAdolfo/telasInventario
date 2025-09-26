// lib/features/empresa/models/stock_tienda_model.dart

class StockTienda {
  final String id;
  final String idTienda;
  final String idEmpresa;
  final String? idTipoProducto;
  final String? idColor;
  final int cantidad;
  final int cantidadVendida;
  final double precioCompra;
  final double precioVentaMenor;
  final double precioVentaMayor;
  final DateTime fechaIngresoStock;
  final String? idSolicitudTraslado;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Campos adicionales copiados de SolicitudTraslado (que a su vez los copió de StockEmpresa)
  final String categoria;
  final String nombre;
  final String unidadMedida;
  final String? unidadMedidaSecundaria;
  final bool permiteVentaParcial;
  final bool requiereColor;
  final List<int> cantidadesPosibles;
  final int cantidadPrioritaria;
  final String? lote;
  final DateTime? fechaVencimiento;
  final String? colorNombre;
  final String? colorCodigo;
  final List<String> idsLotes;

  int get cantidadDisponible => cantidad - cantidadVendida;

  StockTienda({
    required this.id,
    required this.idTienda,
    required this.idEmpresa,
    required this.idTipoProducto,
    this.idColor,
    required this.cantidad,
    required this.cantidadVendida,
    required this.precioCompra,
    required this.precioVentaMenor,
    required this.precioVentaMayor,
    required this.fechaIngresoStock,
    this.idSolicitudTraslado,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
    // Campos adicionales copiados de SolicitudTraslado
    required this.categoria,
    required this.nombre,
    required this.unidadMedida,
    required this.unidadMedidaSecundaria,
    required this.permiteVentaParcial,
    required this.requiereColor,
    required this.cantidadesPosibles,
    required this.cantidadPrioritaria,
    required this.lote,
    required this.fechaVencimiento,
    required this.colorNombre,
    required this.colorCodigo,
    required this.idsLotes,
  });

  factory StockTienda.fromJson(Map<String, dynamic> json, String id) {
    List<int> cantidadesPosibles = [];
    if (json['cantidadesPosibles'] != null) {
      cantidadesPosibles = List<int>.from(
        json['cantidadesPosibles'].map((x) => int.parse(x.toString())),
      );
    }

    List<String> idsLotes = [];
    if (json['idsLotes'] != null) {
      idsLotes = List<String>.from(json['idsLotes']);
    }

    return StockTienda(
      id: id,
      idTienda: json['idTienda'] ?? '',
      idEmpresa: json['idEmpresa'] ?? '',
      idTipoProducto: json['idTipoProducto'] ?? '',
      idColor: json['idColor'],
      cantidad: json['cantidad'] ?? 0,
      cantidadVendida: json['cantidadVendida'] ?? 0,
      precioCompra: (json['precioCompra'] ?? 0).toDouble(),
      precioVentaMenor: (json['precioVentaMenor'] ?? 0).toDouble(),
      precioVentaMayor: (json['precioVentaMayor'] ?? 0).toDouble(),
      fechaIngresoStock: DateTime.parse(json['fechaIngresoStock']),
      idSolicitudTraslado: json['idSolicitudTraslado'],
      deleted: json['deleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      // Campos adicionales copiados de SolicitudTraslado
      categoria: json['categoria'] ?? '',
      nombre: json['nombre'] ?? '',
      unidadMedida: json['unidadMedida'] ?? '',
      unidadMedidaSecundaria: json['unidadMedidaSecundaria'],
      permiteVentaParcial: json['permiteVentaParcial'] ?? false,
      requiereColor: json['requiereColor'] ?? false,
      cantidadesPosibles: cantidadesPosibles,
      cantidadPrioritaria: json['cantidadPrioritaria'] ?? 0,
      lote: json['lote'],
      fechaVencimiento: json['fechaVencimiento'] != null
          ? DateTime.parse(json['fechaVencimiento'])
          : null,
      colorNombre: json['colorNombre'],
      colorCodigo: json['colorCodigo'],
      idsLotes: idsLotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idTienda': idTienda,
      'idEmpresa': idEmpresa,
      'idTipoProducto': idTipoProducto,
      'idColor': idColor,
      'cantidad': cantidad,
      'cantidadVendida': cantidadVendida,
      'precioCompra': precioCompra,
      'precioVentaMenor': precioVentaMenor,
      'precioVentaMayor': precioVentaMayor,
      'fechaIngresoStock': fechaIngresoStock.toIso8601String(),
      'idSolicitudTraslado': idSolicitudTraslado,
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // Campos adicionales copiados de SolicitudTraslado
      'categoria': categoria,
      'nombre': nombre,
      'unidadMedida': unidadMedida,
      'unidadMedidaSecundaria': unidadMedidaSecundaria,
      'permiteVentaParcial': permiteVentaParcial,
      'requiereColor': requiereColor,
      'cantidadesPosibles': cantidadesPosibles,
      'cantidadPrioritaria': cantidadPrioritaria,
      'lote': lote,
      'fechaVencimiento': fechaVencimiento?.toIso8601String(),
      'colorNombre': colorNombre,
      'colorCodigo': colorCodigo,
      'idsLotes': idsLotes,
    };
  }

  StockTienda copyWith({
    int? cantidad,
    int? cantidadVendida,
    double? precioCompra,
    double? precioVentaMenor,
    double? precioVentaMayor,
    DateTime? fechaIngresoStock,
    bool? deleted,
    // Campos adicionales copiados de SolicitudTraslado
    String? categoria,
    String? nombre,
    String? unidadMedida,
    String? unidadMedidaSecundaria,
    bool? permiteVentaParcial,
    bool? requiereColor,
    List<int>? cantidadesPosibles,
    int? cantidadPrioritaria,
    String? lote,
    DateTime? fechaVencimiento,
    String? colorNombre,
    String? colorCodigo,
    List<String>? idsLotes,
  }) {
    return StockTienda(
      id: id,
      idTienda: idTienda,
      idEmpresa: idEmpresa,
      idTipoProducto: idTipoProducto,
      idColor: idColor,
      cantidad: cantidad ?? this.cantidad,
      cantidadVendida: cantidadVendida ?? this.cantidadVendida,
      precioCompra: precioCompra ?? this.precioCompra,
      precioVentaMenor: precioVentaMenor ?? this.precioVentaMenor,
      precioVentaMayor: precioVentaMayor ?? this.precioVentaMayor,
      fechaIngresoStock: fechaIngresoStock ?? this.fechaIngresoStock,
      idSolicitudTraslado: idSolicitudTraslado,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      // Campos adicionales copiados de SolicitudTraslado
      categoria: categoria ?? this.categoria,
      nombre: nombre ?? this.nombre,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      unidadMedidaSecundaria:
          unidadMedidaSecundaria ?? this.unidadMedidaSecundaria,
      permiteVentaParcial: permiteVentaParcial ?? this.permiteVentaParcial,
      requiereColor: requiereColor ?? this.requiereColor,
      cantidadesPosibles: cantidadesPosibles ?? this.cantidadesPosibles,
      cantidadPrioritaria: cantidadPrioritaria ?? this.cantidadPrioritaria,
      lote: lote ?? this.lote,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      colorNombre: colorNombre ?? this.colorNombre,
      colorCodigo: colorCodigo ?? this.colorCodigo,
      idsLotes: idsLotes ?? this.idsLotes,
    );
  }

  // Nuevo método estático empty
  static StockTienda empty() {
    return StockTienda(
      id: '',
      idTienda: '',
      idEmpresa: '',
      idTipoProducto: '',
      idColor: '',
      cantidad: 0,
      cantidadVendida: 0,
      precioCompra: 0,
      precioVentaMenor: 0,
      precioVentaMayor: 0,
      fechaIngresoStock: DateTime.now(),
      idSolicitudTraslado: '',
      deleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      categoria: '',
      nombre: '',
      unidadMedida: '',
      unidadMedidaSecundaria: '',
      permiteVentaParcial: false,
      requiereColor: false,
      cantidadesPosibles: [],
      cantidadPrioritaria: 0,
      lote: '',
      fechaVencimiento: null,
      colorNombre: '',
      colorCodigo: '',
      idsLotes: [],
    );
  }
}
