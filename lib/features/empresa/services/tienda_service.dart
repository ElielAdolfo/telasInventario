import 'package:firebase_database/firebase_database.dart';
import 'package:inventario/config/firebase_config.dart';
import '../models/tienda_model.dart';

class TiendaService {
  final DatabaseReference _dbRef = FirebaseDB.ref("stores");

  Future<String> createTienda(Tienda tienda) async {
    final newRef = _dbRef.push();
    await newRef.set(tienda.toJson());
    return newRef.key!;
  }

  Future<List<Tienda>> getTiendasByEmpresa(String empresaId) async {
    final snapshot = await _dbRef
        .orderByChild('empresaId')
        .equalTo(empresaId)
        .once();

    if (snapshot.snapshot.exists) {
      final tiendas = <Tienda>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final tienda = Tienda.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );
        if (!tienda.deleted) {
          tiendas.add(tienda);
        }
      });
      return tiendas;
    }
    return [];
  }

  Future<Tienda?> getTiendaById(String id) async {
    final snapshot = await _dbRef.child(id).get();
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
    await _dbRef.child(tienda.id).update(tienda.toJson());
  }

  Future<void> deleteTienda(String id) async {
    await _dbRef.child(id).update({
      'deleted': true,
      'deletedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> restoreTienda(String id) async {
    await _dbRef.child(id).update({
      'deleted': false,
      'deletedAt': null,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Tienda>> tiendasStreamByEmpresa(String empresaId) {
    return _dbRef
        .orderByChild('empresaId')
        .equalTo(empresaId)
        .onValue
        .map((event) {
      final tiendas = <Tienda>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          final tienda = Tienda.fromJson(
            Map<String, dynamic>.from(value),
            key,
          );
          if (!tienda.deleted) {
            tiendas.add(tienda);
          }
        });
      }
      return tiendas;
    });
  }
}