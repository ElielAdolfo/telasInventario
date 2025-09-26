// lib/features/producto/services/tipo_producto_service.dart
import 'package:firebase_database/firebase_database.dart';
import '../models/tipo_producto_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class TipoProductoService {
  late final DatabaseReference _dbRef;

  TipoProductoService() {
    if (kIsWeb) {
      _dbRef = FirebaseDatabase(
        databaseURL: 'https://inventario-de053-default-rtdb.firebaseio.com',
      ).ref('tipos_producto');
    } else {
      _dbRef = FirebaseDatabase.instance.ref('tipos_producto');
    }
  }

  Future<String> createTipoProducto(TipoProducto tipoProducto) async {
    final newRef = _dbRef.push();
    await newRef.set(tipoProducto.toJson());
    return newRef.key!;
  }

  Future<List<TipoProducto>> getTiposProducto() async {
    final snapshot = await _dbRef.orderByChild('deleted').equalTo(false).get();
    if (snapshot.exists) {
      final tipos = <TipoProducto>[];
      snapshot.children.forEach((child) {
        tipos.add(
          TipoProducto.fromJson(
            Map<String, dynamic>.from(child.value as Map),
            child.key!,
          ),
        );
      });
      return tipos;
    }
    return [];
  }

  Future<List<TipoProducto>> getTiposProductoByEmpresa(String idEmpresa) async {
    final snapshot = await _dbRef
        .orderByChild('idEmpresa')
        .equalTo(idEmpresa)
        .once();

    if (snapshot.snapshot.exists) {
      final tipos = <TipoProducto>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final tipo = TipoProducto.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );
        if (!tipo.deleted) {
          tipos.add(tipo);
        }
      });
      return tipos;
    }
    return [];
  }

  Future<List<TipoProducto>> getTiposProductoByCategoria(
    String idEmpresa,
    String categoria,
  ) async {
    final snapshot = await _dbRef
        .orderByChild('idEmpresa')
        .equalTo(idEmpresa)
        .once();

    if (snapshot.snapshot.exists) {
      final tipos = <TipoProducto>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final tipo = TipoProducto.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );
        if (!tipo.deleted && tipo.categoria == categoria) {
          tipos.add(tipo);
        }
      });
      return tipos;
    }
    return [];
  }

  Future<TipoProducto?> getTipoProductoById(String id) async {
    final snapshot = await _dbRef.child(id).get();
    if (snapshot.exists) {
      final tipo = TipoProducto.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
      return tipo.deleted ? null : tipo;
    }
    return null;
  }

  Future<void> updateTipoProducto(TipoProducto tipoProducto) async {
    await _dbRef.child(tipoProducto.id).update(tipoProducto.toJson());
  }

  Future<void> deleteTipoProducto(String id) async {
    await _dbRef.child(id).update({
      'deleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<TipoProducto>> tiposProductoStream() {
    return _dbRef.orderByChild('deleted').equalTo(false).onValue.map((event) {
      final tipos = <TipoProducto>[];
      if (event.snapshot.exists) {
        event.snapshot.children.forEach((child) {
          tipos.add(
            TipoProducto.fromJson(
              Map<String, dynamic>.from(child.value as Map),
              child.key!,
            ),
          );
        });
      }
      return tipos;
    });
  }

  Stream<List<TipoProducto>> tiposProductoByEmpresaStream(String idEmpresa) {
    return _dbRef.orderByChild('idEmpresa').equalTo(idEmpresa).onValue.map((
      event,
    ) {
      final tipos = <TipoProducto>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          final tipo = TipoProducto.fromJson(
            Map<String, dynamic>.from(value),
            key,
          );
          if (!tipo.deleted) {
            tipos.add(tipo);
          }
        });
      }
      return tipos;
    });
  }

  Stream<List<TipoProducto>> tiposProductoByCategoriaStream(
    String idEmpresa,
    String categoria,
  ) {
    return _dbRef.orderByChild('idEmpresa').equalTo(idEmpresa).onValue.map((
      event,
    ) {
      final tipos = <TipoProducto>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          final tipo = TipoProducto.fromJson(
            Map<String, dynamic>.from(value),
            key,
          );
          if (!tipo.deleted && tipo.categoria == categoria) {
            tipos.add(tipo);
          }
        });
      }
      return tipos;
    });
  }
}
