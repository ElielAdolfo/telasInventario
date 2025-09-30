// lib/features/empresa/services/stock_lote_tienda_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/stock_lote_tienda_model.dart';

class StockLoteTiendaService {
  late final DatabaseReference _dbRef;

  StockLoteTiendaService() {
    if (kIsWeb) {
      _dbRef = FirebaseDatabase(
        databaseURL: 'https://inventario-de053-default-rtdb.firebaseio.com',
      ).ref('stock_lote_tienda');
    } else {
      _dbRef = FirebaseDatabase.instance.ref('stock_lote_tienda');
    }
  }

  Future<String> createLote(StockLoteTienda lote) async {
    final newRef = _dbRef.push();
    await newRef.set(lote.toJson());
    return newRef.key!;
  }

  Future<List<StockLoteTienda>> getLotesByStockTienda(
    String idStockTienda,
  ) async {
    final snapshot = await _dbRef
        .orderByChild('idStockTienda')
        .equalTo(idStockTienda)
        .once();

    if (snapshot.snapshot.exists) {
      final lotes = <StockLoteTienda>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final lote = StockLoteTienda.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );
        if (!lote.deleted) {
          lotes.add(lote);
        }
      });
      return lotes;
    }
    return [];
  }

  Future<StockLoteTienda?> getLoteById(String id) async {
    final snapshot = await _dbRef.child(id).get();
    if (snapshot.exists) {
      return StockLoteTienda.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
    }
    return null;
  }

  Future<bool> updateLote(StockLoteTienda lote) async {
    try {
      await _dbRef.child(lote.id).update(lote.toJson());
      return true;
    } catch (e) {
      print("Error al actualizar lote: $e");
      return false;
    }
  }

  Future<bool> deleteLote(String id) async {
    try {
      await _dbRef.child(id).update({
        'deleted': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print("Error al eliminar lote: $e");
      return false;
    }
  }

  Stream<List<StockLoteTienda>> lotesByStockTiendaStream(String idStockTienda) {
    return _dbRef
        .orderByChild('idStockTienda')
        .equalTo(idStockTienda)
        .onValue
        .map((event) {
          final lotes = <StockLoteTienda>[];
          if (event.snapshot.exists) {
            (event.snapshot.value as Map).forEach((key, value) {
              final lote = StockLoteTienda.fromJson(
                Map<String, dynamic>.from(value),
                key,
              );
              if (!lote.deleted) {
                lotes.add(lote);
              }
            });
          }
          return lotes;
        });
  }
}
