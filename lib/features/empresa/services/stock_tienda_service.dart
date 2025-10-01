// lib/features/empresa/services/stock_tienda_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:inventario/features/empresa/models/stock_lote_tienda_model.dart';
import 'package:inventario/features/empresa/services/base_service.dart';
import '../models/stock_tienda_model.dart';

class StockTiendaService extends BaseService {
  late final DatabaseReference _dbLoteRef;

  // ✅ dbRef viene de BaseService('stock_tienda')
  StockTiendaService() : super('stock_tienda') {
    // ✅ Segunda referencia con buildRef()
    _dbLoteRef = buildRef('stock_lote_tienda');
  }
  Future<String> createStockTienda(StockTienda stock) async {
    final newRef = dbRef.push(); // ✅ dbRef heredado
    await newRef.set(stock.toJson());
    return newRef.key!;
  }

  Future<List<StockTienda>> getStockByTienda(String idTienda) async {
    final snapshot = await dbRef
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
    final snapshot = await dbRef.child(id).get();
    if (snapshot.exists) {
      return StockTienda.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
    }
    return null;
  }

  Future<StockLoteTienda?> getStockLoteById(String id) async {
    final snapshot = await _dbLoteRef.child(id).get();
    if (snapshot.exists) {
      return StockLoteTienda.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        id,
      );
    }
    return null;
  }

  Future<bool> updateStockTienda(StockTienda stock) async {
    try {
      await dbRef.child(stock.id).update(stock.toJson());
      return true;
    } catch (e) {
      print("Error al actualizar stock tienda: $e");
      return false;
    }
  }

  Future<bool> updateStockLoteTienda(StockLoteTienda lote) async {
    try {
      await _dbLoteRef.child(lote.id).update(lote.toJson());
      return true;
    } catch (e) {
      print("Error al actualizar stock lote tienda: $e");
      return false;
    }
  }

  Future<bool> deleteStockTienda(String id) async {
    try {
      await dbRef.child(id).update({
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
    return dbRef.orderByChild('idTienda').equalTo(idTienda).onValue.map((
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
