import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:inventario/features/empresa/services/base_service.dart';
import '../models/color_model.dart';

class ColorService extends BaseService {

  ColorService() : super('colores');

  Future<List<ColorProducto>> getColores() async {
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final colores = <ColorProducto>[];
      (snapshot.value as Map).forEach((key, value) {
        final color = ColorProducto.fromJson(
          Map<String, dynamic>.from(value),
          key,
        );
        if (!color.deleted) {
          colores.add(color);
        }
      });
      return colores;
    }
    return [];
  }

  Future<ColorProducto?> getColorById(String id) async {
    final snapshot = await dbRef.child(id).get();
    if (snapshot.exists) {
      return ColorProducto.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        snapshot.key!,
      );
    }
    return null;
  }

  Future<String> createColor(ColorProducto color) async {
    final newRef = dbRef.push();
    await newRef.set(color.toJson());
    return newRef.key!;
  }

  Future<bool> updateColor(ColorProducto color) async {
    try {
      await dbRef.child(color.id).update(color.toJson());
      return true;
    } catch (e) {
      print("Error al actualizar color: $e");
      return false;
    }
  }

  Future<bool> deleteColor(String id) async {
    try {
      await dbRef.child(id).update({
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
    return dbRef.onValue.map((event) {
      final colores = <ColorProducto>[];
      if (event.snapshot.exists) {
        (event.snapshot.value as Map).forEach((key, value) {
          final color = ColorProducto.fromJson(
            Map<String, dynamic>.from(value),
            key,
          );
          if (!color.deleted) {
            colores.add(color);
          }
        });
      }
      return colores;
    });
  }
}
