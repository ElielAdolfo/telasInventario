// lib/features/empresa/services/stock_tienda_service.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/stock_tienda_model.dart';

class StockTiendaService {
  late final DatabaseReference _dbRef;

  StockTiendaService() {
    if (kIsWeb) {
      _dbRef = FirebaseDatabase(
        databaseURL: 'https://inventario-de053-default-rtdb.firebaseio.com',
      ).ref('stock_tienda');
    } else {
      _dbRef = FirebaseDatabase.instance.ref('stock_tienda');
    }
  }

  Future<String> createStockTienda(StockTienda stock) async {
    final newRef = _dbRef.push();
    await newRef.set(stock.toJson());
    return newRef.key!;
  }

  Future<List<StockTienda>> getStockByTienda(String idTienda) async {
    final snapshot = await _dbRef
        .orderByChild('idTienda')
        .equalTo(idTienda)
        .once();

    if (snapshot.snapshot.exists) {
      final stocks = <StockTienda>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final stock = StockTienda.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );
        if (!stock.deleted) {
          stocks.add(stock);
        }
      });
      return stocks;
    }
    return [];
  }

  Future<StockTienda?> getStockById(String id) async {
    final snapshot = await _dbRef.child(id).get();
    if (snapshot.exists) {
      return StockTienda.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
    }
    return null;
  }

  Future<bool> updateStockTienda(StockTienda stock) async {
    try {
      await _dbRef.child(stock.id).update(stock.toJson());
      return true;
    } catch (e) {
      print("Error al actualizar stock de tienda: $e");
      return false;
    }
  }

  Future<bool> deleteStockTienda(String id) async {
    try {
      await _dbRef.child(id).update({
        'deleted': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print("Error al eliminar stock de tienda: $e");
      return false;
    }
  }

  Stream<List<StockTienda>> stockByTiendaStream(String idTienda) {
    return _dbRef.orderByChild('idTienda').equalTo(idTienda).onValue.map((
      event,
    ) {
      final stocks = <StockTienda>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          final stock = StockTienda.fromJson(
            Map<String, dynamic>.from(value),
            key,
          );
          if (!stock.deleted) {
            stocks.add(stock);
          }
        });
      }
      return stocks;
    });
  }
}
