// lib/features/producto/models/producto_model.dart
class Producto {
  final String id;
  final String idTipoProducto;
  final String idColor;
  final String nombre;
  final String descripcion;
  final double precioCompleto;
  final double precioUnitario;
  final int cantidadPorEmpaque;
  final String idUsuarioCreador;
  final String? idUsuarioModificador;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Producto({
    required this.id,
    required this.idTipoProducto,
    required this.idColor,
    required this.nombre,
    required this.descripcion,
    required this.precioCompleto,
    required this.precioUnitario,
    required this.cantidadPorEmpaque,
    required this.idUsuarioCreador,
    this.idUsuarioModificador,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Constructor desde JSON (para convertir datos de Firebase)
  factory Producto.fromJson(Map<String, dynamic> json, String id) {
    return Producto(
      id: id,
      idTipoProducto: json['idTipoProducto'] ?? '',
      idColor: json['idColor'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precioCompleto: (json['precioCompleto'] ?? 0).toDouble(),
      precioUnitario: (json['precioUnitario'] ?? 0).toDouble(),
      cantidadPorEmpaque: json['cantidadPorEmpaque'] ?? 0,
      idUsuarioCreador: json['idUsuarioCreador'] ?? '',
      idUsuarioModificador: json['idUsuarioModificador'],
      deleted: json['deleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Convertir a JSON (para guardar en Firebase)
  Map<String, dynamic> toJson() {
    return {
      'idTipoProducto': idTipoProducto,
      'idColor': idColor,
      'nombre': nombre,
      'descripcion': descripcion,
      'precioCompleto': precioCompleto,
      'precioUnitario': precioUnitario,
      'cantidadPorEmpaque': cantidadPorEmpaque,
      'idUsuarioCreador': idUsuarioCreador,
      'idUsuarioModificador': idUsuarioModificador,
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Método para crear una copia con algunos campos modificados
  Producto copyWith({
    String? nombre,
    String? descripcion,
    double? precioCompleto,
    double? precioUnitario,
    int? cantidadPorEmpaque,
    String? idUsuarioModificador,
    bool? deleted,
  }) {
    return Producto(
      id: id,
      idTipoProducto: idTipoProducto,
      idColor: idColor,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precioCompleto: precioCompleto ?? this.precioCompleto,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      cantidadPorEmpaque: cantidadPorEmpaque ?? this.cantidadPorEmpaque,
      idUsuarioCreador: idUsuarioCreador,
      idUsuarioModificador: idUsuarioModificador ?? this.idUsuarioModificador,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Método para calcular el precio total basado en la cantidad
  double calcularPrecioTotal(int cantidad) {
    return precioUnitario * cantidad;
  }

  // Método para verificar si el producto está en un rango de precios
  bool estaEnRangoDePrecio(double min, double max) {
    return precioUnitario >= min && precioUnitario <= max;
  }

  @override
  String toString() {
    return 'Producto(id: $id, nombre: $nombre, precioUnitario: $precioUnitario)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Producto &&
        other.id == id &&
        other.idTipoProducto == idTipoProducto &&
        other.idColor == idColor &&
        other.nombre == nombre &&
        other.precioUnitario == precioUnitario &&
        other.cantidadPorEmpaque == cantidadPorEmpaque;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        idTipoProducto.hashCode ^
        idColor.hashCode ^
        nombre.hashCode ^
        precioUnitario.hashCode ^
        cantidadPorEmpaque.hashCode;
  }
}
