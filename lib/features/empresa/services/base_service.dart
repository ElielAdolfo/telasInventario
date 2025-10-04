import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class BaseService {
  late final DatabaseReference dbRef;

  // 🔹 Define aquí el entorno: "prod", "dev" o "help"
  static const String _environment = 'prod'; // <-- cambia según el entorno

  BaseService(String path) {
    dbRef = _createRef(path);
  }

  // ✅ Método 2: Crear refs adicionales cuando los necesitas
  DatabaseReference buildRef(String path) {
    return _createRef(path);
  }

  // ✅ Método 3 (interno): lógica compartida para evitar duplicación
  DatabaseReference _createRef(String path) {
    final fullPath = '$_environment/$path'; // 👈 añade el entorno como raíz

    if (kIsWeb) {
      return FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://inventario-de053-default-rtdb.firebaseio.com',
      ).ref(fullPath);
    } else {
      return FirebaseDatabase.instance.ref(fullPath);
    }
  }
}
