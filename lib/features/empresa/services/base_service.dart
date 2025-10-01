import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class BaseService {
  late final DatabaseReference dbRef;

  // ✅ Método 1: Inicialización automática con el path principal
  BaseService(String path) {
    dbRef = _createRef(path);
  }

  // ✅ Método 2: Crear refs adicionales cuando los necesitas
  DatabaseReference buildRef(String path) {
    return _createRef(path);
  }

  // ✅ Método 3 (interno): lógica compartida para evitar duplicación
  DatabaseReference _createRef(String path) {
    if (kIsWeb) {
      return FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://inventario-de053-default-rtdb.firebaseio.com',
      ).ref(path);
    } else {
      return FirebaseDatabase.instance.ref(path);
    }
  }
}
