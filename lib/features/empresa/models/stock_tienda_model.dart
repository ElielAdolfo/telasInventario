// lib/features/empresa/models/stock_tienda_model.dart

class StockTienda {
  final String id;
  final String idEmpresa;
  final String idTienda;
  final String? idTipoProducto;
  final String? idColor;

  final int unidades; // Unidades enteras
  final double cantidad; // Puede tener 2 decimales (nuevo campo)
  final double cantidadVendida;
  final double cantidadAperturada; // Aperturado del stock

  final double precioCompra;
  final double precioVentaMenor;
  final double precioVentaMayor;
  final double? precioPaquete; // Precio por paquete (opcional)

  final DateTime fechaIngresoStock;
  final String? idSolicitudTraslado;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Campos adicionales copiados de SolicitudTraslado
  final String categoria;
  final String nombre;
  final String unidadMedida;
  final String? unidadMedidaSecundaria;
  final bool permiteVentaParcial;
  final bool requiereColor;
  final String? lote;
  final DateTime? fechaVencimiento;
  final String? colorNombre;
  final String? colorCodigo;
  final List<String> idsLotes;

  double get cantidadDisponible =>
      unidades - cantidadAperturada - cantidadVendida;

  StockTienda({
    required this.id,
    required this.idTienda,
    required this.idEmpresa,
    required this.idTipoProducto,
    this.idColor,
    required this.unidades,
    required this.cantidad,
    required this.cantidadVendida,
    required this.cantidadAperturada,
    required this.precioCompra,
    required this.precioVentaMenor,
    required this.precioVentaMayor,
    this.precioPaquete,
    required this.fechaIngresoStock,
    this.idSolicitudTraslado,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
    required this.categoria,
    required this.nombre,
    required this.unidadMedida,
    required this.unidadMedidaSecundaria,
    required this.permiteVentaParcial,
    required this.requiereColor,
    required this.lote,
    required this.fechaVencimiento,
    required this.colorNombre,
    required this.colorCodigo,
    required this.idsLotes,
  });

  factory StockTienda.fromJson(Map<String, dynamic> json, String id) {

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
      unidades: json['unidades'] ?? 0,
      cantidad: (json['cantidad'] ?? 0).toDouble(),
      cantidadVendida: (json['cantidadVendida'] ?? 0).toDouble(),
      cantidadAperturada: (json['cantidadAperturada'] ?? 0).toDouble(),
      precioCompra: (json['precioCompra'] ?? 0).toDouble(),
      precioVentaMenor: (json['precioVentaMenor'] ?? 0).toDouble(),
      precioVentaMayor: (json['precioVentaMayor'] ?? 0).toDouble(),
      precioPaquete: json['precioPaquete']?.toDouble(),
      fechaIngresoStock: DateTime.parse(json['fechaIngresoStock']),
      idSolicitudTraslado: json['idSolicitudTraslado'],
      deleted: json['deleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      categoria: json['categoria'] ?? '',
      nombre: json['nombre'] ?? '',
      unidadMedida: json['unidadMedida'] ?? '',
      unidadMedidaSecundaria: json['unidadMedidaSecundaria'],
      permiteVentaParcial: json['permiteVentaParcial'] ?? false,
      requiereColor: json['requiereColor'] ?? false,
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
      'unidades': unidades,
      'cantidad': cantidad,
      'cantidadVendida': cantidadVendida,
      'cantidadAperturada': cantidadAperturada,
      'precioCompra': precioCompra,
      'precioVentaMenor': precioVentaMenor,
      'precioVentaMayor': precioVentaMayor,
      'precioPaquete': precioPaquete,
      'fechaIngresoStock': fechaIngresoStock.toIso8601String(),
      'idSolicitudTraslado': idSolicitudTraslado,
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'categoria': categoria,
      'nombre': nombre,
      'unidadMedida': unidadMedida,
      'unidadMedidaSecundaria': unidadMedidaSecundaria,
      'permiteVentaParcial': permiteVentaParcial,
      'requiereColor': requiereColor,
      'lote': lote,
      'fechaVencimiento': fechaVencimiento?.toIso8601String(),
      'colorNombre': colorNombre,
      'colorCodigo': colorCodigo,
      'idsLotes': idsLotes,
    };
  }

  StockTienda copyWith({
    String? id,
    String? idEmpresa,
    String? idTienda,
    String? idTipoProducto,
    String? idColor,
    int? unidades,
    double? cantidad,
    double? cantidadVendida,
    double? cantidadAperturada,
    double? precioCompra,
    double? precioVentaMenor,
    double? precioVentaMayor,
    double? precioPaquete,
    DateTime? fechaIngresoStock,
    String? idSolicitudTraslado,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoria,
    String? nombre,
    String? unidadMedida,
    String? unidadMedidaSecundaria,
    bool? permiteVentaParcial,
    bool? requiereColor,
    String? lote,
    DateTime? fechaVencimiento,
    String? colorNombre,
    String? colorCodigo,
    List<String>? idsLotes,
  }) {
    return StockTienda(
      id: id ?? this.id,
      idTienda: idTienda ?? this.idTienda,
      idEmpresa: idEmpresa ?? this.idEmpresa,
      idTipoProducto: idTipoProducto ?? this.idTipoProducto,
      idColor: idColor ?? this.idColor,
      unidades: unidades ?? this.unidades,
      cantidad: cantidad ?? this.cantidad,
      cantidadVendida: cantidadVendida ?? this.cantidadVendida,
      cantidadAperturada: cantidadAperturada ?? this.cantidadAperturada,
      precioCompra: precioCompra ?? this.precioCompra,
      precioVentaMenor: precioVentaMenor ?? this.precioVentaMenor,
      precioVentaMayor: precioVentaMayor ?? this.precioVentaMayor,
      precioPaquete: precioPaquete ?? this.precioPaquete,
      fechaIngresoStock: fechaIngresoStock ?? this.fechaIngresoStock,
      idSolicitudTraslado: idSolicitudTraslado ?? this.idSolicitudTraslado,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoria: categoria ?? this.categoria,
      nombre: nombre ?? this.nombre,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      unidadMedidaSecundaria:
          unidadMedidaSecundaria ?? this.unidadMedidaSecundaria,
      permiteVentaParcial: permiteVentaParcial ?? this.permiteVentaParcial,
      requiereColor: requiereColor ?? this.requiereColor,
      lote: lote ?? this.lote,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      colorNombre: colorNombre ?? this.colorNombre,
      colorCodigo: colorCodigo ?? this.colorCodigo,
      idsLotes: idsLotes ?? this.idsLotes,
    );
  }

  static StockTienda empty() {
    return StockTienda(
      id: '',
      idTienda: '',
      idEmpresa: '',
      idTipoProducto: '',
      idColor: '',
      unidades: 0,
      cantidad: 0,
      cantidadVendida: 0,
      cantidadAperturada: 0,
      precioCompra: 0,
      precioVentaMenor: 0,
      precioVentaMayor: 0,
      precioPaquete: 0,
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
      lote: '',
      fechaVencimiento: null,
      colorNombre: '',
      colorCodigo: '',
      idsLotes: [],
    );
  }

  @override
  String toString() {
    return 'StockTienda('
        'id: $id, '
        'idTienda: $idTienda, '
        'idEmpresa: $idEmpresa, '
        'idTipoProducto: $idTipoProducto, '
        'idColor: $idColor, '
        'unidades: $unidades, '
        'cantidad: $cantidad, '
        'cantidadVendida: $cantidadVendida, '
        'cantidadAperturada: $cantidadAperturada, '
        'cantidadDisponible: $cantidadDisponible, '
        'precioCompra: $precioCompra, '
        'precioVentaMenor: $precioVentaMenor, '
        'precioVentaMayor: $precioVentaMayor, '
        'precioPaquete: $precioPaquete, '
        'fechaIngresoStock: $fechaIngresoStock, '
        'categoria: $categoria, '
        'nombre: $nombre, '
        'unidadMedida: $unidadMedida, '
        'unidadMedidaSecundaria: $unidadMedidaSecundaria, '
        'permiteVentaParcial: $permiteVentaParcial, '
        'requiereColor: $requiereColor, '
        'lote: $lote, '
        'fechaVencimiento: $fechaVencimiento, '
        'colorNombre: $colorNombre, '
        'colorCodigo: $colorCodigo, '
        'deleted: $deleted, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'idsLotes: $idsLotes'
        ')';
  }
}
