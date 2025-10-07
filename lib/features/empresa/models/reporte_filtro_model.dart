// lib/features/empresa/models/reporte_filtro_model.dart

class ReporteFiltroModel {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String? idUsuario;
  final String? idTienda;
  final String? idEmpresa;
  final String
  tipoReporte; // 'ventas_dia', 'ventas_rango', 'stock_tienda', 'stock_empresa'
  final String? idProducto;
  final String? idColor;
  final String? tipoVenta; // 'UNIDAD_COMPLETA', 'UNIDAD_ABIERTA'

  ReporteFiltroModel({
    this.fechaInicio,
    this.fechaFin,
    this.idUsuario,
    this.idTienda,
    this.idEmpresa,
    required this.tipoReporte,
    this.idProducto,
    this.idColor,
    this.tipoVenta,
  });

  // Método para crear una copia del filtro con algunos campos actualizados
  ReporteFiltroModel copyWith({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? idUsuario,
    String? idTienda,
    String? idEmpresa,
    String? tipoReporte,
    String? idProducto,
    String? idColor,
    String? tipoVenta,
  }) {
    return ReporteFiltroModel(
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      idUsuario: idUsuario ?? this.idUsuario,
      idTienda: idTienda ?? this.idTienda,
      idEmpresa: idEmpresa ?? this.idEmpresa,
      tipoReporte: tipoReporte ?? this.tipoReporte,
      idProducto: idProducto ?? this.idProducto,
      idColor: idColor ?? this.idColor,
      tipoVenta: tipoVenta ?? this.tipoVenta,
    );
  }

  // Método para convertir el filtro a un mapa (útil para compartir o guardar)
  Map<String, dynamic> toMap() {
    return {
      'fechaInicio': fechaInicio?.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'idUsuario': idUsuario,
      'idTienda': idTienda,
      'idEmpresa': idEmpresa,
      'tipoReporte': tipoReporte,
      'idProducto': idProducto,
      'idColor': idColor,
      'tipoVenta': tipoVenta,
    };
  }

  // Método para crear un filtro desde un mapa
  factory ReporteFiltroModel.fromMap(Map<String, dynamic> map) {
    return ReporteFiltroModel(
      fechaInicio: map['fechaInicio'] != null
          ? DateTime.parse(map['fechaInicio'])
          : null,
      fechaFin: map['fechaFin'] != null
          ? DateTime.parse(map['fechaFin'])
          : null,
      idUsuario: map['idUsuario'],
      idTienda: map['idTienda'],
      idEmpresa: map['idEmpresa'],
      tipoReporte: map['tipoReporte'],
      idProducto: map['idProducto'],
      idColor: map['idColor'],
      tipoVenta: map['tipoVenta'],
    );
  }

  @override
  String toString() {
    return 'ReporteFiltroModel(fechaInicio: $fechaInicio, fechaFin: $fechaFin, idUsuario: $idUsuario, idTienda: $idTienda, idEmpresa: $idEmpresa, tipoReporte: $tipoReporte, idProducto: $idProducto, idColor: $idColor, tipoVenta: $tipoVenta)';
  }
}
