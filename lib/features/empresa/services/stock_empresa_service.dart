// lib/features/stock/services/stock_empresa_service.dart

import 'package:inventario/features/empresa/services/base_service.dart';
import '../models/stock_empresa_model.dart';

class StockEmpresaService extends BaseService {
  StockEmpresaService() : super('stock_empresa');

  Future<String> createStockEmpresa(StockEmpresa stock, String userId) async {
    final newRef = dbRef.push();
    final newVar = stock.copyWith(
      deleted: false,
      createdBy: userId,
      createdAt: DateTime.now(),
    );
    await newRef.set(newVar.toJson());
    return newRef.key!;
  }

  Future<List<StockEmpresa>> getStockByEmpresa(String idEmpresa) async {
    final snapshot = await dbRef
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
    final snapshot = await dbRef
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
    final snapshot = await dbRef.child(id).get();
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
      await dbRef.child(stock.id).update(stock.toJson());
      return true; // Se actualizó correctamente
    } catch (e) {
      print("Error al actualizar stock: $e");
      return false; // Hubo un error
    }
  }

  Future<void> deleteStockEmpresa(String id) async {
    await dbRef.child(id).update({
      'deleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<StockEmpresa>> stockByEmpresaStream(String idEmpresa) {
    return dbRef.orderByChild('idEmpresa').equalTo(idEmpresa).onValue.map((
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
