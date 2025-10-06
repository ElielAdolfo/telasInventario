// lib/features/stock/services/codigo_service.dart
import 'package:inventario/features/empresa/models/codigo_modal.dart';
import 'package:inventario/features/empresa/services/base_service.dart';

class CodigoService extends BaseService {
  CodigoService() : super('codigos_stock');

  // Modificado para obtener el último código real usado en cualquier lugar
  Future<String?> obtenerUltimoCodigo() async {
    try {
      // Primero intentar obtener el último código de la tabla codigos_stock
      final snapshotCodigos = await dbRef
          .orderByChild('timestamp')
          .limitToLast(1)
          .once();
      print("Snapshot codigos: ${snapshotCodigos.snapshot.value}");
      String? ultimoCodigo;

      if (snapshotCodigos.snapshot.exists) {
        final data = snapshotCodigos.snapshot.value as Map;
        final lastKey = data.keys.first;
        final lastCodeData = Map<String, dynamic>.from(data[lastKey]);
        ultimoCodigo = lastCodeData['codigo'];
        print("Último código de codigos_stock: $ultimoCodigo");
      }

      // También verificar en stock_empresa para obtener el código más alto
      final stockRef = buildRef('stock_empresa');
      final snapshotStock = await stockRef
          .orderByChild('codigoUnico')
          .limitToLast(1)
          .once();

      if (snapshotStock.snapshot.exists) {
        final data = snapshotStock.snapshot.value as Map;
        final lastKey = data.keys.first;
        final lastStockData = Map<String, dynamic>.from(data[lastKey]);
        final ultimoCodigoStock = lastStockData['codigoUnico'];
        print("Último código de stock_empresa: $ultimoCodigoStock");

        // Comparar cuál código es más alto
        if (ultimoCodigo == null ||
            _compararCodigos(ultimoCodigoStock, ultimoCodigo) > 0) {
          ultimoCodigo = ultimoCodigoStock;
        }
      }
      print("Último código final: $ultimoCodigo");

      return ultimoCodigo;
    } catch (e) {
      print("Error al obtener último código: $e");
      return null;
    }
  }

  // Método para comparar dos códigos y determinar cuál es mayor
  int _compararCodigos(String codigo1, String codigo2) {
    // Formato esperado: A-0001, B-0001, etc.
    final partes1 = codigo1.split('-');
    final partes2 = codigo2.split('-');

    if (partes1.length != 2 || partes2.length != 2) return 0;

    final letra1 = partes1[0];
    final letra2 = partes2[0];
    final numero1 = int.tryParse(partes1[1]) ?? 0;
    final numero2 = int.tryParse(partes2[1]) ?? 0;

    // Comparar letras primero
    if (letra1 != letra2) {
      return letra1.compareTo(letra2);
    }

    // Si las letras son iguales, comparar números
    return numero1.compareTo(numero2);
  }

  // Modificado para actualizar el último código en lugar de crear uno nuevo cada vez
  Future<void> actualizarUltimoCodigo(String codigo) async {
    try {
      // Primero verificamos si ya existe un registro para actualizarlo
      final snapshot = await dbRef
          .orderByChild('timestamp')
          .limitToLast(1)
          .once();

      if (snapshot.snapshot.exists) {
        // Si existe, actualizamos el último registro
        final data = snapshot.snapshot.value as Map;
        final lastKey = data.keys.first;
        await dbRef.child(lastKey).update({
          'codigo': codigo,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        // Si no existe, creamos uno nuevo
        final newRef = dbRef.push();
        final codigoModel = CodigoModel(
          id: newRef.key!,
          codigo: codigo,
          timestamp: DateTime.now(),
        );
        await newRef.set(codigoModel.toJson());
      }

      print("Código actualizado exitosamente: $codigo");
    } catch (e) {
      print("Error al actualizar código: $e");
      rethrow;
    }
  }

  // Método para generar el siguiente código a partir del último
  String generarSiguienteCodigo(String ultimoCodigo) {
    // Formato esperado: A-0001, B-0001, etc.
    final partes = ultimoCodigo.split('-');
    if (partes.length != 2) return 'A-0001';

    final letra = partes[0];
    final numero = int.tryParse(partes[1]) ?? 0;

    if (numero < 9999) {
      // Incrementar el número
      return '$letra-${(numero + 1).toString().padLeft(4, '0')}';
    } else {
      // Cambiar a la siguiente letra
      final siguienteLetra = String.fromCharCode(letra.codeUnitAt(0) + 1);
      return '$siguienteLetra-0001';
    }
  }
}
