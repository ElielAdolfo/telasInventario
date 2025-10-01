// lib/features/producto/services/producto_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/producto_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProductoService {
  // Referencia a la colección 'productos' en Firebase
  late final DatabaseReference _dbRef;

  ProductoService() {
    if (kIsWeb) {
      _dbRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://inventario-de053-default-rtdb.firebaseio.com',
      ).ref('productos');
    } else {
      _dbRef = FirebaseDatabase.instance.ref('productos');
    }
  }

  // Crear un nuevo producto en Firebase
  Future<String> createProducto(Producto producto) async {
    final newRef = _dbRef.push();
    await newRef.set(producto.toJson());
    return newRef.key!; // Devuelve el ID generado por Firebase
  }

  // Obtener todos los productos no eliminados
  Future<List<Producto>> getProductos() async {
    final snapshot = await _dbRef.orderByChild('deleted').equalTo(false).get();

    if (snapshot.exists) {
      final productos = <Producto>[];
      for (var child in snapshot.children) {
        productos.add(
          Producto.fromJson(
            Map<String, dynamic>.from(child.value as Map),
            child.key!,
          ),
        );
      }
      return productos;
    }
    return [];
  }

  // Obtener productos por tipo de producto
  Future<List<Producto>> getProductosByTipo(String idTipoProducto) async {
    final snapshot = await _dbRef
        .orderByChild('idTipoProducto')
        .equalTo(idTipoProducto)
        .once();

    if (snapshot.snapshot.exists) {
      final productos = <Producto>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final producto = Producto.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );
        if (!producto.deleted) {
          productos.add(producto);
        }
      });
      return productos;
    }
    return [];
  }

  // Obtener productos por color
  Future<List<Producto>> getProductosByColor(String idColor) async {
    final snapshot = await _dbRef
        .orderByChild('idColor')
        .equalTo(idColor)
        .once();

    if (snapshot.snapshot.exists) {
      final productos = <Producto>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final producto = Producto.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );
        if (!producto.deleted) {
          productos.add(producto);
        }
      });
      return productos;
    }
    return [];
  }

  // Obtener productos por tipo y color
  Future<List<Producto>> getProductosByTipoYColor(
    String idTipoProducto,
    String idColor,
  ) async {
    final snapshot = await _dbRef
        .orderByChild('idTipoProducto')
        .equalTo(idTipoProducto)
        .once();

    if (snapshot.snapshot.exists) {
      final productos = <Producto>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final producto = Producto.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );
        if (!producto.deleted && producto.idColor == idColor) {
          productos.add(producto);
        }
      });
      return productos;
    }
    return [];
  }

  // Obtener un producto por su ID
  Future<Producto?> getProductoById(String id) async {
    final snapshot = await _dbRef.child(id).get();

    if (snapshot.exists) {
      final producto = Producto.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
      return producto.deleted ? null : producto;
    }
    return null;
  }

  // Actualizar un producto existente
  Future<void> updateProducto(Producto producto) async {
    await _dbRef.child(producto.id).update(producto.toJson());
  }

  // Eliminar un producto (eliminación lógica)
  Future<void> deleteProducto(String id) async {
    await _dbRef.child(id).update({
      'deleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Stream para escuchar cambios en tiempo real en todos los productos
  Stream<List<Producto>> productosStream() {
    return _dbRef.orderByChild('deleted').equalTo(false).onValue.map((event) {
      final productos = <Producto>[];
      if (event.snapshot.exists) {
        for (var child in event.snapshot.children) {
          productos.add(
            Producto.fromJson(
              Map<String, dynamic>.from(child.value as Map),
              child.key!,
            ),
          );
        }
      }
      return productos;
    });
  }

  // Stream para escuchar cambios en productos de un tipo específico
  Stream<List<Producto>> productosByTipoStream(String idTipoProducto) {
    return _dbRef
        .orderByChild('idTipoProducto')
        .equalTo(idTipoProducto)
        .onValue
        .map((event) {
          final productos = <Producto>[];
          if (event.snapshot.exists) {
            (event.snapshot.value as Map).forEach((key, value) {
              final producto = Producto.fromJson(
                Map<String, dynamic>.from(value),
                key,
              );
              if (!producto.deleted) {
                productos.add(producto);
              }
            });
          }
          return productos;
        });
  }

  // Stream para escuchar cambios en productos de un color específico
  Stream<List<Producto>> productosByColorStream(String idColor) {
    return _dbRef.orderByChild('idColor').equalTo(idColor).onValue.map((event) {
      final productos = <Producto>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          final producto = Producto.fromJson(
            Map<String, dynamic>.from(value),
            key,
          );
          if (!producto.deleted) {
            productos.add(producto);
          }
        });
      }
      return productos;
    });
  }

  // Verificar si un producto existe por nombre en un tipo específico
  Future<bool> existsProductoByNombre(
    String nombre,
    String idTipoProducto,
  ) async {
    final snapshot = await _dbRef.orderByChild('nombre').equalTo(nombre).once();

    if (snapshot.snapshot.exists) {
      for (var child in snapshot.snapshot.children) {
        final producto = Producto.fromJson(
          Map<String, dynamic>.from(child.value as Map),
          child.key!,
        );
        if (!producto.deleted && producto.idTipoProducto == idTipoProducto) {
          return true;
        }
      }
    }
    return false;
  }

  // Buscar productos por nombre o descripción
  Future<List<Producto>> searchProductos(
    String query, {
    String? idTipoProducto,
  }) async {
    final snapshot = await _dbRef.once();
    final resultados = <Producto>[];
    final queryLower = query.toLowerCase();

    if (snapshot.snapshot.exists) {
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final producto = Producto.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );

        // Filtrar por tipo si se especifica
        final coincideTipo =
            idTipoProducto == null || producto.idTipoProducto == idTipoProducto;

        if (!producto.deleted &&
            coincideTipo &&
            (producto.nombre.toLowerCase().contains(queryLower) ||
                producto.descripcion.toLowerCase().contains(queryLower))) {
          resultados.add(producto);
        }
      });
    }

    return resultados;
  }

  // Obtener productos en un rango de precios
  Future<List<Producto>> getProductosByRangoPrecio(
    double min,
    double max, {
    String? idTipoProducto,
  }) async {
    final snapshot = await _dbRef.once();
    final resultados = <Producto>[];

    if (snapshot.snapshot.exists) {
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final producto = Producto.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );

        // Filtrar por tipo si se especifica
        final coincideTipo =
            idTipoProducto == null || producto.idTipoProducto == idTipoProducto;

        if (!producto.deleted &&
            coincideTipo &&
            producto.precioUnitario >= min &&
            producto.precioUnitario <= max) {
          resultados.add(producto);
        }
      });
    }

    return resultados;
  }

  // Obtener productos por una lista de IDs
  Future<List<Producto>> getProductosByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final snapshot = await _dbRef.once();
    final resultados = <Producto>[];
    final idsSet = ids.toSet(); // Para búsqueda más eficiente

    if (snapshot.snapshot.exists) {
      (snapshot.snapshot.value as Map).forEach((key, value) {
        if (idsSet.contains(key)) {
          final producto = Producto.fromJson(
            Map<String, dynamic>.from(value),
            key,
          );
          if (!producto.deleted) {
            resultados.add(producto);
          }
        }
      });
    }

    return resultados;
  }

  // Restaurar un producto eliminado
  Future<void> restoreProducto(String id) async {
    await _dbRef.child(id).update({
      'deleted': false,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Eliminar permanentemente un producto (cuidado: operación destructiva)
  Future<void> permanentDeleteProducto(String id) async {
    await _dbRef.child(id).remove();
  }

  // Obtener todos los productos incluyendo los eliminados (para administración)
  Future<List<Producto>> getAllProductos() async {
    final snapshot = await _dbRef.get();

    if (snapshot.exists) {
      final productos = <Producto>[];
      for (var child in snapshot.children) {
        productos.add(
          Producto.fromJson(
            Map<String, dynamic>.from(child.value as Map),
            child.key!,
          ),
        );
      }
      return productos;
    }
    return [];
  }

  // Actualizar precios de múltiples productos
  Future<void> updatePreciosProductos(
    Map<String, double> preciosActualizados,
  ) async {
    for (var entry in preciosActualizados.entries) {
      await _dbRef.child(entry.key).update({
        'precioUnitario': entry.value,
        'precioCompleto':
            entry.value *
            1, // Esto debería calcularse basado en cantidadPorEmpaque
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
  }
}
