// lib/features/empresa/services/stock_unidad_abierta_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:inventario/features/empresa/services/base_service.dart';
import 'package:inventario/features/empresa/services/stock_lote_tienda_service.dart';
import '../models/stock_unidad_abierta_model.dart';

class StockUnidadAbiertaService extends BaseService {

  StockUnidadAbiertaService() : super('stock_unidad_abierta');

  Future<String> createUnidadAbierta(StockUnidadAbierta unidad) async {
    final newRef = dbRef.push();
    await newRef.set(unidad.toJson());
    return newRef.key!;
  }

  Future<List<StockUnidadAbierta>> getUnidadesAbiertasByTienda(
    String idTienda,
  ) async {
    // Primero obtenemos los lotes de la tienda
    final stockLoteTiendaService = StockLoteTiendaService();
    //final lotes = await stockLoteTiendaService.getLotesByTienda(idTienda);

    List<String> idsLotes = []; //lotes.map((lote) => lote.id).toList();

    // Ahora obtenemos las unidades abiertas correspondientes a esos lotes
    if (idsLotes.isEmpty) {
      return [];
    }

    final unidades = <StockUnidadAbierta>[];
    for (String idLote in idsLotes) {
      final snapshot = await dbRef
          .orderByChild('idStockLoteTienda')
          .equalTo(idLote)
          .once();

      if (snapshot.snapshot.exists) {
        (snapshot.snapshot.value as Map).forEach((key, value) {
          final unidad = StockUnidadAbierta.fromJson(
            Map<String, dynamic>.from(value),
            key,
          );
          if (!unidad.deleted && !unidad.estaCerrada) {
            unidades.add(unidad);
          }
        });
      }
    }

    return unidades;
  }

  Future<StockUnidadAbierta?> getUnidadAbiertaById(String id) async {
    final snapshot = await dbRef.child(id).get();
    if (snapshot.exists) {
      return StockUnidadAbierta.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
    }
    return null;
  }

  Future<bool> updateUnidadAbierta(StockUnidadAbierta unidad) async {
    try {
      await dbRef.child(unidad.id).update(unidad.toJson());
      return true;
    } catch (e) {
      print("Error al actualizar unidad abierta: $e");
      return false;
    }
  }

  Future<bool> deleteUnidadAbierta(String id) async {
    try {
      await dbRef.child(id).update({
        'deleted': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print("Error al eliminar unidad abierta: $e");
      return false;
    }
  }

  Stream<List<StockUnidadAbierta>> unidadesAbiertasByTiendaStream(
    String idTienda,
  ) {
    return dbRef.onValue.map((event) {
      final unidades = <StockUnidadAbierta>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          final unidad = StockUnidadAbierta.fromJson(
            Map<String, dynamic>.from(value),
            key,
          );
          // Filtrar solo las no eliminadas y no cerradas
          if (!unidad.deleted && !unidad.estaCerrada) {
            unidades.add(unidad);
          }
        });
      }
      return unidades;
    });
  }
}
