import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';

class FirebaseDB {
  static const String dbUrl = "https://inventario-de053-default-rtdb.firebaseio.com"; // 👈 tu URL de Firebase

  static DatabaseReference ref(String path) {
    if (kIsWeb) {
      return FirebaseDatabase(
        app: Firebase.app(),
        databaseURL: dbUrl,
      ).ref(path);
    } else {
      return FirebaseDatabase.instance.ref(path);
    }
  }
}
