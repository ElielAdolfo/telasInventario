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

  /// Crea un nuevo lote en Firebase
  Future<String> createLote(StockLoteTienda lote) async {
    try {
      final newRef = _dbRef.push();
      await newRef.set(lote.toJson());
      return newRef.key!;
    } catch (e) {
      print("Error al crear lote: $e");
      rethrow;
    }
  }

  /// Obtiene todos los lotes de una tienda específica
  Future<List<StockLoteTienda>> getLotesByTienda(String idTienda) async {
    try {
      // Primero obtenemos los stocks de tienda de la tienda
      final stockTiendaRef = FirebaseDatabase.instance.ref('stock_tienda');
      final stockTiendaSnapshot = await stockTiendaRef
          .orderByChild('idTienda')
          .equalTo(idTienda)
          .once();

      if (!stockTiendaSnapshot.snapshot.exists) {
        return [];
      }

      // Extraemos los IDs de los stocks de tienda
      final stockTiendaIds = <String>[];
      (stockTiendaSnapshot.snapshot.value as Map).forEach((key, value) {
        final stock = Map<String, dynamic>.from(value);
        if (stock['deleted'] != true) {
          stockTiendaIds.add(key);
        }
      });

      if (stockTiendaIds.isEmpty) {
        return [];
      }

      // Ahora obtenemos los lotes que pertenecen a esos stocks de tienda
      final lotes = <StockLoteTienda>[];

      // Obtenemos todos los lotes
      final lotesSnapshot = await _dbRef.once();

      if (lotesSnapshot.snapshot.exists) {
        (lotesSnapshot.snapshot.value as Map).forEach((key, value) {
          final lote = StockLoteTienda.fromJson(
            Map<String, dynamic>.from(value),
            key,
          );

          // Filtramos los lotes que pertenecen a los stocks de tienda de esta tienda
          if (!lote.deleted && stockTiendaIds.contains(lote.idStockTienda)) {
            lotes.add(lote);
          }
        });
      }

      return lotes;
    } catch (e) {
      print("Error al obtener lotes por tienda: $e");
      rethrow;
    }
  }

  /// Obtiene todos los lotes de un stock de tienda específico
  Future<List<StockLoteTienda>> getLotesByStockTienda(
    String idStockTienda,
  ) async {
    try {
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
    } catch (e) {
      print("Error al obtener lotes por stock de tienda: $e");
      rethrow;
    }
  }

  /// Obtiene un lote por su ID
  Future<StockLoteTienda?> getLoteById(String id) async {
    try {
      final snapshot = await _dbRef.child(id).get();
      if (snapshot.exists) {
        return StockLoteTienda.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map),
          snapshot.key!,
        );
      }
      return null;
    } catch (e) {
      print("Error al obtener lote por ID: $e");
      rethrow;
    }
  }

  /// Actualiza un lote existente
  Future<bool> updateLote(StockLoteTienda lote) async {
    try {
      await _dbRef.child(lote.id).update(lote.toJson());
      return true;
    } catch (e) {
      print("Error al actualizar lote: $e");
      return false;
    }
  }

  /// Elimina un lote (borrado lógico)
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

  /// Stream para escuchar cambios en los lotes de una tienda
  Stream<List<StockLoteTienda>> lotesByTiendaStream(String idTienda) {
    return _dbRef.onValue.asyncMap((event) async {
      // Primero obtenemos los stocks de tienda de la tienda
      final stockTiendaRef = FirebaseDatabase.instance.ref('stock_tienda');
      final stockTiendaSnapshot = await stockTiendaRef
          .orderByChild('idTienda')
          .equalTo(idTienda)
          .once();

      if (!stockTiendaSnapshot.snapshot.exists) {
        return [];
      }

      // Extraemos los IDs de los stocks de tienda
      final stockTiendaIds = <String>[];
      (stockTiendaSnapshot.snapshot.value as Map).forEach((key, value) {
        final stock = Map<String, dynamic>.from(value);
        if (stock['deleted'] != true) {
          stockTiendaIds.add(key);
        }
      });

      if (stockTiendaIds.isEmpty) {
        return [];
      }

      // Procesamos los lotes
      final lotes = <StockLoteTienda>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          final lote = StockLoteTienda.fromJson(
            Map<String, dynamic>.from(value),
            key,
          );

          // Filtramos los lotes que pertenecen a los stocks de tienda de esta tienda
          if (!lote.deleted && stockTiendaIds.contains(lote.idStockTienda)) {
            lotes.add(lote);
          }
        });
      }

      return lotes;
    });
  }

  /// Stream para escuchar cambios en los lotes de un stock de tienda específico
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

  /// Stream para escuchar cambios en un lote específico
  Stream<StockLoteTienda?> loteStream(String id) {
    return _dbRef.child(id).onValue.map((event) {
      if (event.snapshot.exists) {
        return StockLoteTienda.fromJson(
          Map<String, dynamic>.from(event.snapshot.value as Map),
          event.snapshot.key!,
        );
      }
      return null;
    });
  }

  /// Obtiene lotes abiertos (no cerrados) con stock disponible
  Future<List<StockLoteTienda>> getLotesAbiertosDisponibles(
    String idStockTienda,
  ) async {
    try {
      final lotes = await getLotesByStockTienda(idStockTienda);
      return lotes
          .where((lote) => !lote.estaCerrada && lote.cantidadDisponible > 0)
          .toList();
    } catch (e) {
      print("Error al obtener lotes abiertos disponibles: $e");
      rethrow;
    }
  }

  /// Obtiene lotes cerrados
  Future<List<StockLoteTienda>> getLotesCerrados(String idStockTienda) async {
    try {
      final lotes = await getLotesByStockTienda(idStockTienda);
      return lotes.where((lote) => lote.estaCerrada && !lote.deleted).toList();
    } catch (e) {
      print("Error al obtener lotes cerrados: $e");
      rethrow;
    }
  }

  /// Cierra un lote (marca como cerrado)
  Future<bool> cerrarLote(String id, String cerradoPor) async {
    try {
      await _dbRef.child(id).update({
        'estaCerrada': true,
        'fechaCierre': DateTime.now().toIso8601String(),
        'cerradoPor': cerradoPor,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print("Error al cerrar lote: $e");
      return false;
    }
  }

  /// Vende una cantidad específica de un lote
  Future<bool> venderDeLote(String id, int cantidad) async {
    try {
      // Obtener el lote actual
      final lote = await getLoteById(id);
      if (lote == null) {
        return false;
      }

      // Actualizar la cantidad vendida
      await _dbRef.child(id).update({
        'cantidadVendida': lote.cantidadVendida + cantidad,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print("Error al vender de lote: $e");
      return false;
    }
  }

  /// Obtiene el total de stock disponible en lotes abiertos
  Future<int> getTotalStockDisponible(String idStockTienda) async {
    try {
      final lotes = await getLotesAbiertosDisponibles(idStockTienda);
      int total = 0;

      for (final lote in lotes) {
        total += await lote.cantidadDisponible; // ✅ Esperamos correctamente
      }

      return total;
    } catch (e) {
      print("Error al obtener total stock disponible: $e");
      return 0;
    }
  }

  /// Obtiene el total de stock vendido en lotes abiertos
  Future<int> getTotalStockVendido(String idStockTienda) async {
    try {
      final lotes = await getLotesByStockTienda(idStockTienda);
      int total = 0;

      for (final lote in lotes) {
        if (!lote.estaCerrada) {
          total += await lote.cantidadVendida; // ✅ AQUÍ el await
        }
      }

      return total;
    } catch (e) {
      print("Error al obtener total stock vendido: $e");
      return 0;
    }
  }
}
