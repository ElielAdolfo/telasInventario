import 'package:firebase_database/firebase_database.dart';
import 'package:inventario/config/firebase_config.dart';
import 'package:inventario/features/empresa/services/base_service.dart';
import '../models/tienda_model.dart';

class TiendaService extends BaseService {
  TiendaService() : super('stores');

  Future<String> createTienda(Tienda tienda) async {
    final newRef = dbRef.push();
    await newRef.set(tienda.toJson());
    return newRef.key!;
  }

  Future<List<Tienda>> getTiendasByEmpresa(String empresaId) async {
    final snapshot = await dbRef
        .orderByChild('empresaId')
        .equalTo(empresaId)
        .once();

    if (snapshot.snapshot.exists) {
      final tiendas = <Tienda>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final tienda = Tienda.fromJson(Map<String, dynamic>.from(value), key);
        if (!tienda.deleted) {
          tiendas.add(tienda);
        }
      });
      return tiendas;
    }
    return [];
  }

  Future<Tienda?> getTiendaById(String id) async {
    final snapshot = await dbRef.child(id).get();
    if (snapshot.exists) {
      final tienda = Tienda.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
      return tienda.deleted ? null : tienda;
    }
    return null;
  }

  Future<void> updateTienda(Tienda tienda) async {
    await dbRef.child(tienda.id).update(tienda.toJson());
  }

  Future<void> deleteTienda(String id) async {
    await dbRef.child(id).update({
      'deleted': true,
      'deletedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> restoreTienda(String id) async {
    await dbRef.child(id).update({
      'deleted': false,
      'deletedAt': null,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Tienda>> tiendasStreamByEmpresa(String empresaId) {
    return dbRef.orderByChild('empresaId').equalTo(empresaId).onValue.map((
      event,
    ) {
      final tiendas = <Tienda>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          final tienda = Tienda.fromJson(Map<String, dynamic>.from(value), key);
          if (!tienda.deleted) {
            tiendas.add(tienda);
          }
        });
      }
      return tiendas;
    });
  }
}
