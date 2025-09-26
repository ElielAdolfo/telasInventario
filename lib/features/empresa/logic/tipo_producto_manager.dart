// lib/features/producto/logic/tipo_producto_manager.dart
import 'package:flutter/material.dart';
import '../models/tipo_producto_model.dart';
import '../services/tipo_producto_service.dart';

class TipoProductoManager with ChangeNotifier {
  final TipoProductoService _service = TipoProductoService();
  List<TipoProducto> _tiposProducto = [];
  bool _isLoading = false;
  String? _error;

  List<TipoProducto> get tiposProducto => _tiposProducto;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTiposProducto() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tiposProducto = await _service.getTiposProducto();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTiposProductoByEmpresa(String idEmpresa) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tiposProducto = await _service.getTiposProductoByEmpresa(idEmpresa);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTiposProductoByCategoria(
    String idEmpresa,
    String categoria,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tiposProducto = await _service.getTiposProductoByCategoria(
        idEmpresa,
        categoria,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTipoProducto(TipoProducto tipoProducto) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createTipoProducto(tipoProducto);
      await loadTiposProductoByEmpresa(tipoProducto.idEmpresa);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTipoProducto(TipoProducto tipoProducto) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateTipoProducto(tipoProducto);
      await loadTiposProductoByEmpresa(tipoProducto.idEmpresa);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTipoProducto(String id, String idEmpresa) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteTipoProducto(id);
      await loadTiposProductoByEmpresa(idEmpresa);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TipoProducto?> getTipoProductoById(String id) async {
    return await _service.getTipoProductoById(id);
  }

  Stream<List<TipoProducto>> get tiposProductoStream =>
      _service.tiposProductoStream();

  Stream<List<TipoProducto>> tiposProductoByEmpresaStream(String idEmpresa) {
    return _service.tiposProductoByEmpresaStream(idEmpresa);
  }

  Stream<List<TipoProducto>> tiposProductoByCategoriaStream(
    String idEmpresa,
    String categoria,
  ) {
    return _service.tiposProductoByCategoriaStream(idEmpresa, categoria);
  }

  // Obtener categorías únicas por empresa
  List<String> getCategoriasUnicas() {
    final categorias = <String>{};
    for (var tipo in _tiposProducto) {
      if (tipo.categoria.isNotEmpty) {
        categorias.add(tipo.categoria);
      }
    }
    return categorias.toList()..sort();
  }
}
