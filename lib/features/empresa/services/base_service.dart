// lib/features/empresa/services/base_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class BaseService {
  late final DatabaseReference dbRef;
  
  // URL de la base de datos - asegúrate de que esta sea la correcta
  static const String _databaseURL = 'https://inventario-de053-default-rtdb.firebaseio.com';
  
  // Define el entorno: "prod", "dev" o "help"
  static const String _environment = 'prod'; // <-- cambia según el entorno

  BaseService(String path) {
    dbRef = _createRef(path);
  }

  // Crear refs adicionales cuando los necesitas
  DatabaseReference buildRef(String path) {
    return _createRef(path);
  }

  // Lógica compartida para evitar duplicación
  DatabaseReference _createRef(String path) {
    final fullPath = '$_environment/$path'; // añade el entorno como raíz

    if (kIsWeb) {
      return FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: _databaseURL,
      ).ref(fullPath);
    } else {
      // Para móvil, necesitamos especificar la URL si no está en las opciones de Firebase
      return FirebaseDatabase.instance.refFromURL(_databaseURL).child(fullPath);
    }
  }
}