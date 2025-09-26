// lib/features/stock/services/stock_empresa_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/stock_empresa_model.dart';

class StockEmpresaService {
  late final DatabaseReference _dbRef;

  StockEmpresaService() {
    if (kIsWeb) {
      _dbRef = FirebaseDatabase(
        databaseURL: 'https://inventario-de053-default-rtdb.firebaseio.com',
      ).ref('stock_empresa');
    } else {
      _dbRef = FirebaseDatabase.instance.ref('stock_empresa');
    }
  }

  Future<String> createStockEmpresa(StockEmpresa stock) async {
    final newRef = _dbRef.push();
    await newRef.set(stock.toJson());
    return newRef.key!;
  }

  Future<List<StockEmpresa>> getStockByEmpresa(String idEmpresa) async {
    final snapshot = await _dbRef
        .orderByChild('idEmpresa')
        .equalTo(idEmpresa)
        .once();

    if (snapshot.snapshot.exists) {
      final stocks = <StockEmpresa>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final stock = StockEmpresa.fromJson(
          Map<String, dynamic>.from(value),
          key, // Pasamos el ID como parámetro separado
        );
        if (!stock.deleted) {
          stocks.add(stock);
        }
      });
      return stocks;
    }
    return [];
  }

  Future<List<StockEmpresa>> getStockByEmpresaAndProducto(
    String idEmpresa,
    String idTipoProducto,
  ) async {
    final snapshot = await _dbRef
        .orderByChild('idEmpresa')
        .equalTo(idEmpresa)
        .once();

    if (snapshot.snapshot.exists) {
      final stocks = <StockEmpresa>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final stock = StockEmpresa.fromJson(
          Map<String, dynamic>.from(value),
          key, // Pasamos el ID como parámetro separado
        );
        if (!stock.deleted && stock.idTipoProducto == idTipoProducto) {
          stocks.add(stock);
        }
      });
      return stocks;
    }
    return [];
  }

  Future<StockEmpresa?> getStockById(String id) async {
    final snapshot = await _dbRef.child(id).get();
    if (snapshot.exists) {
      final stock = StockEmpresa.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!, // Pasamos el ID como parámetro separado
      );
      return stock.deleted ? null : stock;
    }
    return null;
  }

  Future<bool> updateStockEmpresa(StockEmpresa stock) async {
    try {
      await _dbRef.child(stock.id).update(stock.toJson());
      return true; // Se actualizó correctamente
    } catch (e) {
      print("Error al actualizar stock: $e");
      return false; // Hubo un error
    }
  }

  Future<void> deleteStockEmpresa(String id) async {
    await _dbRef.child(id).update({
      'deleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<StockEmpresa>> stockByEmpresaStream(String idEmpresa) {
    return _dbRef.orderByChild('idEmpresa').equalTo(idEmpresa).onValue.map((
      event,
    ) {
      final stocks = <StockEmpresa>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          final stock = StockEmpresa.fromJson(
            Map<String, dynamic>.from(value),
            key, // Pasamos el ID como parámetro separado
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
