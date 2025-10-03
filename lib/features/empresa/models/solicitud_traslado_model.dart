// lib/features/solicitudes/models/solicitud_traslado_model.dart

class SolicitudTraslado {
  final String id;
  final String idEmpresa;
  final String idTienda;
  final String idStockOrigen;
  final String tipoSolicitud; // "EMPRESA_A_TIENDA" o "TIENDA_A_EMPRESA"
  final int cantidadSolicitada;
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

  // Campos copiados de StockEmpresa para mantener un registro histórico
  final String categoria;
  final String nombre;
  final String unidadMedida;
  final String? unidadMedidaSecundaria;
  final bool permiteVentaParcial;
  final bool requiereColor;
  final List<int> cantidadesPosibles;
  final int cantidadPrioritaria;
  final double precioCompra;
  final double precioVentaMenor;
  final double precioVentaMayor;
  final double? precioPaquete; // Nuevo campo: precio por paquete
  final String? lote;
  final DateTime? fechaVencimiento;
  final String? colorNombre;
  final String? colorCodigo;

  // IDs para referencia
  final String? idTipoProducto;
  final String? idColor;

  // Campos de auditoría
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;
  SolicitudTraslado({
    required this.id,
    required this.idEmpresa,
    required this.idTienda,
    required this.idStockOrigen,
    required this.tipoSolicitud,
    required this.cantidadSolicitada,
    required this.estado,
    required this.fechaSolicitud,
    this.correlativo,
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
    // Campos copiados de StockEmpresa
    required this.categoria,
    required this.nombre,
    required this.unidadMedida,
    required this.unidadMedidaSecundaria,
    required this.permiteVentaParcial,
    required this.requiereColor,
    required this.cantidadesPosibles,
    required this.cantidadPrioritaria,
    required this.precioCompra,
    required this.precioVentaMenor,
    required this.precioVentaMayor,
    this.precioPaquete, // Nuevo campo
    required this.lote,
    required this.fechaVencimiento,
    required this.colorNombre,
    required this.colorCodigo,
    // IDs para referencia
    this.idTipoProducto,
    this.idColor,
    // Campos de auditoría
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
  });

  factory SolicitudTraslado.fromJson(Map<String, dynamic> json, String id) {
    List<int> cantidadesPosibles = [];
    if (json['cantidadesPosibles'] != null) {
      cantidadesPosibles = List<int>.from(
        json['cantidadesPosibles'].map((x) => int.parse(x.toString())),
      );
    }

    return SolicitudTraslado(
      id: id,
      idEmpresa: json['idEmpresa'] ?? '',
      idTienda: json['idTienda'] ?? '',
      idStockOrigen: json['idStockOrigen'] ?? '',
      tipoSolicitud: json['tipoSolicitud'] ?? '',
      cantidadSolicitada: json['cantidadSolicitada'] ?? 0,
      estado: json['estado'] ?? '',
      fechaSolicitud: DateTime.parse(json['fechaSolicitud']),
      correlativo: json['correlativo'],
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
      // Campos copiados de StockEmpresa
      categoria: json['categoria'] ?? '',
      nombre: json['nombre'] ?? '',
      unidadMedida: json['unidadMedida'] ?? '',
      unidadMedidaSecundaria: json['unidadMedidaSecundaria'],
      permiteVentaParcial: json['permiteVentaParcial'] ?? false,
      requiereColor: json['requiereColor'] ?? false,
      cantidadesPosibles: cantidadesPosibles,
      cantidadPrioritaria: json['cantidadPrioritaria'] ?? 0,
      precioCompra: (json['precioCompra'] ?? 0).toDouble(),
      precioVentaMenor: (json['precioVentaMenor'] ?? 0).toDouble(),
      precioVentaMayor: (json['precioVentaMayor'] ?? 0).toDouble(),
      precioPaquete: json['precioPaquete']?.toDouble(), // Nuevo campo
      lote: json['lote'],
      fechaVencimiento: json['fechaVencimiento'] != null
          ? DateTime.parse(json['fechaVencimiento'])
          : null,
      colorNombre: json['colorNombre'],
      colorCodigo: json['colorCodigo'],
      // IDs para referencia
      idTipoProducto: json['idTipoProducto'],
      idColor: json['idColor'],
      // Campos de auditoría
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

  Map<String, dynamic> toJson() {
    return {
      'idEmpresa': idEmpresa,
      'idTienda': idTienda,
      'idStockOrigen': idStockOrigen,
      'tipoSolicitud': tipoSolicitud,
      'cantidadSolicitada': cantidadSolicitada,
      'estado': estado,
      'fechaSolicitud': fechaSolicitud.toIso8601String(),
      'correlativo': correlativo,
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
      // Campos copiados de StockEmpresa
      'categoria': categoria,
      'nombre': nombre,
      'unidadMedida': unidadMedida,
      'unidadMedidaSecundaria': unidadMedidaSecundaria,
      'permiteVentaParcial': permiteVentaParcial,
      'requiereColor': requiereColor,
      'cantidadesPosibles': cantidadesPosibles,
      'cantidadPrioritaria': cantidadPrioritaria,
      'precioCompra': precioCompra,
      'precioVentaMenor': precioVentaMenor,
      'precioVentaMayor': precioVentaMayor,
      'precioPaquete': precioPaquete, // Nuevo campo
      'lote': lote,
      'fechaVencimiento': fechaVencimiento?.toIso8601String(),
      'colorNombre': colorNombre,
      'colorCodigo': colorCodigo,
      // IDs para referencia
      'idTipoProducto': idTipoProducto,
      'idColor': idColor,
      // Campos de auditoría
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'deletedBy': deletedBy,
    };
  }

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
    // Campos copiados de StockEmpresa
    String? categoria,
    String? nombre,
    String? unidadMedida,
    String? unidadMedidaSecundaria,
    bool? permiteVentaParcial,
    bool? requiereColor,
    List<int>? cantidadesPosibles,
    int? cantidadPrioritaria,
    double? precioCompra,
    double? precioVentaMenor,
    double? precioVentaMayor,
    double? precioPaquete, // Nuevo campo
    String? lote,
    DateTime? fechaVencimiento,
    String? colorNombre,
    String? colorCodigo,
    // IDs para referencia
    String? idTipoProducto,
    String? idColor,
    // Campos de auditoría
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
      estado: estado ?? this.estado,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      correlativo: correlativo ?? this.correlativo,
      idStockDestino: idStockDestino ?? this.idStockDestino,
      motivo: motivo ?? this.motivo,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
      observacionesRecepcion:
          observacionesRecepcion ?? this.observacionesRecepcion,
      motivoDevolucion: motivoDevolucion ?? this.motivoDevolucion,
      solicitadoPor: solicitadoPor,
      aprobadoPor: aprobadoPor ?? this.aprobadoPor,
      recibidoPor: recibidoPor ?? this.recibidoPor,
      devueltoPor: devueltoPor ?? this.devueltoPor,
      fechaAprobacion: fechaAprobacion ?? this.fechaAprobacion,
      fechaRecepcion: fechaRecepcion ?? this.fechaRecepcion,
      fechaDevolucion: fechaDevolucion ?? this.fechaDevolucion,
      fechaRechazo: fechaRechazo ?? this.fechaRechazo,
      // Campos copiados de StockEmpresa
      categoria: categoria ?? this.categoria,
      nombre: nombre ?? this.nombre,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      unidadMedidaSecundaria:
          unidadMedidaSecundaria ?? this.unidadMedidaSecundaria,
      permiteVentaParcial: permiteVentaParcial ?? this.permiteVentaParcial,
      requiereColor: requiereColor ?? this.requiereColor,
      cantidadesPosibles: cantidadesPosibles ?? this.cantidadesPosibles,
      cantidadPrioritaria: cantidadPrioritaria ?? this.cantidadPrioritaria,
      precioCompra: precioCompra ?? this.precioCompra,
      precioVentaMenor: precioVentaMenor ?? this.precioVentaMenor,
      precioVentaMayor: precioVentaMayor ?? this.precioVentaMayor,
      precioPaquete: precioPaquete ?? this.precioPaquete, // Nuevo campo
      lote: lote ?? this.lote,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      colorNombre: colorNombre ?? this.colorNombre,
      colorCodigo: colorCodigo ?? this.colorCodigo,
      // IDs para referencia
      idTipoProducto: idTipoProducto ?? this.idTipoProducto,
      idColor: idColor ?? this.idColor,
      // Campos de auditoría
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }
}
