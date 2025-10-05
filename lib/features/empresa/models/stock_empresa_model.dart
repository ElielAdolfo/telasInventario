// lib/features/stock/models/stock_empresa_model.dart

class StockEmpresa {
  final String id;
  final String idEmpresa;
  final String idTipoProducto;
  final String? idColor; // ID del color (opcional)
  final int cantidad; // Cantidad por unidad (ej: 20 metros por rollo)
  final int cantidadReservado; // Cantidad reservada en solicitudes pendientes
  final int cantidadAprobado; // Cantidad aprobada para envío
  final int unidades; // Número de unidades (ej: 50 rollos)
  final double precioCompra;
  final double precioVentaMenor;
  final double precioVentaMayor;
  final double? precioPaquete; // Nuevo campo: precio por paquete
  final DateTime fechaIngreso;
  final String? lote;
  final DateTime? fechaVencimiento;
  final String? observaciones;
  final bool deleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Campos adicionales copiados de TipoProducto
  final String categoria;
  final String nombre;
  final String unidadMedida;
  final String? unidadMedidaSecundaria;
  final bool permiteVentaParcial;
  final bool requiereColor;
  final List<int> cantidadesPosibles;
  final int cantidadPrioritaria;
  
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;
  int get cantidadDisponible => cantidad - cantidadReservado - cantidadAprobado;
  int get total => cantidad * unidades;

  StockEmpresa({
    required this.id,
    required this.idEmpresa,
    required this.idTipoProducto,
    this.idColor,
    required this.cantidad,
    this.cantidadReservado = 0,
    this.cantidadAprobado = 0,
    required this.unidades,
    required this.precioCompra,
    required this.precioVentaMenor,
    required this.precioVentaMayor,
    this.precioPaquete,
    required this.fechaIngreso,
    this.lote,
    this.fechaVencimiento,
    this.observaciones,
    this.deleted = false,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    // Campos adicionales copiados de TipoProducto
    required this.categoria,
    required this.nombre,
    required this.unidadMedida,
    required this.unidadMedidaSecundaria,
    required this.permiteVentaParcial,
    required this.requiereColor,
    required this.cantidadesPosibles,
    required this.cantidadPrioritaria,
    // Campos de auditoría
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
  });

  // Factory constructor para crear desde JSON
  factory StockEmpresa.fromJson(Map<String, dynamic> json, [String? id]) {
    // Convertir la lista de cantidades desde JSON
    List<int> cantidadesPosibles = [];
    if (json['cantidadesPosibles'] != null) {
      for (var item in json['cantidadesPosibles']) {
        cantidadesPosibles.add(int.parse(item.toString()));
      }
    }

    return StockEmpresa(
      id: id ?? json['id'] ?? '',
      idEmpresa: json['idEmpresa'] ?? '',
      idTipoProducto: json['idTipoProducto'] ?? '',
      idColor: json['idColor'],
      cantidad: json['cantidad'] ?? 0,
      cantidadReservado: json['cantidadReservado'] ?? 0,
      cantidadAprobado: json['cantidadAprobado'] ?? 0,
      unidades: json['unidades'] ?? 0,
      precioCompra: (json['precioCompra'] ?? 0).toDouble(),
      precioVentaMenor: (json['precioVentaMenor'] ?? 0).toDouble(),
      precioVentaMayor: (json['precioVentaMayor'] ?? 0).toDouble(),
      precioPaquete: json['precioPaquete']?.toDouble(),
      fechaIngreso: json['fechaIngreso'] != null
          ? DateTime.parse(json['fechaIngreso'])
          : DateTime.now(),
      lote: json['lote'],
      fechaVencimiento: json['fechaVencimiento'] != null
          ? DateTime.parse(json['fechaVencimiento'])
          : null,
      observaciones: json['observaciones'],
      deleted: json['deleted'] ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      // Campos adicionales copiados de TipoProducto
      categoria: json['categoria'] ?? '',
      nombre: json['nombre'] ?? '',
      unidadMedida: json['unidadMedida'] ?? '',
      unidadMedidaSecundaria: json['unidadMedidaSecundaria'],
      permiteVentaParcial: json['permiteVentaParcial'] ?? false,
      requiereColor: json['requiereColor'] ?? false,
      cantidadesPosibles: cantidadesPosibles,
      cantidadPrioritaria: json['cantidadPrioritaria'] ?? 0,
      // Campos de auditoría
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      deletedBy: json['deletedBy'],
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idEmpresa': idEmpresa,
      'idTipoProducto': idTipoProducto,
      'idColor': idColor,
      'cantidad': cantidad,
      'cantidadReservado': cantidadReservado,
      'cantidadAprobado': cantidadAprobado,
      'unidades': unidades,
      'precioCompra': precioCompra,
      'precioVentaMenor': precioVentaMenor,
      'precioVentaMayor': precioVentaMayor,
      'precioPaquete': precioPaquete,
      'fechaIngreso': fechaIngreso.toIso8601String(),
      'lote': lote,
      'fechaVencimiento': fechaVencimiento?.toIso8601String(),
      'observaciones': observaciones,
      'deleted': deleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // Campos adicionales copiados de TipoProducto
      'categoria': categoria,
      'nombre': nombre,
      'unidadMedida': unidadMedida,
      'unidadMedidaSecundaria': unidadMedidaSecundaria,
      'permiteVentaParcial': permiteVentaParcial,
      'requiereColor': requiereColor,
      'cantidadesPosibles': cantidadesPosibles
          .map((e) => e.toString())
          .toList(),
      'cantidadPrioritaria': cantidadPrioritaria,
      // Campos de auditoría
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'deletedBy': deletedBy,
    };
  }

  // Método para crear una copia con algunos campos modificados
  StockEmpresa copyWith({
    String? id,
    String? idEmpresa,
    String? idTipoProducto,
    String? idColor,
    int? cantidad,
    int? cantidadReservado,
    int? cantidadAprobado,
    int? unidades,
    double? precioCompra,
    double? precioVentaMenor,
    double? precioVentaMayor,
    double? precioPaquete,
    DateTime? fechaIngreso,
    String? lote,
    DateTime? fechaVencimiento,
    String? observaciones,
    bool? deleted,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoria,
    String? nombre,
    String? unidadMedida,
    String? unidadMedidaSecundaria,
    bool? permiteVentaParcial,
    bool? requiereColor,
    List<int>? cantidadesPosibles,
    int? cantidadPrioritaria,
    String? createdBy,
    String? updatedBy,
    String? deletedBy,
  }) {
    return StockEmpresa(
      id: id ?? this.id,
      idEmpresa: idEmpresa ?? this.idEmpresa,
      idTipoProducto: idTipoProducto ?? this.idTipoProducto,
      idColor: idColor ?? this.idColor,
      cantidad: cantidad ?? this.cantidad,
      cantidadReservado: cantidadReservado ?? this.cantidadReservado,
      cantidadAprobado: cantidadAprobado ?? this.cantidadAprobado,
      unidades: unidades ?? this.unidades,
      precioCompra: precioCompra ?? this.precioCompra,
      precioVentaMenor: precioVentaMenor ?? this.precioVentaMenor,
      precioVentaMayor: precioVentaMayor ?? this.precioVentaMayor,
      precioPaquete: precioPaquete ?? this.precioPaquete,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      lote: lote ?? this.lote,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      observaciones: observaciones ?? this.observaciones,
      deleted: deleted ?? this.deleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoria: categoria ?? this.categoria,
      nombre: nombre ?? this.nombre,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      unidadMedidaSecundaria: unidadMedidaSecundaria ?? this.unidadMedidaSecundaria,
      permiteVentaParcial: permiteVentaParcial ?? this.permiteVentaParcial,
      requiereColor: requiereColor ?? this.requiereColor,
      cantidadesPosibles: cantidadesPosibles ?? this.cantidadesPosibles,
      cantidadPrioritaria: cantidadPrioritaria ?? this.cantidadPrioritaria,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }

  // Factory constructor para crear una instancia vacía
  static StockEmpresa empty() {
    return StockEmpresa(
      id: '',
      idEmpresa: '',
      idTipoProducto: '',
      cantidad: 0,
      cantidadReservado: 0,
      cantidadAprobado: 0,
      unidades: 0,
      precioCompra: 0,
      precioVentaMenor: 0,
      precioVentaMayor: 0,
      precioPaquete: null,
      fechaIngreso: DateTime.now(),
      deleted: false,
      deletedAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      categoria: '',
      nombre: '',
      unidadMedida: '',
      unidadMedidaSecundaria: null,
      permiteVentaParcial: false,
      requiereColor: false,
      cantidadesPosibles: [],
      cantidadPrioritaria: 0,
      createdBy: null,
      updatedBy: null,
      deletedBy: null,
    );
  }

  @override
  String toString() {
    return 'StockEmpresa{'
        'id: $id, '
        'idEmpresa: $idEmpresa, '
        'idTipoProducto: $idTipoProducto, '
        'idColor: $idColor, '
        'cantidad: $cantidad, '
        'cantidadReservado: $cantidadReservado, '
        'cantidadAprobado: $cantidadAprobado, '
        'unidades: $unidades, '
        'precioCompra: $precioCompra, '
        'precioVentaMenor: $precioVentaMenor, '
        'precioVentaMayor: $precioVentaMayor, '
        'precioPaquete: $precioPaquete, '
        'fechaIngreso: $fechaIngreso, '
        'lote: $lote, '
        'fechaVencimiento: $fechaVencimiento, '
        'observaciones: $observaciones, '
        'deleted: $deleted, '
        'deletedAt: $deletedAt, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'categoria: $categoria, '
        'nombre: $nombre, '
        'unidadMedida: $unidadMedida, '
        'unidadMedidaSecundaria: $unidadMedidaSecundaria, '
        'permiteVentaParcial: $permiteVentaParcial, '
        'requiereColor: $requiereColor, '
        'cantidadesPosibles: $cantidadesPosibles, '
        'cantidadPrioritaria: $cantidadPrioritaria, '
        'createdBy: $createdBy, '
        'updatedBy: $updatedBy, '
        'deletedBy: $deletedBy'
        '}';
  }
}