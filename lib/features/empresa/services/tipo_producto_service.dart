// lib/features/producto/services/tipo_producto_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:inventario/features/empresa/services/base_service.dart';
import '../models/tipo_producto_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class TipoProductoService extends BaseService {

  TipoProductoService() : super('tipos_producto');

  Future<String> createTipoProducto(TipoProducto tipoProducto) async {
    final newRef = dbRef.push();
    await newRef.set(tipoProducto.toJson());
    return newRef.key!;
  }

  Future<List<TipoProducto>> getTiposProducto() async {
    final snapshot = await dbRef.orderByChild('deleted').equalTo(false).get();
    if (snapshot.exists) {
      final tipos = <TipoProducto>[];
      for (var child in snapshot.children) {
        tipos.add(
          TipoProducto.fromJson(
            Map<String, dynamic>.from(child.value as Map),
            child.key!,
          ),
        );
      }
      return tipos;
    }
    return [];
  }

  Future<List<TipoProducto>> getTiposProductoByEmpresa(String idEmpresa) async {
    final snapshot = await dbRef
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
    final snapshot = await dbRef
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
    final snapshot = await dbRef.child(id).get();
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
    await dbRef.child(tipoProducto.id).update(tipoProducto.toJson());
  }

  Future<void> deleteTipoProducto(String id) async {
    await dbRef.child(id).update({
      'deleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<TipoProducto>> tiposProductoStream() {
    return dbRef.orderByChild('deleted').equalTo(false).onValue.map((event) {
      final tipos = <TipoProducto>[];
      if (event.snapshot.exists) {
        for (var child in event.snapshot.children) {
          tipos.add(
            TipoProducto.fromJson(
              Map<String, dynamic>.from(child.value as Map),
              child.key!,
            ),
          );
        }
      }
      return tipos;
    });
  }

  Stream<List<TipoProducto>> tiposProductoByEmpresaStream(String idEmpresa) {
    return dbRef.orderByChild('idEmpresa').equalTo(idEmpresa).onValue.map((
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
    return dbRef.orderByChild('idEmpresa').equalTo(idEmpresa).onValue.map((
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
