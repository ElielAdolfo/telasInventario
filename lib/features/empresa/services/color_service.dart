// lib/features/empresa/services/color_service.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/color_model.dart';

class ColorService {
  late final DatabaseReference _dbRef;

  ColorService() {
    if (kIsWeb) {
      _dbRef = FirebaseDatabase(
        databaseURL: 'https://inventario-de053-default-rtdb.firebaseio.com',
      ).ref('colores');
    } else {
      _dbRef = FirebaseDatabase.instance.ref('colores');
    }
  }

  Future<List<ColorProducto>> getColores() async {
    final snapshot = await _dbRef.once();

    if (snapshot.snapshot.exists) {
      final colores = <ColorProducto>[];
      (snapshot.snapshot.value as Map).forEach((key, value) {
        final color = ColorProducto.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );
        // Filtrar solo los no eliminados
        if (!color.deleted) {
          colores.add(color);
        }
      });
      return colores;
    }
    return [];
  }

  Future<ColorProducto?> getColorById(String id) async {
    final snapshot = await _dbRef.child(id).get();
    if (snapshot.exists) {
      return ColorProducto.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
    }
    return null;
  }

  Future<String> createColor(ColorProducto color) async {
    final newRef = _dbRef.push();
    await newRef.set(color.toJson());
    return newRef.key!;
  }

  Future<bool> updateColor(ColorProducto color) async {
    try {
      await _dbRef.child(color.id).update(color.toJson());
      return true;
    } catch (e) {
      print("Error al actualizar color: $e");
      return false;
    }
  }

  Future<bool> deleteColor(String id) async {
    try {
      await _dbRef.child(id).update({
        'deleted': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print("Error al eliminar color: $e");
      return false;
    }
  }

  Stream<List<ColorProducto>> coloresStream() {
    return _dbRef.onValue.map((event) {
      final colores = <ColorProducto>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          final color = ColorProducto.fromJson(
            Map<String, dynamic>.from(value),
            key,
          );
          // Filtrar solo los no eliminados
          if (!color.deleted) {
            colores.add(color);
          }
        });
      }
      return colores;
    });
  }
}
