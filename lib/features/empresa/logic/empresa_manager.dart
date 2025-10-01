// lib/features/empresa/logic/empresa_manager.dart
import 'package:flutter/material.dart';
import 'package:inventario/features/empresa/models/empresa_model.dart';
import '../services/empresa_service.dart';

class EmpresaManager with ChangeNotifier {
  final EmpresaService _service = EmpresaService();
  List<Empresa> _empresas = [];
  List<Empresa> _deletedEmpresas = [];
  bool _isLoading = false;
  String? _error;

  List<Empresa> get empresas => _empresas;
  List<Empresa> get deletedEmpresas => _deletedEmpresas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar empresas activas desde Firebase
  Future<void> loadEmpresas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _empresas = await _service.getEmpresas();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar empresas eliminadas
  Future<void> loadDeletedEmpresas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _service.deletedEmpresasStream().first;
      _deletedEmpresas = snapshot;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar nueva empresa
  Future<void> addEmpresa(Empresa empresa) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createEmpresa(empresa);
      await loadEmpresas(); // Recargar lista
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar empresa existente
  Future<void> updateEmpresa(Empresa empresa) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateEmpresa(empresa);
      await loadEmpresas(); // Recargar lista
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener empresa por ID
  Future<Empresa?> getEmpresaById(String id) async {
    return await _service.getEmpresaById(id);
  }

  // Stream para actualizaciones en tiempo real
  Stream<List<Empresa>> get empresasStream => _service.empresasStream();

  // Stream para empresas eliminadas
  Stream<List<Empresa>> get deletedEmpresasStream =>
      _service.deletedEmpresasStream();

  // Modificar los métodos deleteEmpresa y restoreEmpresa para usar los nuevos métodos del servicio
  Future<void> deleteEmpresa(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteEmpresa(id);
      await loadEmpresas(); // Recargar lista activas
      await loadDeletedEmpresas(); // Recargar lista eliminadas
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restoreEmpresa(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.restoreEmpresa(id);
      await loadEmpresas(); // Recargar lista activas
      await loadDeletedEmpresas(); // Recargar lista eliminadas
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
