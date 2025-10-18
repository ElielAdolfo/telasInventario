class SolicitudTraslado {
  // Identificación
  final String id;
  final String idEmpresa;
  final String idTienda;
  final String idStockOrigen;
  final String tipoSolicitud; // "EMPRESA_A_TIENDA" o "TIENDA_A_EMPRESA"
  final int cantidadSolicitada;
  final double cantidad; // Puede tener decimales
  final String
  estado; // RESERVADO, APROBADO, RECHAZADO, EN_TRASLADO, RECIBIDO, DEVUELTO, CANCELADO
  final DateTime fechaSolicitud;
  final String? idStockDestino;
  final String? motivo;
  final String? motivoRechazo;
  final String? observacionesRecepcion;
  final String? motivoDevolucion;
  final String? solicitadoPor;
  final String? aprobadoPor;
  final String? recibidoPor;
  final String? devueltoPor;
  final DateTime? fechaAprobacion;
  final DateTime? fechaRecepcion;
  final DateTime? fechaDevolucion;
  final DateTime? fechaRechazo;
  final String? correlativo;
  final String? codigoUnico;

  // Moneda y tipo de cambio
  final String idMoneda;
  final double tipoCambio;

  // Campos copiados de StockEmpresa para mantener historial
  final String categoria;
  final String nombre;
  final String unidadMedida;
  final String? unidadMedidaSecundaria;
  final bool permiteVentaParcial;
  final bool requiereColor;
  final double precioCompra;
  final double precioVentaMenor;
  final double precioVentaMayor;
  final double? precioPaquete;
  final String? lote;
  final DateTime? fechaVencimiento;
  final String? colorNombre;
  final String? colorCodigo;

  // IDs para referencia
  final String? idTipoProducto;
  final String? idColor;

  // Auditoría
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;

  // Constructor
  SolicitudTraslado({
    required this.id,
    required this.idEmpresa,
    required this.idTienda,
    required this.idStockOrigen,
    required this.tipoSolicitud,
    required this.cantidadSolicitada,
    required this.cantidad,
    required this.estado,
    required this.fechaSolicitud,
    this.idStockDestino,
    this.motivo,
    this.motivoRechazo,
    this.observacionesRecepcion,
    this.motivoDevolucion,
    this.solicitadoPor,
    this.aprobadoPor,
    this.recibidoPor,
    this.devueltoPor,
    this.fechaAprobacion,
    this.fechaRecepcion,
    this.fechaDevolucion,
    this.fechaRechazo,
    this.correlativo,
    this.codigoUnico,
    required this.idMoneda,
    required this.tipoCambio,
    required this.categoria,
    required this.nombre,
    required this.unidadMedida,
    this.unidadMedidaSecundaria,
    required this.permiteVentaParcial,
    required this.requiereColor,
    required this.precioCompra,
    required this.precioVentaMenor,
    required this.precioVentaMayor,
    this.precioPaquete,
    this.lote,
    this.fechaVencimiento,
    this.colorNombre,
    this.colorCodigo,
    this.idTipoProducto,
    this.idColor,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
  });

  // fromJson
  factory SolicitudTraslado.fromJson(Map<String, dynamic> json, String id) {
    return SolicitudTraslado(
      id: id,
      idEmpresa: json['idEmpresa'] ?? '',
      idTienda: json['idTienda'] ?? '',
      idStockOrigen: json['idStockOrigen'] ?? '',
      tipoSolicitud: json['tipoSolicitud'] ?? '',
      cantidadSolicitada: json['cantidadSolicitada'] ?? 0,
      cantidad: (json['cantidad'] ?? 0).toDouble(),
      estado: json['estado'] ?? '',
      fechaSolicitud: DateTime.parse(json['fechaSolicitud']),
      idStockDestino: json['idStockDestino'],
      motivo: json['motivo'],
      motivoRechazo: json['motivoRechazo'],
      observacionesRecepcion: json['observacionesRecepcion'],
      motivoDevolucion: json['motivoDevolucion'],
      solicitadoPor: json['solicitadoPor'],
      aprobadoPor: json['aprobadoPor'],
      recibidoPor: json['recibidoPor'],
      devueltoPor: json['devueltoPor'],
      fechaAprobacion: json['fechaAprobacion'] != null
          ? DateTime.parse(json['fechaAprobacion'])
          : null,
      fechaRecepcion: json['fechaRecepcion'] != null
          ? DateTime.parse(json['fechaRecepcion'])
          : null,
      fechaDevolucion: json['fechaDevolucion'] != null
          ? DateTime.parse(json['fechaDevolucion'])
          : null,
      fechaRechazo: json['fechaRechazo'] != null
          ? DateTime.parse(json['fechaRechazo'])
          : null,
      correlativo: json['correlativo'],
      codigoUnico: json['codigoUnico'],
      idMoneda: json['idMoneda'] ?? '',
      tipoCambio: (json['tipoCambio'] ?? 0).toDouble(),
      categoria: json['categoria'] ?? '',
      nombre: json['nombre'] ?? '',
      unidadMedida: json['unidadMedida'] ?? '',
      unidadMedidaSecundaria: json['unidadMedidaSecundaria'],
      permiteVentaParcial: json['permiteVentaParcial'] ?? false,
      requiereColor: json['requiereColor'] ?? false,
      precioCompra: (json['precioCompra'] ?? 0).toDouble(),
      precioVentaMenor: (json['precioVentaMenor'] ?? 0).toDouble(),
      precioVentaMayor: (json['precioVentaMayor'] ?? 0).toDouble(),
      precioPaquete: json['precioPaquete']?.toDouble(),
      lote: json['lote'],
      fechaVencimiento: json['fechaVencimiento'] != null
          ? DateTime.parse(json['fechaVencimiento'])
          : null,
      colorNombre: json['colorNombre'],
      colorCodigo: json['colorCodigo'],
      idTipoProducto: json['idTipoProducto'],
      idColor: json['idColor'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      deletedBy: json['deletedBy'],
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'idEmpresa': idEmpresa,
      'idTienda': idTienda,
      'idStockOrigen': idStockOrigen,
      'tipoSolicitud': tipoSolicitud,
      'cantidadSolicitada': cantidadSolicitada,
      'cantidad': cantidad,
      'estado': estado,
      'fechaSolicitud': fechaSolicitud.toIso8601String(),
      'idStockDestino': idStockDestino,
      'motivo': motivo,
      'motivoRechazo': motivoRechazo,
      'observacionesRecepcion': observacionesRecepcion,
      'motivoDevolucion': motivoDevolucion,
      'solicitadoPor': solicitadoPor,
      'aprobadoPor': aprobadoPor,
      'recibidoPor': recibidoPor,
      'devueltoPor': devueltoPor,
      'fechaAprobacion': fechaAprobacion?.toIso8601String(),
      'fechaRecepcion': fechaRecepcion?.toIso8601String(),
      'fechaDevolucion': fechaDevolucion?.toIso8601String(),
      'fechaRechazo': fechaRechazo?.toIso8601String(),
      'correlativo': correlativo,
      'codigoUnico': codigoUnico,
      'idMoneda': idMoneda,
      'tipoCambio': tipoCambio,
      'categoria': categoria,
      'nombre': nombre,
      'unidadMedida': unidadMedida,
      'unidadMedidaSecundaria': unidadMedidaSecundaria,
      'permiteVentaParcial': permiteVentaParcial,
      'requiereColor': requiereColor,
      'precioCompra': precioCompra,
      'precioVentaMenor': precioVentaMenor,
      'precioVentaMayor': precioVentaMayor,
      'precioPaquete': precioPaquete,
      'lote': lote,
      'fechaVencimiento': fechaVencimiento?.toIso8601String(),
      'colorNombre': colorNombre,
      'colorCodigo': colorCodigo,
      'idTipoProducto': idTipoProducto,
      'idColor': idColor,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'deletedBy': deletedBy,
    };
  }

  // copyWith
  SolicitudTraslado copyWith({
    String? estado,
    String? idStockDestino,
    String? motivo,
    String? motivoRechazo,
    String? observacionesRecepcion,
    String? motivoDevolucion,
    String? aprobadoPor,
    String? recibidoPor,
    String? devueltoPor,
    DateTime? fechaSolicitud,
    DateTime? fechaAprobacion,
    DateTime? fechaRecepcion,
    DateTime? fechaDevolucion,
    DateTime? fechaRechazo,
    String? correlativo,
    String? codigoUnico,
    String? idMoneda,
    double? tipoCambio,
    String? categoria,
    String? nombre,
    String? unidadMedida,
    String? unidadMedidaSecundaria,
    bool? permiteVentaParcial,
    bool? requiereColor,
    double? precioCompra,
    double? precioVentaMenor,
    double? precioVentaMayor,
    double? precioPaquete,
    double? cantidad,
    String? lote,
    DateTime? fechaVencimiento,
    String? colorNombre,
    String? colorCodigo,
    String? idTipoProducto,
    String? idColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? createdBy,
    String? updatedBy,
    String? deletedBy,
  }) {
    return SolicitudTraslado(
      id: id,
      idEmpresa: idEmpresa,
      idTienda: idTienda,
      idStockOrigen: idStockOrigen,
      tipoSolicitud: tipoSolicitud,
      cantidadSolicitada: cantidadSolicitada,
      cantidad: cantidad ?? this.cantidad,
      estado: estado ?? this.estado,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      idStockDestino: idStockDestino ?? this.idStockDestino,
      motivo: motivo ?? this.motivo,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
      observacionesRecepcion:
          observacionesRecepcion ?? this.observacionesRecepcion,
      motivoDevolucion: motivoDevolucion ?? this.motivoDevolucion,
      aprobadoPor: aprobadoPor ?? this.aprobadoPor,
      recibidoPor: recibidoPor ?? this.recibidoPor,
      devueltoPor: devueltoPor ?? this.devueltoPor,
      fechaAprobacion: fechaAprobacion ?? this.fechaAprobacion,
      fechaRecepcion: fechaRecepcion ?? this.fechaRecepcion,
      fechaDevolucion: fechaDevolucion ?? this.fechaDevolucion,
      fechaRechazo: fechaRechazo ?? this.fechaRechazo,
      correlativo: correlativo ?? this.correlativo,
      codigoUnico: codigoUnico ?? this.codigoUnico,
      idMoneda: idMoneda ?? this.idMoneda,
      tipoCambio: tipoCambio ?? this.tipoCambio,
      categoria: categoria ?? this.categoria,
      nombre: nombre ?? this.nombre,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      unidadMedidaSecundaria:
          unidadMedidaSecundaria ?? this.unidadMedidaSecundaria,
      permiteVentaParcial: permiteVentaParcial ?? this.permiteVentaParcial,
      requiereColor: requiereColor ?? this.requiereColor,
      precioCompra: precioCompra ?? this.precioCompra,
      precioVentaMenor: precioVentaMenor ?? this.precioVentaMenor,
      precioVentaMayor: precioVentaMayor ?? this.precioVentaMayor,
      precioPaquete: precioPaquete ?? this.precioPaquete,
      lote: lote ?? this.lote,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      colorNombre: colorNombre ?? this.colorNombre,
      colorCodigo: colorCodigo ?? this.colorCodigo,
      idTipoProducto: idTipoProducto ?? this.idTipoProducto,
      idColor: idColor ?? this.idColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }

  // empty
  factory SolicitudTraslado.empty() {
    return SolicitudTraslado(
      id: '',
      idEmpresa: '',
      idTienda: '',
      idStockOrigen: '',
      tipoSolicitud: '',
      cantidadSolicitada: 0,
      cantidad: 0.0,
      estado: '',
      fechaSolicitud: DateTime.now(),
      idStockDestino: null,
      motivo: null,
      motivoRechazo: null,
      observacionesRecepcion: null,
      motivoDevolucion: null,
      solicitadoPor: null,
      aprobadoPor: null,
      recibidoPor: null,
      devueltoPor: null,
      fechaAprobacion: null,
      fechaRecepcion: null,
      fechaDevolucion: null,
      fechaRechazo: null,
      correlativo: null,
      codigoUnico: null,
      idMoneda: 'USD',
      tipoCambio: 1.0,
      categoria: '',
      nombre: '',
      unidadMedida: '',
      unidadMedidaSecundaria: null,
      permiteVentaParcial: false,
      requiereColor: false,
      precioCompra: 0.0,
      precioVentaMenor: 0.0,
      precioVentaMayor: 0.0,
      precioPaquete: null,
      lote: null,
      fechaVencimiento: null,
      colorNombre: null,
      colorCodigo: null,
      idTipoProducto: null,
      idColor: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deletedAt: null,
      createdBy: null,
      updatedBy: null,
      deletedBy: null,
    );
  }
}
