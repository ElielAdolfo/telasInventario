// lib/features/empresa/services/carrito_persistence_service.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:inventario/features/empresa/services/base_service.dart';
import '../models/carrito_item_model.dart';

class CarritoPersistenceService extends BaseService {
  CarritoPersistenceService() : super('carrito_items');

  // Agregar un item al carrito en Firebase
  Future<void> agregarItemAlCarrito(CarritoItem item) async {
    final id = dbRef.push().key;
    if (id == null) {
      throw Exception('No se pudo generar un ID para el item del carrito');
    }

    await dbRef.child(id).set({
      'idUsuario': item.idUsuario,
      'idProducto': item.idProducto,
      'nombreProducto': item.nombreProducto,
      'idColor': item.idColor,
      'nombreColor': item.nombreColor,
      'codigoColor': item.codigoColor,
      'precio': item.precio,
      'cantidad': item.cantidad,
      'subtotal': item.subtotal,
      'tipoVenta': item.tipoVenta,
      'idStockTienda': item.idStockTienda,
      'idStockLoteTienda': item.idStockLoteTienda,
      'idStockUnidadAbierta': item.idStockUnidadAbierta,
      'codigoUnico': item.codigoUnico,
      'fechaAgregado': ServerValue.timestamp,
      'estado': 'PENDIENTE', // PENDIENTE, VENDIDO, CANCELADO
    });
  }

  // Obtener items del carrito de un usuario
  Future<List<CarritoItem>> obtenerItemsCarrito(String idUsuario) async {
    final snapshot = await dbRef
        .orderByChild('idUsuario')
        .equalTo(idUsuario)
        .once();

    final items = <CarritoItem>[];

    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;

      // Filtrar solo los items con estado PENDIENTE
      data.forEach((key, value) {
        if (value['estado'] == 'PENDIENTE') {
          items.add(
            CarritoItem(
              id: key,
              idProducto: value['idProducto'] ?? '',
              nombreProducto: value['nombreProducto'] ?? '',
              idColor: value['idColor'],
              nombreColor: value['nombreColor'],
              codigoColor: value['codigoColor'],
              precio: (value['precio'] is int)
                  ? (value['precio'] as int).toDouble()
                  : value['precio']?.toDouble() ?? 0.0,
              cantidad: (value['cantidad'] is int)
                  ? (value['cantidad'] as int).toDouble()
                  : value['cantidad']?.toDouble() ?? 0.0,
              tipoVenta: value['tipoVenta'] ?? '',
              idStockTienda: value['idStockTienda'],
              idStockLoteTienda: value['idStockLoteTienda'],
              idStockUnidadAbierta: value['idStockUnidadAbierta'],
              idUsuario: value['idUsuario'] ?? '',
              codigoUnico: value['codigoUnico'],
            ),
          );
        }
      });

      // Ordenar por fechaAgregado (del más antiguo al más reciente)
      items.sort((a, b) {
        // Firebase no permite ordenar directamente por timestamp en consultas compuestas
        // así que ordenamos en memoria después de obtener los datos
        return a.id.compareTo(b.id); // Los IDs de Firebase son cronológicos
      });
    }

    return items;
  }

  // Actualizar cantidad de un item
  Future<void> actualizarCantidadItem(String id, double nuevaCantidad) async {
    final snapshot = await dbRef.child(id).once();
    if (snapshot.snapshot.value == null) {
      throw Exception('Item no encontrado');
    }

    final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
    final precio = (data['precio'] is int)
        ? (data['precio'] as int).toDouble()
        : data['precio']?.toDouble() ?? 0.0;

    await dbRef.child(id).update({
      'cantidad': nuevaCantidad,
      'subtotal': precio * nuevaCantidad,
    });
  }

  // Eliminar un item del carrito
  Future<void> eliminarItemCarrito(String id) async {
    await dbRef.child(id).update({'estado': 'CANCELADO'});
  }

  // Marcar items como vendidos
  Future<void> marcarItemsComoVendidos(List<String> itemIds) async {
    final updates = <String, dynamic>{};
    for (String id in itemIds) {
      updates['$id/estado'] = 'VENDIDO';
    }
    await dbRef.update(updates);
  }
}
