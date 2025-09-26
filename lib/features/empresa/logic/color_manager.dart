// lib/features/color/logic/color_manager.dart

import 'package:flutter/material.dart';
import '../models/color_model.dart';
import '../services/color_service.dart';

class ColorManager with ChangeNotifier {
  final ColorService _service = ColorService();
  List<ColorProducto> _colores = [];
  bool _isLoading = false;
  String? _error;

  List<ColorProducto> get colores => _colores;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadColores() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _colores = await _service.getColores();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addColor(ColorProducto color) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createColor(color);
      await loadColores();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateColor(ColorProducto color) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateColor(color);
      await loadColores();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteColor(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteColor(id);
      await loadColores();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<ColorProducto>> coloresStream() {
    return _service.coloresStream();
  }
}
